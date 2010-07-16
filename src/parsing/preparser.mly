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
%token FUN
%token FOR IN WHILE IF ELSE
%token UNDERSCORE
%token EOF

/* FIXME: Priorities to be reread */
/*%nonassoc   prec_comparison*//* FIXME */
%nonassoc   below_prec_expression
%nonassoc   prec_expression
%nonassoc   prec_prototype
%nonassoc   prec_declaration
%nonassoc   GREATER_PRIOR LESSER_PRIOR
%nonassoc   below_SEMI_COLON
%left       SEMI_COLON
%nonassoc   below_COLON
%left       COLON
%nonassoc   LPAREN RPAREN
%nonassoc   LPRIOR RPRIOR
%nonassoc   below_IDENT
%nonassoc   BOOL INT IDENT UNDERSCORE

%start implementation lex_flot
%type <Parsed_syntax.ast list> implementation
%type <string list> lex_flot

%%

implementation:
    | structure EOF                                                             { $1 }
;

structure: /* Split the header and the body. */
    /*| comparison structure %prec prec_comparison                                { $1 :: $2 }*//* FIXME */
    | prototype structure %prec prec_prototype                                  { $1 :: $2 }
    | declaration structure %prec prec_declaration                              { $1 :: $2 }
    | expression %prec prec_expression                                          { Expression $1 :: [] }
;

expression:
    | expression_no_semi_colon %prec below_SEMI_COLON                           { Expression_list $1 }
    | expression_no_semi_colon SEMI_COLON expression                            { Expression_sequence ($1, $3) }
;

expression_no_semi_colon:
    | expression_item %prec below_COLON                                         { $1 :: [] }
    | expression_item expression_no_semi_colon                                  { $1 :: $2 }
;

prototype:
    | list_type_with_prior_inv_colon_list_args                                  { let a, b = $1 in Prototype (List.rev a, b) }
;

list_type_with_prior_inv_colon_list_args:
    | list_type_with_prior_item COLON arg                                       { ($1 :: [], $3 :: []) }
    | list_type_with_prior_item list_type_with_prior_inv_colon_list_args arg    { let a, b = $2 in ($1 :: a, $3 :: b) }
;

declaration:
    |  list_type_with_prior_inv_colon_list_args EQUAL expression_no_semi_colon  { let a, b = $1 in Decl (List.rev a, b, Expression_list $3) }
;

list_type_with_prior_item:
    | LPRIOR expression_item RPRIOR                                             { ($2, true) }
    | expression_item %prec below_COLON                                         { ($1, false) }
;

expression_item:
    | BOOL                                                                      { Bool $1 }
    | INT                                                                       { Int $1 }
    | arg                                                                       { match $1 with
                                                                                    | Arg_ident i -> Ident i
                                                                                    | Arg_underscore -> Underscore }
    | LPAREN expression RPAREN                                                  { Expr $2 }
;

arg:
    | UNDERSCORE                                                                { Arg_underscore }
    | IDENT                                                                     { Arg_ident $1 }
;

/* FIXME : Add comparisons. (But the syntax of the current document is ambigous.) */
/*
list_args:
    | arg list_args                                                             { $1 :: $2 }
    | arg %prec below_IDENT                                                     { $1 :: [] }
;
comparison:
    | list_args RPRIOR list_args                                                { Comparison ($1, $3) }
    | list_args LPRIOR list_args                                                { Comparison ($3, $1) }
;
*/

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

