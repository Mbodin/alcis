(* choices.ml *)
(* Handle all the options of the program. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)


let set_internal_error_function, internal_error = (* For typing problems, I’m afraid I’m forced to take a default answer in argument. *)
    let default = fun a _ -> a in
    let internal_error_function = ref default in
    (fun f -> internal_error_function := (fun a b -> f b; a)),
    fun a -> (!internal_error_function a)

type arg =
    | Bool of bool


let options = Hashtbl.create 100
let actions = Hashtbl.create 100

let add_boolean_option name default description =
    Hashtbl.add options name (Bool default);
    Hashtbl.add actions ("-" ^ name)
    ((function
        | [] -> Hashtbl.add options name (Bool true)
        | l -> internal_error () ["The option “-" ^ name ^ "” requests no argument, but it is called with " ^ (string_of_int (List.length l)) ^ " ones."]
    ), 0, description);
    Hashtbl.add actions ("-no-" ^ name)
    ((function
        | [] -> Hashtbl.add options name (Bool false)
        | l -> internal_error () ["The option “-no-" ^ name ^ "” requests no argument, but it is called with " ^ (string_of_int (List.length l)) ^ " ones."]
    ), 0, "Disable the option -" ^ name);
    ()

let get_value name =
    try Hashtbl.find options name with
    | Not_found -> prerr_string
     (Sys.executable_name ^ ": error: I’m afraid that the option “" ^ name ^ "” is unavailable.\n"
    ^ Sys.executable_name ^ ":        This is an internal error and should not have happenned.\n"
    ^ Sys.executable_name ^ ":        Please repport it to Martin BODIN (martin.bodin@ens-lyon.fr).\n"); (* FIXME *)
                    exit 1

let get_boolean name =
    match get_value name with
    | Bool b -> b


let get_nb_arg name =
    try Some (let _, a, _ = Hashtbl.find actions name in a) with
    | Not_found -> None

let do_action action args =
    let f, n, _ =
        try Hashtbl.find actions action with
        | Not_found ->
                let default = (fun _ -> ()), 0, "" in (* FIXME *)
                internal_error default ["The action associated to the option “" ^ action ^ "” is requested to be called, but no such option exists.";
                "For information, there was too " ^ (string_of_int (List.length args)) ^ " argument given to it."]
    in
    if n <> List.length args then
        internal_error () ["The action associated to the option “" ^ action ^ "” received " ^ (string_of_int (List.length args)) ^ " arguments, but " (string_of_int n) ^ " where expected."]
    else f args

let list_options () =
    Hashtbl.iter 
    (fun name -> fun (_, _, desc) -> print_string ("\t" ^ name ^ "\t\t" ^ desc ^ "\n"))
    actions

let help_action =
    ((function
        | [] -> list_options ()
        | _ -> internal_error () ["There was at least an argument given to the help action." :: "I’m very sorry you to read this: you probably obtain it while calling help."]
    ), 0, "Display this help")

let _ = Hashtbl.add actions "-help" help_action
let _ = Hashtbl.add actions "-h" help_action

