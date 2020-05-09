let inputfile = ref ""
let il = ref false
let cfg = ref false
let main_contract = ref ""
let alarm_details = ref false
let exp_mode = ref false
let intra = ref false
let csv = ref false
let debug = ref ""
let bit = ref 0
let inline_depth = ref (-1)

let solc_ver = ref "0.4"

let verify_io = ref false 
let verify_dz = ref false
let verify_tod = ref false 
let verify_blk = ref false
let verify_re = ref false
let verify_urv = ref false
let verify_acc = ref false
let verify_assert = ref false

(* exploit generation *)
let exploit = ref false
let exploit_all = ref false
let exploit_io = ref false
let exploit_dz = ref false
let exploit_assert = ref false
let exploit_erc20 = ref false
let exploit_erc721 = ref false
let exploit_leak = ref false
let exploit_suicide = ref false

let transaction_depth = ref 1000000000000000 (* maximum transaction depth other than initial transaction (i.e., constructor call) *)
let ngram = ref 0

(* timeout options *)
let verify_timeout = ref 10
let z3timeout = ref 0
let exploit_global_timeout = ref 600 (* default: 10 minutes *)

let validate = ref false

let activate_detector s =
  match s with
  | "io" -> verify_io:=true
  | "dz" -> verify_dz:=true
  | "tod" -> verify_tod:=true
  | "blk" -> verify_blk:=true
  | "re" -> verify_re:=true
  | "urv" -> verify_urv:=true
  | "acc" -> verify_acc:=true
  | "assertion" -> verify_assert:=true
  | _ -> invalid_arg "invalid option in specifying bug types"

let activate_default_detector_if_unspecified () =
  let b = !verify_io || !verify_dz || !verify_tod || !verify_blk || !verify_re || !verify_urv || !verify_acc || !verify_assert in
  if b=false && not !exploit then (verify_io:=true; verify_dz:=true)
  else ()

let print_detector_activation_status () =
  if !verify_io then prerr_endline  "ON: integer over/underflow";
  if !verify_dz then prerr_endline  "ON: division-by-zero";
  if !verify_tod then prerr_endline "ON: transaction-ordering dependence";
  if !verify_blk then prerr_endline "ON: block-information dependence";
  if !verify_re then prerr_endline  "ON: re-entrancy";
  if !verify_urv then prerr_endline "ON: unchecked return value";
  if !verify_acc then prerr_endline "ON: access control";
  if !verify_assert then prerr_endline "ON: assertion";
  prerr_endline ""

let options =
  [
    ("-input", (Arg.String (fun s -> inputfile := s)), "inputfile containing your examples");
    ("-il", (Arg.Set il), "show intermediate representations of original program");
    ("-cfg", (Arg.Set cfg), "show control flow graph"); 
    ("-verify_timeout", (Arg.Int (fun n -> verify_timeout:=n)), "timebudget for verification mode");
    ("-exploit_timeout", (Arg.Int (fun n -> exploit_global_timeout:=n)), "timebudget for exploit generation mode");
    ("-z3timeout", (Arg.Int (fun n -> z3timeout:=n)), "z3 timebudget in miliseconds");
    ("-alarm_details", (Arg.Set alarm_details), "inspect unproved queries in IL code");
    ("-exp", (Arg.Set exp_mode), "produce summary file for experiments");
    ("-intra", (Arg.Set intra), "verify intra-transactionally");
    ("-ex_all", Arg.Unit (fun () -> exploit:=true; exploit_all:=true), "generate exploits for all supported safety properties");
    ("-ex_io", Arg.Unit (fun () -> exploit:=true; exploit_io:=true), "generate exploits for integer overflows");
    ("-ex_dz", Arg.Unit (fun () -> exploit:=true; exploit_dz:=true), "generate exploits for division-by-zeros");
    ("-ex_assert", Arg.Unit (fun () -> exploit:=true; exploit_assert:=true), "generate exploits for user-provided assertions");
    ("-ex_erc20", Arg.Unit (fun () -> exploit:=true; exploit_erc20:=true), "generate exploits for erc20 standard");
    ("-ex_erc721", Arg.Unit (fun () -> exploit:=true; exploit_erc721:=true), "generate exploits for erc721 standard");
    ("-ex_leak", Arg.Unit (fun () -> exploit:=true; exploit_leak:=true), "generate exploits for finding contracts whose ethers are leaked");
    ("-ex_suicide", Arg.Unit (fun () -> exploit:=true; exploit_suicide:=true), "generate exploits for finding suicidal");
    ("-tdepth", Arg.Int (fun n -> transaction_depth:=n), "maximum transaction depth other than initial transaction (constructor call)");
    ("-csv", (Arg.Set csv), "output analysis report in csv format");
    ("-main", (Arg.String (fun s -> main_contract := s)), "name of main contract to be deployed");
    ("-debug", (Arg.String (fun s -> debug := s)), "debugging certain parts; not for public");
    ("-bit", Arg.Int (fun n -> bit := n), "restrict the number of bits for 256-bit expressions");
    ("-ngram", Arg.Int (fun n -> assert (n>0); ngram := n), "set 'n' for n-gram");
    ("-solc", Arg.String (fun s -> solc_ver := s), "specify solidity compiler version, e.g., 0.5.13");
    ("-inline_depth", Arg.Int (fun n -> inline_depth := n), "the number of times being iinlined");
    ("-validate", (Arg.Set validate), "run concrete validator after the analysis is done.");
  ]
