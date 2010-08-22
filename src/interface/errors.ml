(* errors.ml *)
(* Functions to handle errors and a list of booleans that describe what to do if there is one. *)
(* author: Martin BODIN <martin.bodin@ens-lyon.org> *)


let define_warning name default descr =
    Choices.add_boolean_option ("W" ^ name) default descr

let get_warning name =
    Choices.get_boolean ("W" ^ name)


let internal errorfun mesg =
    errorfun 
    ("I’m really sorry, this is an internal error and should not have happenned."
    :: "Please repport it to Martin BODIN (martin.bodin@ens-lyon.fr)."
    :: "There follows a description of the error:" :: mesg)

let rec prmesg file premesg = function
    | [] -> internal (prmesg (Sys.executable_name ^ ": ") "error: ")
            ["No error message given to prmseg in file error.ml."]
    | first :: l -> prerr_string file; prerr_string premesg; prerr_string first; prerr_newline ();
                    List.iter (fun m -> prerr_string file; prerr_string (String.make (String.length premesg) ' '); prerr_string m; prerr_newline ()) l

let error pos mesg =
    prmesg (Position.get_filename pos ^ ": ") (Position.infile_to_string pos ^ "error: ") mesg;
    exit 1

let warn pos mesg =
    if get_warning "error" then error pos mesg
    else prmesg (Position.get_filename pos ^ ": ") (Position.infile_to_string pos ^ "warning: ") mesg

let internal_warning mesg =
    internal ((if Choices.get_boolean "failure-stop" then error else warn) Position.global) mesg;
    ()

let internal_error mesg =
    internal (error Position.global) mesg

let _ = Choices.set_internal_error_function internal_error error

let _ = Choices.add_boolean_option "failure-stop" true "Stop the program at any internal error, even if it seems it could be ignored"
let _ = define_warning "error" false "Transforms all warnings to errors"

