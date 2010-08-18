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
    ((fun () -> Hashtbl.add options name (Bool true)), description);
    Hashtbl.add actions ("-no-" ^ name)
    ((fun () -> Hashtbl.add options name (Bool false)), "Disable the option -" ^ name);
    ()

let get_value name =
    try Hashtbl.find options name with
    | Not_found -> prerr_string (Sys.executable_name ^ ": error: I’m afraid that the option “" ^ name ^ "” is unavailable.\n"
    ^ Sys.executable_name ^ ":        This is an internal error and should not have happenned.\n"
    ^ Sys.executable_name ^ ":        Please repport it to Martin BODIN (martin.bodin@ens-lyon.fr).\n");
                    exit 1

let get_boolean name =
    match get_value name with
    | Bool b -> b

let list_options () =
    Hashtbl.iter 
    (fun name -> fun (_, desc) -> print_string ("\t" ^ name ^ "\t\t" ^ desc))
    actions

