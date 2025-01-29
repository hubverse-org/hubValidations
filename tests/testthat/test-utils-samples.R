test_that("spl_hash_tbl for compiling sample properties works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  tbl_spl <- tbl[tbl$output_type == "sample", ]
  config_tasks <- read_config(hub_path)

  hash_tbl <- spl_hash_tbl(tbl, round_id, config_tasks)

  expect_s3_class(hash_tbl, "tbl_df")
  # Check that the sample output_type_ids in the original tbl match those in
  # the hash_tbl
  expect_equal(
    sort(unique(tbl_spl$output_type_id)),
    sort(unique(hash_tbl$output_type_id))
  )
  # Check that all samples correspond to a single compound_idx
  expect_equal(unique(hash_tbl$n_compound_idx), 1L)
  # Check that the non_compound_taskid_set hash is unique across all samples
  non_compound_taskid_hash <- unique(hash_tbl$hash_non_comp_tid)
  expect_equal(length(non_compound_taskid_hash), 1L)
  # Check that the compound_idx values are as expected
  expect_equal(
    sort(unique(hash_tbl$compound_idx)),
    c("1", "2", "3", "4", "5")
  )

  # Test that the function detects inconsistencies in a
  # compound_taskid_set var ----
  spl_1_ctid <- tbl_spl[tbl_spl$output_type_id == "1", ]
  # Introduce inconsistency in compound_task_id variable `location` of sample 1
  spl_1_ctid$location[1] <- "02"

  spl_1_ctid_hash_tbl <- spl_hash_tbl(spl_1_ctid, round_id, config_tasks)
  # The sample now has rows that correspond to two different compound_idxs
  expect_equal(spl_1_ctid_hash_tbl$n_compound_idx, 2L)
  # However, the most frequent compound_idx is still the same as before,
  # hence the sample is still assigned to that compound_idx
  expect_equal(spl_1_ctid_hash_tbl$compound_idx, "2")
  # The non_compound_taskid_set hash is still the same as that determined for
  # samples above
  expect_equal(non_compound_taskid_hash, spl_1_ctid_hash_tbl$hash_non_comp_tid)


  # Test that the function detects inconsistencies in a
  # non_compound_taskid_set var ----
  spl_1_nctid <- tbl_spl[tbl_spl$output_type_id == "1", ]
  # Introduce inconsistency in non_compound_task_id variable `horizon` of sample 1
  spl_1_nctid$horizon[1] <- "1"
  spl_1_nctid_hash_tbl <- spl_hash_tbl(spl_1_nctid, round_id, config_tasks)
  expect_false(spl_1_nctid_hash_tbl$hash_non_comp_tid == non_compound_taskid_hash)
  # The sample still only correponds to a single compound_idx
  expect_equal(spl_1_nctid_hash_tbl$n_compound_idx, 1L)
  # The most frequent compound_idx is still the same as before
  expect_equal(spl_1_nctid_hash_tbl$compound_idx, "2")


  # Check that function returns zero row and column dataframes when tbl
  # contains no samples ----
  no_spl_hash <- spl_hash_tbl(
    tbl[tbl$output_type != "sample", ],
    round_id, config_tasks
  )
  expect_equal(nrow(no_spl_hash), 0L)
  expect_equal(ncol(no_spl_hash), 0L)
})
