(* parsed_syntax.ml *)
(* Define all the structures that are used to represent the code. *)
(* author : Martin BODIN <martin.bodin@ens-lyon.org> *)


type ast =
    | Prototype of list_type_proto * expr_proto list
    | Decl of list_type_decl * list_type_decl * expression
    | Expression of expression

and list_type_proto = (type_proto * bool) list

and type_proto =
    | Expr_proto of expression
    | Type_name_proto of string
    | Arrow_proto of list_type_proto * list_type_proto

and type_decl =
    | Arrow_decl of type_decl * type_decl
    | Expr_decl of expression
    | Type_name_decl of string

and expr_proto =
    | Expr_proto_underscore
    | Expr_proto_ident of string

and list_type_decl = type_decl list

and expression =
    | Expression_list of expression_item list
    | Expression_sequence of expression_item list * expression

and expression_item =
    | Bool of bool
    | Int of int
    | Ident of string
    | Expr of expression

