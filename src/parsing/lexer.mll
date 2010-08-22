{
(* lexer.mll *)
(* Lex the input. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

    open Preparser
    open Position
    let eof_reached = ref false

    let _ = Errors.define_warning "comments" true "Activate all warnings concerning comments"
}

let blank = [' ' '\t' '\r']

let integer_literal  = ['0'-'9']['0'-'9' '_']*
  | ("0x"|"0X")['0'-'9' 'A'-'F' 'a'-'f']['0'-'9' 'A'-'F' 'a'-'f' '_']*
  | ("0o"|"0O")['0'-'7']['0'-'7' '_']*
  | ("0b"|"0B")['0'-'1']['0'-'1' '_']*

let letter = ['a'-'z' 'A'-'Z']

let symbol = ['_' '!' '$' '%' '&' '*' '+' '-' '.' '/' '<' '=' '>' '?' '@' '^' '|' '~' '\'']
(* FIXME: Shall we accept all the UTF-8 ? *)

let identifier = (symbol | letter)(symbol | letter | ['0'-'9'])*


rule token = parse

  | blank+ as s             { characters_read (String.length s); token lexbuf }    (* blank are ignored. *)
  | '\n'                    { new_line (); token lexbuf }

  | '('                     { characters_read 1; LPAREN }
  | ')'                     { characters_read 1; RPAREN }

  | integer_literal as k    { characters_read (String.length k); INT (cetiq k) }

  | ':'                     { characters_read 1; COLON }
  | '='                     { characters_read 1; EQUAL }

  | ';'                     { characters_read 1; SEMI_COLON }

  | "<<<"                   { characters_read 3; LPRIOR }
  | ">>>"                   { characters_read 3; RPRIOR }

  | "fun"                   { characters_read 3; FUN }
  | "->"                    { characters_read 2; RIGHT_ARROW }

  | "if"                    { characters_read 2; IF }
  | "else"                  { characters_read 4; ELSE }

  | '_'                     { characters_read 1; UNDERSCORE (get_position ()) }

  | identifier as s         { characters_read (String.length s); IDENT (cetiq s) }

  | "(*"                    { comment lexbuf ; token lexbuf }

  | eof                     { eof_reached := true; EOF }
  | _                       { Errors.error (get_position ())
                                [Printf.sprintf "I’m really sorry, but I don’t recognize the token ‘%s’ near the characters %d-%d."
                                (Lexing.lexeme lexbuf)
                                (Lexing.lexeme_start lexbuf)
                                (Lexing.lexeme_end lexbuf);
                                "Perhaps you misspell it."]
                            }

and comment = shortest (* ignore comments *)
  | ")"                     { characters_read 1; if Errors.get_warning "comments" then Errors.warn (get_position ())
                            [
                                Printf.sprintf "This comment is ambigous ‘%s’ near %d-%d."
                                (Lexing.lexeme lexbuf)
                                (Lexing.lexeme_start lexbuf)
                                (Lexing.lexeme_end lexbuf);
                                "I will consider it as the beginning of a comment.";
                                "You should add a space there."
                            ]; comment lexbuf }
  | (_)*"(*" as s           { characters_read (String.length s); comment lexbuf; comment lexbuf }
  | (_)*"*)" as s           { characters_read (String.length s) }
  | (_)* as s eof           { if Errors.get_warning "comments" then Errors.warn (get_position ())
                                ["I’m afraid that the following comment is not finished : “" ^ s ^ "”";
                                "You should add “*)” at the end of the file, or at an other correct place."] }

