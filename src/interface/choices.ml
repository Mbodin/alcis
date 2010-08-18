(* choices.ml *)
(* Handle all the options of the program. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.fr> *)


type arg =
    | Bool of bool


let options = Hashtbl.create 100
let actions = Hashtbl.create 100

let add_boolean_option name default description =
    Hashtbl.add options name (Bool default);
    Hashtbl.add actions ("-" ^ name)
    ((fun () -> Hashtbl.add options name (Bool true)), 0, description);
    Hashtbl.add actions ("-no-" ^ name)
    ((fun () -> Hashtbl.add options name (Bool false)), 0, "Disable the option -" ^ name);
    ()

let get_value name =
    try Hashtbl.find options name with
    | Not_found -> prerr_string
     (Sys.executable_name ^ ": error: I’m afraid that the option “" ^ name ^ "” is unavailable.\n"
    ^ Sys.executable_name ^ ":        This is an internal error and should not have happenned.\n"
    ^ Sys.executable_name ^ ":        Please repport it to Martin BODIN (martin.bodin@ens-lyon.fr).\n");
                    exit 1

let get_boolean name =
    match get_value name with
    | Bool b -> b

let get_nb_arg name =
    try Some (let _, a, _ = Hashtbl.find actions name in a) with
    | Not_found -> None

let list_options () =
    Hashtbl.iter 
    (fun name -> fun (_, _, desc) -> print_string ("\t" ^ name ^ "\t\t" ^ desc))
    actions

let _ = Hashtbl.add actions "-help" ((fun () -> list_options ()), 0, "Display this help and exit")
let _ = Hashtbl.add actions "-h" ((fun () -> list_options ()), 0, "Display this help and exit")

