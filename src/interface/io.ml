(* io.ml *)
(* Contains functions to manipulate files. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)


let _ = Choices.add_option "input" (Choices.Input_list [])

let set_extension opt filename filetype =
    Choices.add_action opt 1 ["file"] ("Read the file as " ^ filename ^ " (“-” stand for the standard input)")
    (function
        | f :: [] ->
            Choices.set_value "input"
                (Choices.Input_list (match f, Choices.get_value "input" with
                | "-", Choices.Input_list l -> (stdin, filetype) :: l
                | f, Choices.Input_list l -> (open_in f, filetype) :: l
                | _ -> Errors.internal_error ["The option “input” does not contain an input list."]))
        | l -> Errors.internal_error ["The option “" ^ opt ^ "” requests one argument, but " ^ (string_of_int (List.length l)) ^ " were given to it."] (* FIXME: Make a generic function for this message. *)
    )

let _ = set_extension "-ah" "an Alcis header" Choices.Alcis_header
let _ = set_extension "-ac" "an Alcis source code" Choices.Alcis_source_code
let _ = set_extension "-ai" "an Alcis interface for C" Choices.Alcis_C_interface

