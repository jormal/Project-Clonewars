let inputfile = ref ""
let outputfile = ref ""
let cfg = ref false
let verbose = ref false
let main_contract = ref ""
let inline_depth = ref (-1)

let solc_ver = ref "0.4"

let activate_detector s =
  match s with
  | _ -> invalid_arg "invalid option in specifying bug types"

let options =
  [
    ("-input", (Arg.String (fun s -> inputfile := s)), "File path for input solidity program.");
    ("-output", (Arg.String (fun s -> outputfile := s)), "File path for translation output of intermediate representation.");
    ("-cfg", (Arg.Set cfg), "File path for print out control flow graph."); 
    ("-main", (Arg.String (fun s -> main_contract := s)), "Name of main contract to be deployed.");
    ("-solc", Arg.String (fun s -> solc_ver := s), "Version of specified solidity compiler. (e.g., 0.5.13)");
    ("-inline_depth", Arg.Int (fun n -> inline_depth := n), "Number of times being inlined.");
    ("-verbose", (Arg.Set verbose), "Print with verbose mode.")
  ]
