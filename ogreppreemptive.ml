let rec walkdir dirname ~f =
  let open Lwt_unix in
  let%lwt dir = opendir dirname in
  try%lwt
    while%lwt true do
      let%lwt entry = readdir dir in
      if entry <> "." && entry <> ".." then
        let path = Filename.concat dirname entry in
        let%lwt s = stat path in
        let kind = s.st_kind in
        match kind with
          | S_REG -> Lwt_preemptive.detach f path
          | S_DIR -> walkdir path ~f
          | _ -> Lwt.return_unit
      else Lwt.return_unit
    done
  with End_of_file -> closedir dir

let () =
  let open Ogreplib.Common.Sync in
  Lwt_main.run begin
    walkdir Sys.argv.(2) ~f:(grep Sys.argv.(1))
  end
