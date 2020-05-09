open Lang
open Translator
open Vocab
open Options

let mk_file_without_pragma tmpfname =
  let lines = BatFile.lines_of !Options.inputfile in
  (* let lines = BatEnum.map (fun s -> if BatString.starts_with s "pragma" then "" else s) lines in *)
  BatFile.write_lines tmpfname lines

(* Default solc: v.0.4.26 *)
let compile sol tmp jname =
  let solc =
    (* 0.4.11 does not support compact json option. *)
    if !Options.solc_ver = "0.4.16" then "solc_0.4.16" else
    if !Options.solc_ver = "0.4.17" then "solc_0.4.17" else
    if !Options.solc_ver = "0.4.18" then "solc_0.4.18" else
    if !Options.solc_ver = "0.4.19" then "solc_0.4.19" else
    if !Options.solc_ver = "0.4.20" then "solc_0.4.20" else
    if !Options.solc_ver = "0.4.21" then "solc_0.4.21" else
    if !Options.solc_ver = "0.4.23" then "solc_0.4.23" else
    if !Options.solc_ver = "0.4.24" then "solc_0.4.24" else
    if !Options.solc_ver = "0.4.25" then "solc_0.4.25" else
    if !Options.solc_ver = "0.4.26" then "solc_0.4.26" else
    if BatString.starts_with !Options.solc_ver "0.4" then "solc" else
    if !Options.solc_ver = "0.5.0" then "solc_0.5.1" else (* solc_0.5.0 --ast-compact-json produces a solc error. *)
    if !Options.solc_ver = "0.5.1" then "solc_0.5.1" else
    if !Options.solc_ver = "0.5.2" then "solc_0.5.2" else
    if !Options.solc_ver = "0.5.3" then "solc_0.5.3" else
    if !Options.solc_ver = "0.5.4" then "solc_0.5.4" else
    if !Options.solc_ver = "0.5.5" then "solc_0.5.5" else
    if !Options.solc_ver = "0.5.6" then "solc_0.5.6" else
    if !Options.solc_ver = "0.5.7" then "solc_0.5.7" else
    if !Options.solc_ver = "0.5.8" then "solc_0.5.8" else
    if !Options.solc_ver = "0.5.9" then "solc_0.5.9" else
    if !Options.solc_ver = "0.5.10" then "solc_0.5.10" else
    if !Options.solc_ver = "0.5.11" then "solc_0.5.11" else
    if !Options.solc_ver = "0.5.12" then "solc_0.5.12" else
    if !Options.solc_ver = "0.5.13" then "solc_0.5.13"
    else failwith "Unsupported Solidity Compiler" in
  let exit = Sys.command (solc ^ " " ^ "--ast-compact-json " ^ sol ^ "> " ^ tmp) in
  if exit = 0 then
    tmp |> BatFile.lines_of |> BatEnum.skip 4 |> BatFile.write_lines jname
  else
    let _ = Sys.command ("rm " ^ sol) in
    let _ = Sys.command ("rm " ^ tmp) in
    failwith ("Compilation Failed : " ^ !Options.solc_ver)

let set_default_inline_depth () =
  if !Options.inline_depth < 0 then
    if !Options.exploit then Options.inline_depth := 3
    else Options.inline_depth := 2
  else ()

let prepare () =
  let _ = set_default_inline_depth () in
  let (success,sol) = BatString.replace (Filename.basename !inputfile) ".sol" "_tmp.sol" in
  let _ = assert success in
  let _ = mk_file_without_pragma sol in
  let (success,tmp) = BatString.replace sol ".sol" "" in
  let (success,jname) = BatString.replace sol ".sol" ".json" in
  let _ = assert success in
  let _ = compile sol tmp jname in
  let json = Yojson.Basic.from_file jname in
  let _ = Sys.command ("rm " ^ sol) in
  let _ = Sys.command ("rm " ^ tmp) in
  let _ = Sys.command ("rm " ^ jname) in
  let lines = BatList.of_enum (BatFile.lines_of !inputfile) in
  let (_,lst) = (* store cumulative byte size at the end of each line *) 
    List.fold_left (fun (acc_eol,acc_lst) cur ->
      let eol = Bytes.length (Bytes.of_string cur) + 1 in
      let acc_eol' = eol + acc_eol in
      (acc_eol', acc_lst @ [acc_eol'])
    ) (0,[]) lines in
  let _ = end_of_lines := lst in
  let pgm = Translator.run json in
  let _ = main_contract := get_cname (get_main_contract pgm) in
  let pgm = Preprocess.run pgm in
  let pgm = MakeCfg.run pgm in
  let pgm = Inline.run pgm in (* inlining is performed on top of an initial cfg. *)
  let pgm = CallGraph.remove_unreachable_funcs pgm in
  (pgm, lines)

let main () =
  let (pgm,lines) = prepare () in
  if !Options.il then
    print_endline (to_string_pgm pgm) else
  if !Options.cfg then
    print_endline (to_string_cfg_p pgm)

let _ =
  let usageMsg = "./main.native -input filename" in
  Arg.parse options activate_detector usageMsg;
  activate_default_detector_if_unspecified ();
  print_detector_activation_status ();
  Printexc.record_backtrace true;
  try main ()
  with exc -> prerr_endline (Printexc.to_string exc); prerr_endline (Printexc.get_backtrace())
