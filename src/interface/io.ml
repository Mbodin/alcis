(* io.ml *)
(* Contains functions to manipulate files. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)


let _ = Choices.add_option "input" (Choices.Input_list [])

let set_extension opt filename filetype =
    Choices.add_action opt 1 ["file"] ("Read the file as " ^ filename ^ " (“-” stands for the standard input)")
    (function
        | f :: [] ->
            Choices.set_value "input"
                (Choices.Input_list (match f, Choices.get_value "input" with
                | "-", Choices.Input_list l -> (stdin, filetype) :: l
                | f, Choices.Input_list l -> (open_in f, filetype) :: l
                | _ -> Errors.internal_error ["The option “input” does not contain an input list."]))
        | l -> Choices.wrong_arg_number_error opt 1 l
    )

let _ = set_extension "-ah" "an Alcis header" Position.Alcis_header
let _ = set_extension "-ac" "an Alcis source code" Position.Alcis_source_code
let _ = set_extension "-ai" "an Alcis interface for C" Position.Alcis_C_interface
let _ = set_extension "-c" "a C source code" Position.C_source_code
let _ = set_extension "-h" "a C header" Position.C_header

let get_file_type n =
    let check_with e =
        if String.length e > String.length n then false
        else
            let b = ref true in
            for i = 0 to String.length e - 1
            do
                b := !b && n.[String.length n - String.length e + i] = e.[i]
            done;
            !b
    in
    match () with
    | _ when check_with ".ah" -> Position.Alcis_header
    | _ when check_with ".ac" -> Position.Alcis_source_code
    | _ when check_with ".ai" -> Position.Alcis_C_interface
    | _ when check_with ".c" -> Position.C_source_code
    | _ when check_with ".h" -> Position.C_header
    | _ -> Errors.error Position.global ["I’m really sorry, but I don’t recognize the extension of the file “" ^ n ^ "”.";
    "You may retry with one of the option “-ah”, “-ac”, “-ai”, etc. insteed of “-i”."]

let _ = Choices.add_action "-i" 1 ["file"] "Read the file depending on its extension"
    (function
        | f :: [] ->
                Choices.set_value "input"
                (Choices.Input_list (match Choices.get_value "input" with
                | Choices.Input_list l -> (open_in f, get_file_type f) :: l
                | _ -> Errors.internal_error ["The option “input” does not contain an input list."]))
        | l -> Choices.wrong_arg_number_error "-i" 1 l
    )

