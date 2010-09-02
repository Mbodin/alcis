(* parser_printer.ml *)
(* Contains function to parse the temporary structures created while parsing. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)

let _ = Choices.add_action "-o-lexemes" 1 ["file"] "(Only used by developpers)"
    (function
        | f :: [] ->
                let out = open_out f in
                let channel = open_in "FIXME" in
                let buf = Lexing.from_channel channel in
                List.iter (fun s -> output_string out (s ^ " ")) (Preparser.lex_flot Lexer.token buf)
        | l -> Choices.wrong_arg_number_error "-o-lexemes" 1 l
    )

