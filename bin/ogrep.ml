open Core

let rec walkdir dir ~f =
  let entries = Sys.readdir dir in
  Array.iter ~f:(fun entry ->
    let path = Filename.concat dir entry in
    let stat = Unix.stat path in
    (match stat.st_kind with
      | S_REG -> f path
      | S_DIR -> walkdir (Filename.concat dir entry) ~f
      | _ -> ()
    )
  ) entries

let grep pattern filename =
  let open Str in
  let open Printf in
  let open In_channel in
  let reg = regexp pattern in
  with_file filename ~f:(fun file ->
    iter_lines file ~f:(fun line ->
      try
        let index = search_forward reg line 0 in
        printf "%s:%d:%s\n" filename index line
      with Caml.Not_found -> ()
    )
  )


let help () =
  printf "Usage: %s <PATTERN> [<FOLDER|FILE>:.]\n" Sys.argv.(0);
  ignore (exit 1);
  ()

let arg_or_help index =
  try Sys.argv.(index)
  with Invalid_argument _ -> help (); ""

let arg_or_default index default =
  try Sys.argv.(index)
  with Invalid_argument _ -> default

let () =
  let pat = arg_or_help 1 in
  let root = arg_or_default 2 "." in
  let open In_channel in
  let open Str in
  let file_patterns filename =
    try with_file filename ~f:(fun file ->
      fold_lines file ~init:[] ~f:(fun acc line -> regexp line :: acc))
      with Sys_error _ -> []
  in
  let strmatch pattern str =
    try ignore (search_forward pattern str 0); true
    with Caml.Not_found -> false in
  let ignore_patterns = file_patterns ".ogrepignore" in
  let include_patterns = file_patterns ".ogrepinclude" in
  let included filename =
    let exception Found in
    try List.iter include_patterns ~f:(fun pattern ->
      if strmatch pattern filename then raise Found); false
    with
      | Found -> true in
  let not_ignored filename =
    List.for_all ignore_patterns ~f:(fun pattern ->
      try ignore (search_forward pattern filename 0); false
      with Caml.Not_found -> true
    ) in
  let grep_included_and_not_ignored filename =
    (if included filename && not_ignored filename then grep pat filename) in
  match Unix.stat root with
    | { st_kind = S_REG; _ } -> grep pat root
    | { st_kind = S_DIR; _ } -> walkdir root ~f:grep_included_and_not_ignored
    | _ -> ()
