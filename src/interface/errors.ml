(* errors.ml *)
(* Functions to handle errors and a list of booleans that describe what to do if there is one. *)
(* author : Martin BODIN <martin.bodin@ens-lyon.org> *)

let prmesg file premesg = function
    | [] -> prerr_string file; prerr_string premesg; prerr_string "<no error message ! (shouldn’t happen)>"
    | first :: l -> prerr_string file; prerr_string premesg; prerr_string first;
                    List.iter (fun m -> prerr_string file; prerr_string (String.make (String.length premesg) ' '); prerr_string m) l

let error mesg =
    prmesg Sys.executable_name ": error: " mesg;
    exit 1

let warn mesg =
    prmesg Sys.executable_name ": warning: " mesg

let internal_error () =
    error ["I’m really sorry, this is an internal error and should not have happens"; "Please repport it."]



let warnings = Hashtbl.create 42

let define_warning name default =
    Hashtbl.add warnings name default;
    ()

let get_warning name =
    Hashtbl.find warnings name

