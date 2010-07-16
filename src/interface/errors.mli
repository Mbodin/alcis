(* errors.mli *)
(* Functions to handle errors and a list of booleans that describe what to do if there is one. *)
(* author : Martin BODIN <martin.bodin@ens-lyon.org> *)

val error : string -> 'a
val warn : string -> unit


val warning_comments : unit -> bool

