(*
 * Copyright (c) 2014-2015 Magnus Skjegstad <magnus@v0.no>
 * Copyright (c) 2015 Heidi Howard <hh360@cam.ac.uk>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

open V1_LWT
open String
open Re
open Lwt

(* Based on mirage-skeleton/xen/static_website+ip code for reading boot parameters *)
type t = (string * string) list

let create () = 
  OS.Xs.make () >>= fun client ->
  OS.Xs.(immediate client (fun x -> read x "vm")) >>= fun vm ->
  OS.Xs.(immediate client (fun x -> read x (vm^"/image/cmdline"))) >>= fun cmd_line ->
  let entries = Re_str.(split (regexp_string " ") cmd_line) in
  return 
  (List.map (fun x ->
        match Re_str.(split (regexp_string "=") x) with 
        | [a;b] -> (a,b)
        | _ -> raise (Failure "malformed boot parameters")) entries)


(* get boot parameter *)
let get t parameter = 
  try 
    Some (List.assoc parameter t)
  with
    Not_found -> None

let get_exn t parameter = List.assoc parameter t