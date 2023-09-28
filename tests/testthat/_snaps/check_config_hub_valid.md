# check_config_hub_valid works

    Code
      check_config_hub_valid(hub_path = system.file("testhubs/simple", package = "hubValidations"))
    Output
      <message/check_success>
      Message:
      All hub config files are valid.

---

    Code
      check_config_hub_valid(hub_path = system.file("testhubs/flusight", package = "hubValidations"))
    Output
      <message/check_success>
      Message:
      All hub config files are valid.

---

    Code
      check_config_hub_valid(hub_path = system.file("testhubs/flusight", package = "hubValidations"))
    Output
      <error/check_error>
      Error:
      ! All hub config files must be valid.  Config file "tasks" invalid.

