%{
(* preparser.mly *)
(* Preparse the input. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

  open Parsed_syntax
  exception Eof

  let parsing_error l =
      Errors.error (Position.get_position ())
      ((Printf.sprintf "I’m sorry, but I don’t understand the input, and I think it’s a syntax error at characters %d-%d." (Parsing.symbol_start ()) (Parsing.symbol_end ())) :: l)

  let parse_error s =
      parsing_error [s]

  let expecting expct =
      parsing_error [
          "I was expecting an expression of the pattern “" ^ expct ^ "”.";
      ]

  let double_arrow_error = ["In the file preparser.mly, a double right arrow type appears to be misparenthesis."]

%}

%token <string Position.e> INT /* The Ocaml int type would be two small for real integers. */
%token <string Position.e> IDENT
%token LPAREN RPAREN
%token COLON
%token EQUAL
%token COLON LPRIOR RPRIOR
%token SEMI_COLON
%token FUN RIGHT_ARROW
%token IF ELSE
%token <Position.t> UNDERSCORE
%token EOF

%nonassoc   error
%left       SEMI_COLON
%right      RIGHT_ARROW
%nonassoc   below_COLON
%nonassoc   COLON
%nonassoc   LPAREN RPAREN LPRIOR RPRIOR
%nonassoc   INT IDENT UNDERSCORE

%start header body lex_flot
%type <Parsed_syntax.header list> header
%type <Parsed_syntax.expression> body
%type <string list> lex_flot

%%

header:
    | structure_header EOF                                                                  { $1 }
;

body:
    | structure_body EOF                                                                    { $1 }
;

structure_header:
    | comparison structure_header                                                           { $1 :: $2 }
    | prototype structure_header                                                            { $1 :: $2 }
    | /* empty */                                                                           { [] }
;

structure_body:
    | expression                                                                            { $1 }
;

expression:
    | definition                                                                            { let a, b, c = $1 in Constant (a, b, c) }
    | declaration                                                                           { let a, b = $1 in Variable (a, b) }
    | expression_no_semi_colon                                                              { Expression_list $1 }
    | expression SEMI_COLON expression                                                      { Expression_sequence ($1, $3) }
    | /* empty */ %prec error                                                               { expecting "<expression>" }
;

expression_no_semi_colon:
    | expression_item_prior %prec below_COLON                                               { $1 :: [] }
    | expression_item_prior expression_no_semi_colon                                        { $1 :: $2 }
;

prototype:
    | expr_item_prior_inv_colon_list_args                                                   { match $1 with
                                                                                                | List_type a, b -> Prototype (List_type (List.rev a), b)
                                                                                                | Arrow (List_type a, c), b -> Prototype (Arrow (List_type (List.rev a), c), b)
                                                                                                | ((Arrow (Arrow _, _)) as a), b -> Prototype (a, b) }
;

expr_item_prior_inv_colon_list_args:
    | expression_item_prior RIGHT_ARROW fun_type COLON arg                                  { (Arrow (List_type ($1 :: []), $3), $5 :: []) }
    | expression_item_prior COLON arg                                                       { (List_type ($1 :: []), $3 :: []) }
    | expression_item_prior expr_item_prior_inv_colon_list_args arg                         { match $2 with
                                                                                                | List_type a, b -> (List_type ($1 :: a), $3 :: b)
                                                                                                | Arrow (List_type a, c), b -> (Arrow (List_type ($1 :: a), c), $3 :: b)
                                                                                                | Arrow (Arrow _, _), _ -> Errors.internal_error double_arrow_error }
;

fun_type:
    | /* empty */ %prec error                                                               { expecting "<type>" }
    | expression_no_semi_colon                                                              { List_type $1 }
    | fun_type RIGHT_ARROW fun_type                                                         { Arrow ($1, $3) }
;

definition:
    | expr_item_prior_inv_colon_list_args %prec error                                       { expecting "=" }
    | expr_item_prior_inv_colon_list_args EQUAL %prec error                                 { expecting "<expression>" }
    | expr_item_prior_inv_colon_list_args EQUAL expression_no_semi_colon %prec error        { expecting ";" }
    | expr_item_prior_inv_colon_list_args EQUAL expression_no_semi_colon SEMI_COLON         { match $1 with
                                                                                                | List_type a, b -> (List_type (List.rev a), b, Expression_list $3)
                                                                                                | Arrow (List_type a, c), b -> (Arrow (List_type (List.rev a), c), b, Expression_list $3)
                                                                                                | Arrow (Arrow _, _), _ -> Errors.internal_error double_arrow_error }
;

declaration:
    | expr_item_prior_inv_colon_list_args SEMI_COLON                                        { match $1 with
                                                                                                | List_type a, b -> (List_type (List.rev a), b)
                                                                                                | Arrow (List_type a, c), b -> (Arrow (List_type (List.rev a), c), b)
                                                                                                | Arrow (Arrow _, _), _ -> Errors.internal_error double_arrow_error }
;

expression_item_prior:
    | LPRIOR %prec error                                                                    { expecting "<expression> >>>" }
    | LPRIOR expression_item %prec error                                                    { expecting ">>>" }
    | LPRIOR expression_item RPRIOR                                                         { ($2, true) }
    | expression_item                                                                       { ($1, false) }
;

expression_item:
    | INT                                                                                   { Int $1 }
    | arg                                                                                   { match $1 with
                                                                                                | Arg_ident i -> Ident i
                                                                                                | Arg_underscore p -> Underscore p }
    | LPAREN expression RPAREN                                                              { Expr $2 }
    | LPAREN expression                                                                     { expecting ")" }
;

arg:
    | UNDERSCORE                                                                            { Arg_underscore $1 }
    | IDENT                                                                                 { Arg_ident $1 }
;

comparison:
    | expression_no_semi_colon RPRIOR expression_no_semi_colon SEMI_COLON                   { Comparison ($1, $3) }
    | expression_no_semi_colon LPRIOR expression_no_semi_colon SEMI_COLON                   { Comparison ($3, $1) }
;


/* ================================ */
/* Rules used to draw a lexem flow. */
/* ================================ */
lex_flot:
    | token lex_flot                                                                        { $1 :: $2 }
    | EOF                                                                                   { "EOF" :: [] }
;

token:
  | LPAREN                                                                                  { "LPAREN" }
  | RPAREN                                                                                  { "RPAREN" }
  | LPRIOR                                                                                  { "LPRIOR" }
  | RPRIOR                                                                                  { "RPRIOR" }
  | INT                                                                                     { (Printf.sprintf "INT (“%s”)" (Position.get_val $1)) }
  | EQUAL                                                                                   { "EQUAL" }
  | SEMI_COLON                                                                              { "SEMI_COLON" }
  | COLON                                                                                   { "COLON" }
  | FUN                                                                                     { "FUN" }
  | IF                                                                                      { "IF" }
  | ELSE                                                                                    { "ELSE" }
  | UNDERSCORE                                                                              { "UNDERSCORE" }
  | IDENT                                                                                   { (Printf.sprintf "IDENT (“%s”)" (Position.get_val $1)) }
;

%%

