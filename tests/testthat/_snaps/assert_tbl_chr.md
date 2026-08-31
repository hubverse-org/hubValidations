# assert_tbl_chr reports the columns that are not character

    Code
      assert_tbl_chr(tbl)
    Condition
      Error:
      ! Every column of `tbl_chr` must be character.
      x Columns "origin_date", "horizon", and "value" are of type "Date", "integer", and "double".
      i Use `read_model_out_file(coerce_types = "chr")` to read a submission as character.

---

    Code
      assert_tbl_chr(tbl["horizon"])
    Condition
      Error:
      ! Every column of `tbl_chr` must be character.
      x Column "horizon" is of type "integer".
      i Use `read_model_out_file(coerce_types = "chr")` to read a submission as character.

