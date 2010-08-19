(* choices.ml *)
(* Handle all the options of the program. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)


let set_internal_error_function, internal_error =
    let internal_error_function = ref (fun _ -> ()) in
    (fun f -> internal_error_function := f),
    fun a -> !internal_error_function a; exit 1

type arg =
    | Bool of bool


let options = Hashtbl.create 100
let actions = Hashtbl.create 100

let max_size_action_name = ref 0

let add_action name nb_arg arg_descr descr f =
    Hashtbl.add actions name (f, nb_arg, arg_descr, descr);
    max_size_action_name := max !max_size_action_name (String.length name);
    ()

let add_boolean_option name default description =
    Hashtbl.add options name (Bool default);
    add_action ("-" ^ name) 0 [] description
    (function
        | [] -> Hashtbl.add options name (Bool true)
        | l -> internal_error ["The option “-" ^ name ^ "” requests no argument, but it is called with " ^ (string_of_int (List.length l)) ^ " ones."]
    );
    add_action ("-no-" ^ name) 0 [] description
    (function
        | [] -> Hashtbl.add options name (Bool false)
        | l -> internal_error ["The option “-no-" ^ name ^ "” requests no argument, but it is called with " ^ (string_of_int (List.length l)) ^ " ones."]
    );
    ()

let get_value name =
    try Hashtbl.find options name with
    | Not_found -> internal_error ["I’m afraid that the option “" ^ name ^ "” is unavailable."; "This error was cause while executing the function “Choices.get_value”."]

let get_boolean name =
    match get_value name with
    | Bool b -> b


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

let list_options () =
    print_string ("Usage:\n\t" ^ Sys.executable_name ^ " [options]\n\nHere is the list of the available options:\n");
    List.iter print_string
    (List.sort compare
    (Hashtbl.fold
    (fun name -> fun (_, _, arg_descr, desc) -> fun l ->
        ("\t" ^ name ^ (String.make (!max_size_action_name - String.length name) ' ') ^ " " ^
        (match arg_descr with
        | [] -> ""
        | first :: l -> (List.fold_left (fun a b -> a ^ ", " ^ b) ("<" ^ first) l) ^ ">"
        ) ^ "\t\t" ^ desc ^ "\n") :: l)
    actions []));
    ()

let help_action = function
        | [] -> list_options ()
        | l -> internal_error ["The help action requests no argument, but " ^ (string_of_int (List.length l)) ^ " were given to it.";
                                "I’m very sorry you to read this: you probably obtain it while calling help."]

let _ = add_action "-help" 0 [] "Display this help" help_action
let _ = add_action "-h" 0 [] "Display this help" help_action

