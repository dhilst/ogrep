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


let () =
  let pat = Sys.argv.(1) in
  let open In_channel in
  let open Str in
  let ign_patterns =
    try with_file ".ogrepignore" ~f:(fun file ->
      fold_lines file ~init:[] ~f:(fun acc line -> regexp line :: acc))
      with Sys_error _ -> []
  in
  let not_ignored filename =
    List.for_all ign_patterns ~f:(fun pattern ->
      try ignore (search_forward pattern filename 0); false
      with Caml.Not_found -> true
    ) in
  walkdir "." ~f:(fun filename ->
    if not_ignored filename then grep pat filename
  )
