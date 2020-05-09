(***********************************************************************)
(*                                                                     *)
(* Copyright (c) 2007-present.                                         *)
(* Programming Research Laboratory (ROPAS), Seoul National University. *)
(* All rights reserved.                                                *)
(*                                                                     *)
(* This software is distributed under the term of the BSD license.     *)
(* See the LICENSE file for details.                                   *)
(*                                                                     *)
(***********************************************************************)
(** Vocabularies *)

let (<<<) f g = fun x -> f (g x)
let (>>>) f g = fun x -> g (f x)
let ($>) x f = match x with Some s -> f s | None -> None
let (&>) x f = match x with Some s -> Some (f s) | None -> None
let (@) l1 l2 = BatList.append l1 l2
let id x = x
let flip f = fun y x -> f x y
let cond c f g x = if c then f x else g x
let opt c f x = if c then f x else x
let tuple x = (x, x)

let domof m = BatMap.foldi (fun k _ set -> BatSet.add k set) m BatSet.empty

(** This applies [List.fold_left], but the argument type is the same with
    [PSet.fold].  *)
let list_fold : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
= fun f list init ->
  List.fold_left (flip f) init list

let list_fold2 : ('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> 'c -> 'c
= fun f list1 list2 init ->
  let f' acc a b = f a b acc in
  List.fold_left2 f' init list1 list2

let list_rev : 'a list -> 'a list
= fun l ->
  let rec list_rev_rec l1 l2 =
    match l1 with
    | [] -> l2
    | a :: b -> list_rev_rec b (a :: l2) in
  list_rev_rec l []

let append_opt : 'a option -> 'a list -> 'a list
= fun x l ->
  match x with None -> l | Some x -> x::l
let find_opt : 'a -> ('a, 'b) BatMap.t -> 'b option
= fun k m ->
  try Some (BatMap.find k m) with
  | Not_found -> None

let find_def : 'a -> ('a, 'b) BatMap.t -> 'b -> 'b
= fun k m default ->
  try BatMap.find k m with _ -> default

let link_by_sep sep s acc = if acc = "" then s else acc ^ sep ^ s

let string_of_list ?(first="[") ?(last="]") ?(sep=";") : ('a -> string)
  -> ('a list) -> string
= fun string_of_v list ->
  let add_string_of_v v acc = link_by_sep sep (string_of_v v) acc in
  first ^ list_fold add_string_of_v list "" ^ last

let string_of_set ?(first="{") ?(last="}") ?(sep=",") : ('a -> string)
  -> ('a BatSet.t) -> string
= fun string_of_v set ->
  let add_string_of_v v acc = link_by_sep sep (string_of_v v) acc in
  first ^ BatSet.fold add_string_of_v set "" ^ last

let string_of_map ?(first="{") ?(last="}") ?(sep=",\n") ?(indent="") : ('a -> string)
  -> ('b -> string) -> (('a, 'b) BatMap.t) -> string
= fun string_of_k string_of_v map ->
  let add_string_of_k_v k v acc =
    let str = string_of_k k ^ " -> " ^ string_of_v v in
    link_by_sep (sep^indent) str acc in
  if BatMap.is_empty map then "empty"
  else indent ^ first ^ BatMap.foldi add_string_of_k_v map "" ^ last

let i2s = string_of_int

let list2set l = list_fold BatSet.add l BatSet.empty
let set2list s = BatSet.fold (fun x l -> x::l) s []

let set_union_small_big small big = BatSet.fold BatSet.add small big

(* fixpoint operator for set *)
let rec fix : ('a BatSet.t -> 'a BatSet.t) -> 'a BatSet.t -> 'a BatSet.t 
= fun f init ->
  let next = f init in
    if BatSet.subset next init then init
    else fix f next

(****************************************)
(*** End of Implementation from ROPAS ***)
(****************************************)

let remove_some : 'a option -> 'a
= fun x ->
  match x with
  | Some x -> x
  | None -> assert false

let rec combination k lst =
  if k<0 then raise (Failure "combination: invalid input") else
  if k=0 then [[]]
  else
    (match lst with
     | [] -> []
     | h::tl ->
       let with_h = List.map (fun l -> h::l) (combination (k-1) tl) in
       let without_h = combination k tl in
       with_h @ without_h)
                                                                                   
let rec combination_from_to i k lst = (* by default, starts from 1 *)
  if i<=0 then raise (Failure "combination_from_to: invalid input") else
  if i>k then []
  else (combination i lst) @ (combination_from_to (i+1) k lst)

(* Source: http://typeocaml.com/2015/05/05/permutation/ *)
let ins_all_positions x l =
  let rec aux prev acc = function
    | [] -> (prev @ [x]) :: acc |> List.rev
    | hd::tl as l -> aux (prev @ [hd]) ((prev @ [x] @ l) :: acc) tl
  in
  aux [] [] l

(* Source: http://typeocaml.com/2015/05/05/permutation/ *)
let rec permutations = function
  | [] -> []
  | x::[] -> [[x]] (* we must specify this edge case *)
  | x::xs -> List.fold_left (fun acc p -> acc @ ins_all_positions x p ) [] (permutations xs)

let k_permutation k lst =
  let llst = combination k lst in
  List.fold_left (fun acc lst' ->
    permutations lst' @ acc
  ) [] llst

let rec permutation_from_to i k lst =
  if i<=0 then raise (Failure "permutation_from_to: invalid input") else
  if i>k then [] 
  else (k_permutation i lst) @ (permutation_from_to (i+1) k lst)

let rec n_cart n lst llst =
  let _ = assert (n>=0) in
  if n=0 then BatList.n_cartesian_product llst
  else n_cart (n-1) lst (lst::llst)

let n_cartesian n lst = n_cart n lst []

let rec adjacent_pairs lst =
  match lst with
  | h1::h2::t -> (h1,h2)::(adjacent_pairs (h2::t))
  | _ -> []

let triple_fst (a,b,c) = a
let triple_snd (a,b,c) = b
let triple_third (a,b,c) = c

let zfill num str =
  let to_fill = num - (String.length str) in
  if to_fill <= 0 then str
  else (String.make to_fill '0') ^ str
