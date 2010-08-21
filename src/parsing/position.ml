(* position.ml *)
(* Contains definition to know where something happens. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

type file_type =
    | Alcis_header
    | Alcis_source_code
    | Alcis_C_interface
    | C_header
    | C_source_code

type t = string * ((int * (int option)) option)

let get_filename (s, _) = s

let get_colon (_, p) =
    match p with
    | None -> None
    | Some (_, c) -> c

let get_line (_, p) =
    match p with
    | None -> None
    | Some (l, _) -> Some l

let make f = function
    | None -> fun _ -> f, None
    | Some l -> fun c -> f, Some (l, c)

let global = make Sys.executable_name None None

