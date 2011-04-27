(* parser.ml *)
(* Parse a preparsed file *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

open Parsed_syntax

let gv = Position.get_val


let filename = ref Position.global

let priorities : (name_expr, name_expr list) Hashtbl.t = Hashtbl.create 100
(* Each element of a name_expr are all the element less important than it. *)


let rec string_of_parsed_expression = function
	| Integer i -> gv i
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


let name_expr_of_expression_item = function (* FIXME: Explain precisely the goal of this function: I thonk I just don’t need the following FIXME… *)
	| Int i -> Integer i
	| Ident se -> Name (Position.apply (fun s -> Position.cetiq (* FIXME: The position does not correspond to what is expected! *) [Expr_ident s]) se)
	| Underscore p -> Name (Position.etiq (Position.cetiq (* FIXME: Same problem as above. *) [Expr_underscore Type (* FIXME: add an “unknow” type just for this part of the process? *)]) p)
	| Expr_fun p -> Name (Position.etiq (Position.cetiq (* FIXME: Same problem as above. *) [Expr_underscore Type (* FIXME: To be reread… *) ]) p)
	| Expr e -> Errors.not_implemented "name_expr_of_expression_item." (* FIXME *)

let parse_source_code _ = Errors.not_implemented "parse_source_code." (* FIXME *)

let parse_header_part ph = function
	| Prototype (list_types, args) -> Errors.not_implemented "parse_header." (* FIXME *)
	| Comparison (el1, el2) -> Errors.not_implemented "parse_header." (* FIXME *)

let parse_header h =
	let ph : parsed_header = Hashtbl.create 50 in
	List.iter (parse_header_part ph) h ;
	ph

