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
  let reg = regexp pattern in
  In_channel.with_file filename ~f:(fun file ->
    let lines = In_channel.input_lines file in
    let string_match_reg line = (string_match reg line 0) in
    List.iter lines ~f:(fun line ->
      if string_match_reg line
      then printf "%s:%s\n" filename line
    )
  )

let () =
  let pat = Sys.argv.(1) in
  walkdir "." ~f:(grep pat)
