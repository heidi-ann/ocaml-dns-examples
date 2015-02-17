open Lwt
open V1_LWT

module Client (C:CONSOLE) (S:STACKV4) = struct

  module U = S.UDPV4
  module DNS = Dns_resolver_mirage.Make(OS.Time)(S)

  open Dns.Packet
  open Dns.Name

  let start c s =
    Bootvar.create () >>= fun bootvar ->
    let domain = Bootvar.get_exn bootvar "domain" in
    let server = Ipaddr.V4.of_string_exn (Bootvar.get_exn bootvar "server") in
    let t = DNS.create s in
    OS.Time.sleep 2.0 
    >>= fun () ->
    C.log_s c ("Resolving " ^ domain)
    >>= fun () ->
    DNS.resolve (module Dns.Protocol.Client) t server 53 Q_ANY_CLS Q_A [domain]
    >>= fun r ->
    List.fold_left r.answers ~f:(fun a x ->
      match x.rdata with
      | A ip -> (Ipaddr.V4 ip) :: a
      | _ -> a ) ~init:[] 
    >>= fun rl ->
    Lwt_list.iter_s
      (fun r ->
         C.log_s c ("Answer " ^ (Ipaddr.to_string r))
      ) rl

end