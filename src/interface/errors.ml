(* errors.ml *)
(* Functions to handle errors and a list of booleans that describe what to do if there is one. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)

let prmesg file premesg = function
    | [] -> prerr_string file; prerr_string premesg; prerr_string "<no error message ! (shouldn’t happen)>\n"
    | first :: l -> prerr_string file; prerr_string premesg; prerr_string first;
                    List.iter (fun m -> prerr_string file; prerr_string (String.make (String.length premesg) ' '); prerr_string m; prerr_newline ()) l

let error mesg =
    prmesg Sys.executable_name ": error: " mesg;
    exit 1

let warn mesg =
    prmesg Sys.executable_name ": warning: " mesg

let internal_error () =
    error ["I’m really sorry, this is an internal error and should not have happens"; "Please repport it."]



let define_warning name default descr =
    Choices.add_boolean_option ("W" ^ name) default descr;
    ()

let get_warning name =
    match Choices.get_value ("W" ^ name) with
    | Choices.Bool b -> b

