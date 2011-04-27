(* parser.mli *)
(* Parse a preparsed file *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

open Parsed_syntax

val parse_header : header list -> parsed_header
val parse_source_code : expression list -> parsed_source_code

