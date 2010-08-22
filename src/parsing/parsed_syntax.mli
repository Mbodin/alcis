(* parsed_syntax.mli *)
(* Define all the structures that are used to represent the code. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)


type header =
    | Prototype of list_type * arg list
    | Comparison of (expression_item * bool) list * (expression_item * bool) list

and list_type =
    | Arrow of list_type * list_type
    | List_type of (expression_item * bool) list

and arg = 
    | Arg_underscore of Position.t
    | Arg_ident of string Position.e

and expression =
    | Constant of list_type * arg list * expression
    | Variable of list_type * arg list
    | Expression_list of (expression_item * bool) list
    | Expression_sequence of expression * expression

and expression_item =
    | Int of string Position.e
    | Ident of string Position.e
    | Underscore of Position.t
    | Expr of expression

