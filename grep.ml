let rec walkdir dir ~f =
  let open Printf in
  let entries = Sys.readdir dir in
  Array.iter (fun entry ->
    let path = Filename.concat dir entry in
    let stat = Unix.stat path in
    (match stat.st_kind with
      | S_REG -> f path
      | S_DIR -> walkdir (Filename.concat dir entry) ~f
      | _ -> ()
    )
  ) entries

let grep pattern filename =
  let open In_channel in
  with_file finename ~f:(fun file ->
    let lines = input_lines in
    List.iter lines (fun line ->
      let open Str in
      let open Printf in
      let reg = regexp pattern in
      if string_match reg line 0
      then printf "%s:%s\n" finename line
    )
  )

let () =
  walkdir "." (grep Sys.argv(1))
