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

type 'a e = 'a * t

let get_pos (_, p) = p
let get_val (a, _) = a


let current_pos = ref global

let get_position () = !current_pos

let set_filename name =
    current_pos := (name, None)

let new_line () =
    match !current_pos with
    | (f, Some (l, _)) -> current_pos := (f, Some (l + 1, Some 0))
    | (f, None) -> current_pos := (f, Some (1, None))

let characters_read n =
    match !current_pos with
    | (f, Some (l, Some c)) -> current_pos := (f, Some (l, Some (c + n)))
    | (f, Some (l, None)) -> current_pos := (f, Some (l, Some n))
    | (f, None) -> current_pos := (f, Some (0, Some n))

