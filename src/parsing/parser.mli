(* parser.mli *)
(* Parse a preparsed file *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

open Parsed_syntax

val parse_header : header -> parsed_header
val parse_source_code : expression -> parsed_source_code

