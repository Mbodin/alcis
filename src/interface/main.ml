(* main.ml *)
(* Launch the actions given in argument of the program. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)


let rec load_options = function
    | [] -> ()
    | action :: l ->
            let nb_needed = match Choices.get_nb_arg action with
                | Some n -> n
                | None -> Errors.error ["I’m really sorry, but I don’t know the option “" ^ action ^ "”."; "You can have the list of all available options with the option “-help”."]
            in
            let rec get_n_first = function
                | 0 -> fun l -> ([], l)
                | n -> function
                    | [] -> Errors.error ["I’m sorry but the option “" ^ action ^ "” needs " ^ (string_of_int nb_needed) ^ " argument, and only " ^ (string_of_int (nb_needed - n)) ^ " are given there."; "You can have some help with the option “-help”."]
                    | arg :: l -> let args, l' = get_n_first (n - 1) l in (arg :: args, l')
            in
            let args, queue = get_n_first nb_needed l in
            Choices.do_action action args;
            load_options queue

let main () =
    load_options (Array.to_list Sys.argv);
    ()

let _ = main ()

