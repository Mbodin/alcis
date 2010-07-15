%{
  open Parsed_syntax
  exception Eof
%}

%token <bool> BOOL
%token <int> INT
%token <string> IDENT
%token LPAREN RPAREN
%token COLON
%token EQUAL
%token COMMA LPRIOR RPRIOR
%token SEMI_COLON
%token FUN
%token FOR IN WHILE IF ELSE
%token UNDERSCORE
%token RIGHT_ARROW
%token EOF

%left SEMICOLON

%start implementation lex_flot
%type <string Syntax.expr> implementation
%type <string list> lex_flot

%%

implementation:
    | structure EOF                                             { $1 }
;

structure: /* Split the header and the body. */
    | prototype structure                                       { $1 :: $2 }
    | declaration structure                                     { $1 :: $2 }
    | instruction structure                                     { $1 :: $2 }
    | expression                                                { $1 :: [] }
;

instruction:
    | expression SEMICOLON                                      { $1 }
;

expression:
    | BOOL                                                      { Parsed_bool $1 }
    | INT                                                       { Parsed_int $1 }
    | IDENT                                                     { Parsed_ident $1 }
    | LPAREN expression RPAREN                                  { $2 }
;

prototype:
    | list_type_prototype COMMA list_expr_prototype             { Parse_prototype ($1, $3) }
;

list_type_prototype:
    | LPRIOR type_prototype RPRIOR list_type_prototype          { ($2, true) :: $4 }
    | type_prototype list_type_prototype                        { ($1, false) :: $2 }
    | /* empty */                                               { [] }
;

list_type_decl:
    | type_decl list_type_decl                                  { $1 :: $2 }
    | /* empty */                                               { [] }
;

list_expr_prototype:
    | expr_prototype list_expr_prototype                        { $1 :: $2 }
    | /* empty */                                               { [] }
;

type_prototype:
    | list_expr_prototype RIGHT_ARROW list_expr_prototype       { Parsed_arrow_proto ($1, $3) }
    | LPAREN expression RPAREN                                  { Parsed_expr_proto $2 }
    | IDENT                                                     { Parsed_type_name_proto $1 }
;

type_decl:
    | list_expr_decl RIGHT_ARROW list_expr_decl                 { Parsed_arrow_decl ($1, $3) }
    | LPAREN expression RPAREN                                  { Parsed_expr_decl $2 }
    | IDENT                                                     { Parsed_type_name_decl $1 }
;

expr_prototype:
    | UNDERSCORE                                                { Parsed_expr_proto_underscore }
    | IDENT                                                     { Parsed_expr_proto_ident $1 }
;

declaration:
    | list_type_decl COMMA list_type_decl EQUAL expression      { Parse_decl ($1, $3, $5) }
;


/* ================================ */
/* Rules used to draw a lexem flow. */
/* ================================ */
lex_flot:
  | LPAREN lex_flot                                 { "LPAREN" :: $2 }
  | RPAREN lex_flot                                 { "RPAREN" :: $2 }
  | INT lex_flot                                    { (Printf.sprintf "INT (%d)" $1) :: $2 }
  | BOOL lex_flot                                   { (Printf.sprintf "BOOL (%B)" $1) :: $2 }
  | COLON lex_flot                                  { "COLON" :: $2 }
  | EQUAL lex_flot                                  { "EQUAL" :: $2 }
  | SEMI_COLON lex_flot                             { "SEMI_COLON" :: $2 }
  | COMMA lex_flot                                  { "COMMA" :: $2 }
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

