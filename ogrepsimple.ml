let rec walkdir dirname ~f =
  let open Unix in
  let dir = opendir dirname in
  try
    while true do
      let entry = readdir dir in
      if entry <> "." && entry <> ".." then
        let path = Filename.concat dirname entry in
        let kind = (stat path).st_kind in
        match kind with
          | S_REG -> f path
          | S_DIR -> walkdir path ~f
          | _ -> ()
    done
  with End_of_file -> closedir dir

let () =
  let open Ogreplib.Common.Sync in
  walkdir Sys.argv.(2) ~f:(grep Sys.argv.(1))
