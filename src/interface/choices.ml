(* choices.ml *)
(* Handle all the options of the program. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)


let set_internal_error_function, internal_error, error =
    let no_error_function_given () =
        prerr_string (Sys.executable_name ^ ": An internal error appears: It seems that the file errors.ml does not initialize the errors functions in the file choices.ml.\n"
        ^ Sys.executable_name ^ ": Please repport it to Martin BODIN (martin.bodin@ens-lyon.fr).\n");
        exit 1
    in
    let internal_error_function = ref (fun _ -> ()) in
    let error_function = ref (fun _ -> ()) in
    (fun fintern f -> internal_error_function := fintern; error_function := f),
    (fun a -> !internal_error_function a; no_error_function_given ()),
    (fun a -> !error_function a; no_error_function_given ())


type arg =
    | Bool of bool
    | String of string
    | Input_list of (in_channel * Position.file_type) list


let options = Hashtbl.create 100
let actions = Hashtbl.create 100

let max_size_action_name = ref 0

let add_action name nb_arg arg_descr descr f =
    Hashtbl.add actions name (f, nb_arg, arg_descr, descr);
    max_size_action_name := max !max_size_action_name (List.fold_left (fun i s -> i + 2 + String.length s) (3 + String.length name) arg_descr);
    ()

let add_option name default =
    try let _ = Hashtbl.find options name in internal_error ["The option “" ^ name ^ "” has been declared twice."] with
    | Not_found -> Hashtbl.add options name default

let get_value name =
    try Hashtbl.find options name with
    | Not_found -> internal_error ["The option “" ^ name ^ "” is requested, but does not stand in the available options."]

let set_value name value =
    Hashtbl.add options name value

let set_boolean name b =
    set_value name (Bool b)

let add_boolean_option name default description =
    add_option name (Bool default);
    add_action ("-" ^ name) 0 [] (description ^ (if default then " (default)" else ""))
    (function
        | [] -> set_boolean name true
        | l -> internal_error ["The option “-" ^ name ^ "” requests no argument, but it is called with " ^ (string_of_int (List.length l)) ^ " ones."]
    );
    add_action ("-no-" ^ name) 0 [] ("Disable the option “-" ^ name ^ "”" ^ (if not default then " (default)" else ""))
    (function
        | [] -> set_boolean name false
        | l -> internal_error ["The option “-no-" ^ name ^ "” requests no argument, but it is called with " ^ (string_of_int (List.length l)) ^ " ones."]
    );
    ()

let get_value name =
    try Hashtbl.find options name with
    | Not_found -> internal_error ["I’m afraid that the option “" ^ name ^ "” is unavailable."; "This error was cause while executing the function “Choices.get_value”."]

let get_boolean name =
    match get_value name with
    | Bool b -> b
    | _ -> internal_error ["The option “" ^ name ^ "” seems not to be of boolean type, but a boolean value were requested."]


let get_nb_arg name =
    try Some (let _, a, _, _ = Hashtbl.find actions name in a) with
    | Not_found -> None

let do_action action args =
    let f, n, _, _ =
        try Hashtbl.find actions action with
        | Not_found ->
                internal_error ["The action associated to the option “" ^ action ^ "” is requested to be called, but no such option exists.";
                "For information, there was " ^ (string_of_int (List.length args)) ^ " arguments given to it."]
    in
    if n <> List.length args then
        internal_error ["The action associated to the option “" ^ action ^ "” received " ^ (string_of_int (List.length args)) ^ " arguments, but " ^ (string_of_int n) ^ " where expected."]
    else f args

let usage_option name arg_descr desc =
        let name_plus_arg =
            name ^ " " ^
            (match arg_descr with
            | [] -> ""
            | first :: l -> (List.fold_left (fun a b -> a ^ ", " ^ b) ("<" ^ first) l) ^ ">"
            )
        in
        "\t" ^ name_plus_arg ^ (String.make (!max_size_action_name - String.length name_plus_arg) ' ') ^ "\t\t" ^ desc ^ "\n"

let list_options () =
    print_string ("Usage:\n\t" ^ Sys.executable_name ^ " [options]\n\nHere is the list of the available options:\n");
    List.iter print_string
    (List.sort compare
    (Hashtbl.fold
    (fun name -> fun (_, _, arg_descr, desc) -> fun l ->
    usage_option name arg_descr desc :: l)
    actions []));
    ()

let help_action = function
        | [] -> list_options ()
        | l -> internal_error ["The help action requests no argument, but " ^ (string_of_int (List.length l)) ^ " were given to it.";
                                "I’m very sorry you to read this: you probably obtain it while calling help."]

let _ = add_action "-help" 0 [] "Display this help" help_action

let _ = add_action "-about" 1 ["option"] "Display the usage of the given option"
    (function
        | opt :: [] ->
                let _, _, arg_descr, desc =
                    try Hashtbl.find actions opt with
                    | Not_found -> error ["The argument “" ^ opt ^ "” given to the option “-about” does not correspond to a existing option.";
                                            "The option “-help” can list all the available options."]
                in
                print_string (usage_option opt arg_descr desc)
        | l -> internal_error ["The about option requests one argument, but " ^ (string_of_int (List.length l)) ^ " were given to it.";
                                "I’m very sorry you to read this: you probably obtain it while calling help."])

