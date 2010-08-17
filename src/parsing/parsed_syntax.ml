(* parsed_syntax.ml *)
(* Define all the structures that are used to represent the code. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)


type header =
    | Prototype of list_type * arg list
    | Comparison of (expression_item * bool) list * (expression_item * bool) list

and body =
    | Definition of (list_type * arg list * expression)
    | Expression of expression

and list_type =
    | Arrow of list_type * list_type
    | List_type of (expression_item * bool) list

and arg = 
    | Arg_underscore
    | Arg_ident of string

and expression =
    | Expression_list of (expression_item * bool) list
    | Expression_sequence of (expression_item * bool) list * expression

and expression_item =
    | Bool of bool
    | Int of int
    | Ident of string
    | Underscore
    | Expr of expression

