test_that("check_valid_round_id works", {
    hub_path <- system.file("testhubs/simple", package = "hubUtils")
    hub_con <- hubUtils::connect_hub(hub_path)
    config_tasks <- attr(hub_con, "config_tasks")
    file_path <- "test/file.csv"

    expect_snapshot(
        check_valid_round_id("2022-10-29",
                             config_tasks,
                             file_path)
    )
    expect_snapshot(
        check_valid_round_id("invalid-round_id",
                             config_tasks,
                             file_path)
    )
})
