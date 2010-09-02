(* parser_printer.ml *)
(* Contains function to parse the temporary structures created while parsing. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)

open Parsed_syntax

let print_preparsed_header _ _ = Errors.not_implemented "print_preparsed_header." (* FIXME *)

let print_preparsed_expression _ _ _ = Errors.not_implemented "print_preparsed_expression." (* FIXME *)

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
    (fun out (channel, _) ->
            Lexer.eof_reached := false;
            let buf = Lexing.from_channel channel in
            while !Lexer.eof_reached = false
            do
                let result = Preparser.lex_flot Lexer.token buf in
                List.iter (fun s -> output_string out (s ^ " ")) result
            done
    )

let _ = set_dev "preparsed"
    (fun out (channel, t) ->
            Lexer.eof_reached := false;
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

