open OUnit2

let () =
  run_test_tt_main
    ("scaffold" >:::
      [
        Test_util.tests;
        Test_naming.tests;
        Test_err.tests;
        Test_json.tests;
        Test_lang.tests;
        Test_langs.tests;
        Test_template.tests;
        Test_catalog.tests;
        Test_collision.tests;
        Test_params.tests;
        Test_session.tests;
        Test_insert.tests;
        Test_engine.tests;
        Test_cli.tests;
      ])
