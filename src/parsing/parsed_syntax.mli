(* parsed_syntax.mli *)
(* Define all the structures that are used to represent the code. *)

type parsed_ast =
    | Parse_prototype of parsed_list_type_proto * parsed_list_expr_proto
    | Parse_decl of parsed_list_type_decl * parsed_list_type_expr * parsed_expression

and parsed_list_type_proto = (parsed_type_proto * bool) list

and parsed_type_proto =
    | Parsed_expr_proto of parsed_expression
    | Parsed_type_name_proto of string
    | Parsed_arrow_proto of parsed_list_type_proto * parsed_list_type_proto


    (* FIXME: finish that file. *)

