test_that("validate_pr works on valid PR", {
    skip_if_offline()

    temp_hub <- fs::path(tempdir(), "valid_sb_hub")
    gert::git_clone(url = "https://github.com/Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
                    path = temp_hub,
                    branch = "pr-valid")

   checks <- validate_pr(hub_path = temp_hub,
                gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
                pr_number = 4,
                skip_submit_window_check = TRUE)

   expect_snapshot(str(checks))
   expect_invisible(suppressMessages(check_for_errors(checks)))
   expect_message(check_for_errors(checks),
                  regexp = "All validation checks have been successful.")

})

test_that("validate_pr works on invalid PR", {
    skip_if_offline()

    temp_hub <- fs::path(tempdir(), "invalid_sb_hub")
    gert::git_clone(url = "https://github.com/Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
                    path = temp_hub,
                    branch = "pr-missing-taskid")

    checks <- validate_pr(hub_path = temp_hub,
                          gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
                          pr_number = 5,
                          skip_submit_window_check = TRUE)

    expect_snapshot(str(checks))

    expect_error(
        suppressMessages(check_for_errors(checks))
    )
})
