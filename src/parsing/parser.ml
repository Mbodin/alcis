(* parser.ml *)
(* Parse a preparsed file *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

open Parsed_syntax

let priorities = Hashtbl.create 50
(* There follow the prototype of it. *)
(* val priorities : (name_expr, name_expr list) Hashtbl.t *)
(* Each element of a name_expr are all the element less important than it. *)


let parse_header _ = Errors.internal_error ["Not implemented function: parse_header."] (* FIXME *)

let parse_source_code _ = Errors.internal_error ["Not implemented function: parse_source_code."] (* FIXME *)

