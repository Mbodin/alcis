(* parser.ml *)
(* Parse a preparsed file *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

open Parsed_syntax

let gv = Position.get_val


let filename = ref Position.global

let priorities = Hashtbl.create 50
(* There follow the prototype of it. *)
(* val priorities : (name_expr, name_expr list) Hashtbl.t *)
(* Each element of a name_expr are all the element less important than it. *)


let rec string_of_parsed_expression = function
    | Name p -> string_of_name_expr (gv p)
    | Application p ->
            let f, args = gv p in
            List.fold_left (fun a b -> a ^ b) ""
            ("( " :: string_of_parsed_expression f :: " )"
            :: (List.map string_of_parsed_expression args))
    | Sequence p ->
            let s1, s2 = gv p in
            string_of_parsed_expression s1 ^ " ; " ^ string_of_parsed_expression s2

and string_of_name_expr name =
    let str_item = function
        | Expr_ident s -> s
        | Expr_underscore t -> "_" ^ " ( " ^ string_of_type_expr_item t ^ " )"
    in
    let rec aux = function
        | [] -> ""
        | a :: [] -> str_item a
        | a :: l -> str_item a ^ " " ^ aux l
    in aux (gv name)

and string_of_type_expr_item = function
        | Fun -> "fun"
        | Type -> "type"
        | Type_expr e -> "( " ^ string_of_parsed_expression e ^ " )"


let unknown_name_expr name =
    Errors.error !filename
    [
        "I’m sorry, but I’m afraid that the variable “" ^ string_of_name_expr name ^ "” is used before being declared.";
        "This variable is declared in " ^ Position.to_string (Position.get_pos name) ^ "."
    ]

let get_priorities a =
    try Hashtbl.find priorities a with
    | Not_found -> unknown_name_expr a

let greater a b =
    List.exists ((=) b) (get_priorities a)

let lesser a b = greater b a

let comparable a b =
    (greater a b) or (lesser a b)


let parse_header _ = Errors.internal_error ["Not implemented function: parse_header."] (* FIXME *)

let parse_source_code _ = Errors.internal_error ["Not implemented function: parse_source_code."] (* FIXME *)

