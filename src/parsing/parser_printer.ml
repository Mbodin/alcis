(* parser_printer.ml *)
(* Contains function to parse the temporary structures created while parsing. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)

let _ = Choices.add_action "-o-lexemes" 1 ["file"] "(Only used by developpers)"
    (function
        | f :: [] ->
            let out = if f = "-" then stdout else open_out f in
            List.iter
            (fun (channel, _) ->
                    Lexer.eof_reached := false;
                    let buf = Lexing.from_channel channel in
                    while !Lexer.eof_reached = false
                    do
                        let result = Preparser.lex_flot Lexer.token buf in
                        List.iter (fun s -> output_string out (s ^ " ")) result
                    done)
            (match Choices.get_value "input" with
            | Choices.Input_list l -> l
            | _ -> Errors.internal_error ["The option “input” does not contain an input list."]) (* FIXME: A generic message for this. *)
        | l -> Choices.wrong_arg_number_error "-o-lexemes" 1 l
    )

