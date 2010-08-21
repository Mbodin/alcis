(* io.ml *)
(* Contains functions to manipulate files. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)


let _ = Choices.add_option "input" (Choices.Input_list [])

let _ = Choices.add_action "-ah" 1 ["file"] "Read the file as an Alcis header (“-” stand for the standard input)"
    (function
        | f :: [] ->
            Choices.set_value "input"
                (Choices.Input_list (match f, Choices.get_value "input" with
                | "-", Choices.Input_list l -> (stdin, Choices.Alcis_header) :: l
                | f, Choices.Input_list l -> (open_in f, Choices.Alcis_header) :: l
                | _ -> Errors.internal_error ["The option “input” does not contain an input list."]))
        | l -> Errors.internal_error ["The option “-ah” requests one argument, but " ^ (string_of_int (List.length l)) ^ " were given to it."] (* FIXME: Make a generic function for this message. *)
    )

