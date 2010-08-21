{
(* lexer.mll *)
(* Lex the input. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

    open Preparser
    let eof_reached = ref false

    let _ = Errors.define_warning "comments" true "Activate all warnings concerning comments"
}

let blank = [' ' '\t' '\n' '\r']

let integer_literal  = ['0'-'9']['0'-'9' '_']*
  | ("0x"|"0X")['0'-'9' 'A'-'F' 'a'-'f']['0'-'9' 'A'-'F' 'a'-'f' '_']*
  | ("0o"|"0O")['0'-'7']['0'-'7' '_']*
  | ("0b"|"0B")['0'-'1']['0'-'1' '_']*

let letter = ['a'-'z' 'A'-'Z']

let symbol = ['_' '!' '$' '%' '&' '*' '+' '-' '.' '/' '<' '=' '>' '?' '@' '^' '|' '~' '\'']
(* FIXME: Shall we accept all the UTF-8 ? *)

let identifier = (symbol | letter)(symbol | letter | ['0'-'9'])*


rule token = parse

  | blank+                  { token lexbuf }    (* blank are ignored. *)

  | '('                     { LPAREN }
  | ')'                     { RPAREN }

  | integer_literal as k    { INT k }

  | ':'                     { COLON }
  | '='                     { EQUAL }

  | ';'                     { SEMI_COLON }

  | "<<<"                   { LPRIOR }
  | ">>>"                   { RPRIOR }

  | "fun"                   { FUN }
  | "->"                    { RIGHT_ARROW }

  | "if"                    { IF }
  | "else"                  { ELSE }

  | '_'                     { UNDERSCORE }

  | identifier as s         { IDENT s }

  | "(*"                    { comment lexbuf ; token lexbuf }

  | eof                     { eof_reached := true; EOF }
  | _                       { Errors.error Position.global (*Position.make (Position.get_current_filename ()) (Position.current_line ()) (Position.current_char ()*) (* FIXME *)
                                [Printf.sprintf "I’m really sorry, but I don’t recognize the token ‘%s’ near the characters %d-%d."
                                (Lexing.lexeme lexbuf)
                                (Lexing.lexeme_start lexbuf)
                                (Lexing.lexeme_end lexbuf);
                                "Perhaps you misspell it."]
                            }

and comment = shortest (* ignore comments *)
  | ")"                     { if Errors.get_warning "comments" then Errors.warn Position.global (* FIXME *)
                            [
                                Printf.sprintf "This comment is ambigous ‘%s’ near %d-%d."
                                (Lexing.lexeme lexbuf)
                                (Lexing.lexeme_start lexbuf)
                                (Lexing.lexeme_end lexbuf);
                                "I will consider it as the beginning of a comment.";
                                "You should add a space there."
                            ]; comment lexbuf }
  | (_)*"(*"                { comment lexbuf; comment lexbuf }
  | (_)*"*)"                { }
  | (_)* as s eof           { if Errors.get_warning "comments" then Errors.warn Position.global (* FIXME *)
                                ["I’m afraid that the following comment is not finished : “" ^ s ^ "”";
                                "You should add “*)” at the end of the file, or at an other correct place."] }

