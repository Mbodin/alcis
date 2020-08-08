{
(** Tokenize the input. *)
(* author: Martin Constantino–Bodin <martin.bodin@ens-lyon.org> *)

    open Preparser
    open Position

    let _ = Errors.define_warning "comments" true "Activate all warnings concerning comments"

    let reserved_identifiers =
      List.fold_left (fun m (id, v) -> PMap.add id v m) PMap.empty [
        (".", DOT) ;
        (":=", ASSIGN) ;
        ("::=", TYPE_ASSIGN) ;
        (":", COLON) ;
        ("|", PIPE) ;
        ("?", QUESTION_MARK) ;
        ("|>", LEFT_FUNCTION_APP) ;
        ("<|", RIGHT_FUNCTION_APP) ;
        ("\\", LAMBDA) ;
        ("->", RIGHT_ARROW) ;
      ]
}

let blank = [' ' '\t' '\r']

(* The “letters” of letter-based identifiers. *)
let letters = ['a'-'z' 'A'-'Z' '\'' '_']

(* Similarly, the symbols of symbol-based identifiers. *)
let symbol = ['`' '~' '!' '"' '@' '#' '$' '%' '^' '&' '*' '-' '+' '=' '[' ']' '{' '}' '\\' '/' '|' ';' ':' '<' '>' '?' ',' '.' '¬' '¦' '×' '÷' '¿' '¡' '€' '₤' '¤' '‘' '’' '“' '”' '°']
(* FIXME: Shall we accept all of Unicode? *)

let number = ['0'-'9']

(* FIXME: These [characters_read] and [new_line] feels bad practise. *)

rule token = parse

  | blank+ as s             { characters_read (String.length s (* FIXME: Unicode length and not ASCII length. *)); token lexbuf }    (* blanks are ignored. *)
  | '\n'                    { new_line (); token lexbuf }

  | '('                     { characters_read 1; LPAREN (get_position ()) }
  | ')'                     { characters_read 1; RPAREN }

  | "(|"                    { characters_read 2; LMODULE (get_position ()) }
  | "|)"                    { characters_read 2; RMODULE }

  | '.'                     { characters_read 1; DOT }
  | '_'                     { characters_read 1; UNDERSCORE (get_position ()) }

  | "?" (letters+ as s)     { characters_read (2 + String.length s); ARGUMENT ([], s) }
  | "??" (letters+ as s)    { characters_read (2 + String.length s); ARGUMENT ([Recursive], s) }
  | "?!" (letters+ as s)    { characters_read (2 + String.length s); ARGUMENT ([Strict], s) }
  | "??!" (letters+ as s)   { characters_read (2 + String.length s); ARGUMENT ([Recursive; Strict], s) }
  | "?&" (letters+ as s)    { characters_read (2 + String.length s); ARGUMENT ([Name], s) }

  | (letters+ as m) ".|>"   { characters_read (3 + String.length m); MODULE_OPEN m }
  | (letters+ as m) ".<|"   { characters_read (3 + String.length m); MODULE_INCLUDE m }
  | (letters+ as m) ".("    { characters_read (3 + String.length m); MODULE_LOCAL_OPEN m }
  | (letters+ as m) "." (letters+ as id)
                            { characters_read (1 + String.length m + String.length s);
                              MODULE_LOCAL_NAME (m, id) }

  | '?' (letters+ as s) '.' { characters_read (2 + String.length s); QUANTIFICATION s }

  | letters+ as s           { characters_read (String.length s); IDENT (cetiq s) }
  | number as s             { characters_read (String.length s); IDENT (cetiq s) }
  | symbol+ as s            { characters_read (String.length s);
                              try
                                PMap.find s reserved_identifiers
                              with Not_found -> IDENT (cetiq s) }

  | "(*"                    { comment lexbuf ; token lexbuf }

  | eof                     { EOF }

  | _                       { Errors.error (get_position ())
                                [Printf.sprintf "Unrecognized token ‘%s’ near characters %d-%d."
                                  (Lexing.lexeme lexbuf)
                                  (Lexing.lexeme_start lexbuf)
                                  (Lexing.lexeme_end lexbuf)]
                            }

and comment = shortest (* ignore comments *)
  | ")"                     { characters_read 1;
                              Errors.error (get_position ())
                                [Printf.sprintf "Ambigous comment ‘%s’ near %d-%d."
                                  (Lexing.lexeme lexbuf)
                                  (Lexing.lexeme_start lexbuf)
                                  (Lexing.lexeme_end lexbuf);
                                 "Consider adding a space at the beginning of the comment."];
                              comment lexbuf }
  | (_)*"(*" as s           { characters_read (String.length s); comment lexbuf; comment lexbuf }
  | (_)*"*)" as s           { characters_read (String.length s) }
  | (_)* as s eof           { Errors.error (get_position ())
                                ["Unfinished comment: “" ^ s ^ "”";
                                 "Consider adding “*)” at the end of the file."] }

