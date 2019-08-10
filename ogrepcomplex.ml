let rec walkdir dirname ~(f : string -> unit) : unit Lwt.t =
  let open Lwt in
  let open Lwt_unix in
  let n = 200 in
  let dirs_stream, dirs_push = Lwt_stream.create () in
  let%lwt dir = opendir dirname in
  try%lwt
    while%lwt true do
      let%lwt entries = readdir_n dir n in
      let entries_stream = Lwt_stream.of_array entries in
      let%lwt () =
        Lwt_stream.iter_p (function
          | "." | ".." -> return_unit
          | entry -> let path = Filename.concat dirname entry in begin
            match%lwt stat path with
                | { st_kind = S_REG; _ } -> Lwt_preemptive.detach f path
                | { st_kind = S_DIR; _ } -> dirs_push (Some path) |> return
                |  _ -> return_unit
          end
        ) entries_stream in
        if Array.length entries < n then
          let () = dirs_push None in
          let%lwt () = Lwt.fail End_of_file in return_unit
        else return_unit
    done
  with End_of_file -> begin
    let%lwt () = closedir dir in
    Lwt_stream.iter_p (fun dir -> walkdir dir ~f) dirs_stream
  end

let () =
  let open Ogreplib.Common.Sync in
  Lwt_main.run begin
    walkdir Sys.argv.(2) ~f:(grep Sys.argv.(1))
  end

