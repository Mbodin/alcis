{
(* lexer.mll *)
(* Lex the input. *)
(* author : Martin BODIN <martin.bodin@ens-lyon.org> *)

    open Preparser
    let eof_reached = ref false
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

  | integer_literal as k    { INT (int_of_string k) }

  | "true"                  { BOOL true }
  | "false"                 { BOOL false }

  | ':'                     { COLON }
  | '='                     { EQUAL }
  | ';'                     { SEMI_COLON }
  | ','                     { COMMA }

  | "<<<"                   { LPRIOR }
  | ">>>"                   { RPRIOR }

  | "fun"                   { FUN }

  | "for"                   { FOR }
  | "in"                    { IN }
  | "while"                 { WHILE }

  | "if"                    { IF }
  | "else"                  { ELSE }

  | '_'                     { UNDERSCORE }

  | "->"                    { RIGHT_ARROW }

  | identifier as s         { IDENT s }

  | "(*"                    { comment lexbuf ; token lexbuf }

  | eof                     { eof_reached := true; EOF }
  | _                       { Errors.error
                                (Printf.sprintf "unrecognised token : ‘%s’ near %d-%d"
                                (Lexing.lexeme lexbuf)
                                (Lexing.lexeme_start lexbuf)
                                (Lexing.lexeme_end lexbuf))
                            }

and comment = shortest (* ignore comments *)
  | ")"                     { if Errors.warning_comments () then Errors.warn
                            (
                                Printf.sprintf "this will be considered as a open comment : ‘%s’ near %d-%d"
                                (Lexing.lexeme lexbuf)
                                (Lexing.lexeme_start lexbuf)
                                (Lexing.lexeme_end lexbuf)
                            ); comment lexbuf }
  | (_)*"(*"                { comment lexbuf; comment lexbuf }
  | (_)*"*)"                { }
  | (_)* as s eof           { if Errors.warning_comments () then Errors.warn ("unfinished comment : “" ^ s ^ "”") }

