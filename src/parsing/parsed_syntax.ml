(* parsed_syntax.ml *)
(* Define all the structures that are used to represent the code. *)
(* author : Martin BODIN <martin.bodin@ens-lyon.org> *)


type ast =
    | Prototype of list_type * arg list
    | Decl of list_type * arg list * expression
    | Expression of expression
    | Comparison of arg list * arg list

and list_type = (expression_item * bool) list

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

