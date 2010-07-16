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
%token TYPE COLON
%token EQUAL
%token COLON LPRIOR RPRIOR
%token SEMI_COLON
%token FUN
%token FOR IN WHILE IF ELSE
%token UNDERSCORE
%token RIGHT_ARROW
%token EOF

/* FIXME: Priorities to be reread */
%nonassoc   prec_prototype
%nonassoc   prec_declaration
%nonassoc   bw_prec_expression
%nonassoc   prec_expression
%nonassoc   bw_SEMI_COLON
%left       SEMI_COLON
%left       COLON
%nonassoc   bw_RIGHT_ARROW
%right      RIGHT_ARROW
%nonassoc   LPRIOR RPRIOR
%nonassoc   LPAREN RPAREN
%nonassoc   bw_IDENT
%nonassoc   BOOL INT IDENT TYPE

%start implementation lex_flot
%type <Parsed_syntax.ast list> implementation
%type <string list> lex_flot

%%

implementation:
    | structure EOF                                                             { $1 }
;

structure: /* Split the header and the body. */
    | prototype structure %prec prec_prototype                                  { $1 :: $2 }
    | declaration structure %prec prec_declaration                              { $1 :: $2 }
    | expression                                                                { Expression $1 :: [] }
;

expression_item:
    | BOOL                                                                      { Bool $1 }
    | INT                                                                       { Int $1 }
    | IDENT                                                                     { Ident $1 }
    | LPAREN expression RPAREN                                                  { Expr $2 }
;

expression:
    | expression_no_semi_colon %prec bw_SEMI_COLON                              { Expression_list $1 }
    | expression_no_semi_colon SEMI_COLON expression                            { Expression_sequence ($1, $3) }
;

expression_no_semi_colon:
    | expression_item                                                           { $1 :: [] }
    | expression_item expression_no_semi_colon                                  { $1 :: $2 }
;

prototype:
    | list_type_with_prior COLON list_args                                      { Prototype ($1, $3) }
;

declaration:
    | list_type_without_prior COLON list_args EQUAL expression_no_semi_colon    { Decl ($1, $3, Expression_list $5) }
;

list_type_with_prior:
    | LPRIOR type_item RPRIOR list_type_with_prior                              { ($2, true) :: $4 }
    | LPRIOR type_item RPRIOR                                                   { ($2, true) :: [] }
    | list_type_without_prior                                                   { $1 }
    | list_type_with_prior RIGHT_ARROW list_type_with_prior                     { (Arrow ($1, $3), false) :: [] }
;

list_type_without_prior:
    | type_item list_type_without_prior                                         { ($1, false) :: $2 }
    | type_item                                                                 { ($1, false) :: [] }
    | list_type_without_prior RIGHT_ARROW list_type_without_prior               { (Arrow ($1, $3), false) :: [] }
;

list_args:
    | arg list_args                                                             { $1 :: $2 }
    | arg %prec bw_IDENT                                                        { $1 :: [] }
;

type_item:
    | LPAREN expression RPAREN                                                  { Type_expr $2 }
    | IDENT                                                                     { Type_name $1 }
    | TYPE                                                                      { Type }
;

arg:
    | UNDERSCORE                                                                { Arg_underscore }
    | IDENT                                                                     { Arg_ident $1 }
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

