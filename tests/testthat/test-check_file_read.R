test_that("check_file_read works", {
    hub_path <- system.file("testhubs/simple", package = "hubUtils")

    check_file_read(
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        hub_path = hub_path)


    check_file_read(
        file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv",
        hub_path = hub_path)
})
