let print_if_match pattern filename line =
  let open Core in
  match String.substr_index line ~pattern with
    | Some i -> Printf.printf "%s:%d:%s\n" filename i line
    | None -> ()

module Sync = struct
  let grep pattern filename =
    let open Core in
    In_channel.with_file filename ~f:(fun file ->
      In_channel.iter_lines file ~f:(fun line ->
        match String.substr_index line ~pattern with
          | Some i -> Printf.printf "%s:%d:%s\n" filename i line
          | None -> ()
    ))
end


module Async = struct
  let grep pattern filename =
    let open Core in
    let open Lwt_io in
    let lines = lines_of_file filename in
    Lwt_stream.iter_p (fun line -> 
      match String.substr_index line ~pattern with
        | Some i -> Lwt_io.printf "%s:%d:%s\n" filename i line
        | None -> Lwt.return_unit
    ) lines
end

