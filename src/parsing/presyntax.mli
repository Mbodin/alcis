(** The structure that is being parsed by the preparser *)
(* author: Martin Constantino–Bodin <martin.bodin@ens-lyon.org> *)


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
    | Int of string Position.e	(* Note that int are treated through string to allow using as long integers as wanted. *)
    | Ident of string Position.e
    | Underscore of Position.t
    | Expr_fun of Position.t
    | Expr of expression


type parsed_header = (name_expr, type_expr) Hashtbl.t

and parsed_source_code = (name_expr, type_expr * parsed_expression) Hashtbl.t * parsed_expression

and type_expr = type_expr_item list

and type_expr_item =
    | Fun
    | Type
    | Type_expr of parsed_expression (* The identifier case is included in that case. *)

and name_expr = name_expr_item list Position.e (* The position corresponds to where the notation has been defined. *)

and name_expr_item =
    | Expr_ident of string
    | Expr_underscore of type_expr_item

and parsed_expression =
	| Integer of string Position.e
    | Name of name_expr Position.e (* The position corresponds to where it has been used. *)
    | Application of (parsed_expression * parsed_expression list) Position.e
    | Sequence of (parsed_expression * parsed_expression) Position.e

