
open Parsed_syntax

let decal out i =
    output_string out (String.make i '\t')

let rec print_preparsed_header out l =
    let print_aux = function
        | Prototype (lt, argl) -> output_string out "Prototype (\n";
                                  print_preparsed_list_type out 1 lt;
                                  output_string out "\t,\n";
                                  List.iter (print_preparsed_arg out 1) argl;
                                  output_string out "\t)\n"
        | Comparison (l1, l2) -> output_string out "Comparison (\n";
                                    List.iter (fun (e, _) -> print_preparsed_expression_item out 1 e) l1;
                                    output_string out "\t,\n";
                                    List.iter (fun (e, _) -> print_preparsed_expression_item out 1 e) l2;
                                    output_string out "\t)\n"
    in
    List.iter print_aux l

and print_preparsed_list_type out d = function
    | Arrow (l1, l2) -> decal out d;
                        output_string out "Arrow (\n";
                        print_preparsed_list_type out (d + 1) l1;
                        decal out d;
                        output_string out "\t,\n";
                        print_preparsed_list_type out (d + 1) l2;
                        decal out d;
                        output_string out "\t)\n"
    | List_type l -> decal out d;
                        output_string out "List_type (\n";
                        List.iter
                        (function
                            | (e, false) -> print_preparsed_expression_item out (d + 1) e
                            | (e, true) -> decal out (d + 1);
                                            output_string out "Prior (\n";
                                            print_preparsed_expression_item out (d + 2) e;
                                            decal out (d + 2);
                                            output_string out ")\n"
                        ) l;
                        decal out d;
                        output_string out "\t)\n"

and print_preparsed_arg out d = function
    | Arg_underscore _ -> decal out d;
                        output_string out "_\n"
    | Arg_ident name -> decal out d;
                        output_string out ("“" ^ Position.get_val name ^ "”\n")

and print_preparsed_expression out d = function
    | Expression_list l -> decal out d;
                            output_string out "Expression_list (\n";
                            List.iter (function
                                | e, false -> print_preparsed_expression_item out (d + 1) e
                                | _, true -> decal out (d + 1);
                                                output_string out "<prioritary expression (probably a syntax error not yet detected there.)>\n"
                            ) l;
                            decal out d;
                            output_string out "\t)\n"
    | Expression_sequence (e1, e2) -> decal out d;
                                      output_string out "(\n";
                                      print_preparsed_expression out d e1;
                                      decal out d;
                                      output_string out ";\n";
                                      print_preparsed_expression out d e2;
                                      decal out d;
                                      output_string out ")\n"
    | Constant (l, a, e) -> decal out d;
                            output_string out "Constant (\n";
                            print_preparsed_list_type out (d + 1) l;
                            decal out d;
                            output_string out "\t,\n";
                            List.iter (print_preparsed_arg out (d + 1)) a;
                            decal out d;
                            output_string out "\t,\n";
                            print_preparsed_expression out (d + 1) e;
                            decal out d;
                            output_string out "\t)\n"
     | Variable (l, a) -> decal out d;
                            output_string out "Variable (\n";
                            print_preparsed_list_type out (d + 1) l;
                            decal out d;
                            output_string out "\t,\n";
                            List.iter (print_preparsed_arg out (d + 1)) a;
                            decal out d;
                            output_string out "\t)\n"

and print_preparsed_expression_item out d = function
    | Expr e -> decal out d;
                output_string out "Expr (\n";
                print_preparsed_expression out (d + 1) e;
                decal out d;
                output_string out "\t)\n"
    | e ->
        decal out d;
        output_string out
        (match e with
            | Int i -> "Int (" ^ Position.get_val i ^ ")\n"
            | Ident i -> "Ident (“" ^ Position.get_val i ^ "”)\n"
            | Underscore _ -> "Underscore\n"
            | Expr_fun _ -> "Fun\n"
            | Expr _ -> Errors.internal_error ["A value changed itself while reading it."]
        )

let set_output name descr fu = Choices.add_action ("-o-" ^ name) 1 ["file"] descr
    (function
        | f :: [] ->
            let out = if f = "-" then stdout else open_out f in
            List.iter (fu out)
            (match Choices.get_value "input" with
            | Choices.Input_list l -> l
            | _ -> Errors.misstyped "input" "an input list")
        | l -> Choices.wrong_arg_number_error "-o-lexemes" 1 l
    )

let set_dev name f = set_output name "(Only used by developpers)" f

let _ = set_dev "lexemes"
    (fun out (name, channel, _) ->
            Position.set_filename name;
            let buf = Lexing.from_channel channel in
            let result = Preparser.lex_flot Lexer.token buf in
            List.iter (fun s -> output_string out (s ^ " ")) result
    )

let _ = set_dev "preparsed"
    (fun out (name, channel, t) ->
            Position.set_filename name;
            let buf = Lexing.from_channel channel in
            match t with
            | Position.Alcis_header ->
                    let result = Preparser.header Lexer.token buf in
                    print_preparsed_header out result
            | Position.Alcis_source_code ->
                    let result = Preparser.body Lexer.token buf in
                    print_preparsed_expression out 0 result
            | _ -> Errors.not_implemented "preparsed in parser_printer.ml" (* FIXME *)
                )

