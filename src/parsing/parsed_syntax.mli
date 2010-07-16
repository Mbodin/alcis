(* parsed_syntax.mli *)
(* Define all the structures that are used to represent the code. *)
(* author : Martin BODIN <martin.bodin@ens-lyon.org> *)


type ast =
    | Prototype of list_type * arg list
    | Decl of list_type * arg list * expression
    | Expression of expression

and list_type = (type_item * bool) list

and type_item =
    | Type_expr of expression
    | Type_name of string
    | Type
    | Arrow of list_type * list_type

and arg = 
    | Arg_underscore
    | Arg_ident of string

and expression =
    | Expression_list of expression_item list
    | Expression_sequence of expression_item list * expression

and expression_item =
    | Bool of bool
    | Int of int
    | Ident of string
    | Expr of expression

