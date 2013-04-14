open Common

module H = Eliom_content.Html5.D

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(*****************************************************************************)
(* App *)
(*****************************************************************************)
module App = Eliom_registration.App (struct let application_name = "app" end)

(*****************************************************************************)
(* Shared *)
(*****************************************************************************)

{shared{
let width = 1200
let height = 680
module Model = Model_codemap
}}

(*****************************************************************************)
(* Main entry point *)
(*****************************************************************************)
let main_service =
  App.register_service 
    ~path:["codemap"] 
    ~get_params:(Eliom_parameter.string "path")
  (fun path () ->
    pr2 path;

    (* TODO: compute config based on path and depending
     * on some OCaml pfff repo type.
     *)
    let rects = Globals.rects in
    (* let rects = Server_codemap.treemap_generator [path] in *)
    let rects = Server_codemap.optimize_rects rects in

    let w = { Model.
       rects;
       width = width;
       height = height;

       orig_coord_width = 0.;
       orig_coord_height = 0.;
       width_text_etalon_normalized_coord = 0.;
    }
    in

    ignore
      {unit { Client_codemap.paint %w }};
    Lwt.return
      (H.html 
          (H.head (H.title (H.pcdata "Codemap")) [ 
          ])
	  (H.body [
            H.div ~a:[H.a_id "output";] [];
            H.canvas 
              ~a:[H.a_id "main_canvas"; H.a_width width; H.a_height height] [];
          ]))
  )

(*****************************************************************************)
(* Testing *)
(*****************************************************************************)

let test_codemap_micro =
  App.register_service 
    ~path:["test_micro"] 
    ~get_params:(Eliom_parameter.unit)
  (fun () () ->

    let rects = [] in
    let w = { Model.
       rects;

       width = width;
       height = height;
       orig_coord_width = 0.;
       orig_coord_height = 0.;
       width_text_etalon_normalized_coord = 0.;
    }
    in
    let file = 
      (* "/home/pad/pfff/Makefile" *)
      (*"/home/pad/pfff/facebook/tests/mini_www/flib/cmf/check_module/test.php"*)
      "/home/pad/pfff/main.ml"
    in
    let fileinfo = Server_codemap.fileinfo_of_file file in

    ignore
      {unit{ Client_codemap.test_paint_micro %w %fileinfo }};
    Lwt.return
      (H.html 
          (H.head (H.title (H.pcdata "Micro")) [ 
          ])
	  (H.body [
            H.div 
              ~a:[H.a_id "output";] [];
            H.canvas 
              ~a:[H.a_id "main_canvas"; H.a_width width; H.a_height height] [];

          ]))
  )
