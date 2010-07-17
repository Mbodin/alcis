%{
(* preparser.mly *)
(* Preparse the input. *)
(* author : Martin BODIN <martin.bodin@ens-lyon.org> *)

  open Parsed_syntax
  exception Eof
%}

%token <bool> BOOL
%token <int> INT /* FIXME: Use string instead of int, so that the program can work with real integer. */
%token <string> IDENT
%token LPAREN RPAREN
%token COLON
%token EQUAL
%token COLON LPRIOR RPRIOR
%token SEMI_COLON
%token FUN RIGHT_ARROW
%token FOR IN WHILE IF ELSE
%token UNDERSCORE
%token EOF

/* FIXME: Priorities to be reread */
%nonassoc   prec_comparison
%nonassoc   below_prec_expression
%nonassoc   prec_expression
%nonassoc   prec_prototype
%nonassoc   prec_constante
%nonassoc   below_SEMI_COLON
%left       SEMI_COLON
%right      RIGHT_ARROW
%nonassoc   below_COLON
%nonassoc   COLON
%nonassoc   below_PAREN
%nonassoc   LPAREN RPAREN
%nonassoc   below_PRIOR
%nonassoc   LPRIOR RPRIOR
%nonassoc   below_IDENT
%nonassoc   BOOL INT IDENT UNDERSCORE

%start header body lex_flot
%type <Parsed_syntax.header list> header
%type <Parsed_syntax.expression> body
%type <string list> lex_flot

%%

header:
    | structure_header EOF                                                      { $1 }
;

body:
    | structure_body EOF                                                        { $1 }
;

structure_header:
    | comparison structure_header %prec prec_comparison                         { $1 :: $2 }
    | prototype structure_header %prec prec_prototype                           { $1 :: $2 }
;

structure_body:
    | expression %prec prec_expression                                          { $1 }
;

expression:
    | constante %prec prec_constante                                            { Constante $1 }
    | expression_no_semi_colon %prec below_SEMI_COLON                           { Expression_list $1 }
    | expression_no_semi_colon SEMI_COLON expression                            { Expression_sequence ($1, $3) }
;

expression_no_semi_colon:
    | expression_item_prior %prec below_COLON                                   { $1 :: [] }
    | expression_item_prior expression_no_semi_colon                            { $1 :: $2 }
;

prototype:
    | expr_item_prior_inv_colon_list_args                                       { match $1 with
                                                                                    | List_type a, b -> Prototype (List_type (List.rev a), b)
                                                                                    | Arrow (List_type a, c), b -> Prototype (Arrow (List_type (List.rev a), c), b)
                                                                                    | ((Arrow (Arrow _, _)) as a), b -> Prototype (a, b) }
;

expr_item_prior_inv_colon_list_args:
    | expression_item_prior RIGHT_ARROW fun_type COLON arg                      { (Arrow (List_type ($1 :: []), $3), $5 :: []) }
    | expression_item_prior COLON arg                                           { (List_type ($1 :: []), $3 :: []) }
    | expression_item_prior expr_item_prior_inv_colon_list_args arg             { match $2 with
                                                                                    | List_type a, b -> (List_type ($1 :: a), $3 :: b)
                                                                                    | Arrow (List_type a, c), b -> (Arrow (List_type ($1 :: a), c), $3 :: b)
                                                                                    | Arrow (Arrow _, _), _ -> Errors.error "Internal Error" } /* FIXME: A better error file. */
;

fun_type:
    | expression_no_semi_colon                                                  { List_type $1 }
    | fun_type RIGHT_ARROW fun_type                                             { Arrow ($1, $3) }

constante:
    |  expr_item_prior_inv_colon_list_args EQUAL expression_no_semi_colon SEMI_COLON      { match $1 with
                                                                                    | List_type a, b -> (List_type (List.rev a), b, Expression_list $3)
                                                                                    | Arrow (List_type a, c), b -> (Arrow(List_type (List.rev a), c), b, Expression_list $3)
                                                                                    | Arrow (Arrow _, _), _ -> Errors.error "Internal Error" } /* FIXME */
;

expression_item_prior:
    | LPRIOR expression_item RPRIOR                                             { ($2, true) }
    | expression_item %prec below_COLON                                         { ($1, false) }
;

expression_item:
    | BOOL                                                                      { Bool $1 }
    | INT                                                                       { Int $1 }
    | arg %prec below_SEMI_COLON                                                { match $1 with
                                                                                    | Arg_ident i -> Ident i
                                                                                    | Arg_underscore -> Underscore }
    | LPAREN expression RPAREN                                                  { Expr $2 }
;

arg:
    | UNDERSCORE                                                                { Arg_underscore }
    | IDENT                                                                     { Arg_ident $1 }
;

comparison:
    | expression_no_semi_colon RPRIOR expression_no_semi_colon SEMI_COLON       { Comparison ($1, $3) }
    | expression_no_semi_colon LPRIOR expression_no_semi_colon SEMI_COLON       { Comparison ($3, $1) }
;


/* ================================ */
/* Rules used to draw a lexem flow. */
/* ================================ */
lex_flot:
  | LPAREN lex_flot                                 { "LPAREN" :: $2 }
  | RPAREN lex_flot                                 { "RPAREN" :: $2 }
  | INT lex_flot                                    { (Printf.sprintf "INT (%d)" $1) :: $2 }
  | BOOL lex_flot                                   { (Printf.sprintf "BOOL (%B)" $1) :: $2 }
  | EQUAL lex_flot                                  { "EQUAL" :: $2 }
  | SEMI_COLON lex_flot                             { "SEMI_COLON" :: $2 }
  | COLON lex_flot                                  { "COLON" :: $2 }
  | FUN lex_flot                                    { "FUN" :: $2 }
  | IN lex_flot                                     { "IN" :: $2 }
  | WHILE lex_flot                                  { "WHILE" :: $2 }
  | IF lex_flot                                     { "IF" :: $2 }
  | ELSE lex_flot                                   { "ELSE" :: $2 }
  | UNDERSCORE lex_flot                             { "UNDERSCORE" :: $2 }
  | IDENT lex_flot                                  { (Printf.sprintf "IDENT (%s) " $1) :: $2 }
  | EOF                                             { "EOF" :: [] }
;

%%

