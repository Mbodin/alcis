(* errors.ml *)
(* Functions to handle errors and a list of booleans that describe what to do if there is one. *)
(* author : Martin BODIN <martin.bodin@ens-lyon.org> *)

let error mesg =
    prerr_string (Sys.executable_name ^ ": error: ");
    prerr_string mesg;
    exit 1

let warn mesg =
    prerr_string (Sys.executable_name ^ ": warning: ");
    prerr_string mesg

let warning_comments () = true (* FIXME: Make that to be personnalisable. *)

