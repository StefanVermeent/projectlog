
test_that("creating a single study folder structure works", {

  current_wd <- getwd()
  path = file.path(tempdir(), "temp-repo") |> gsub(x = _, pattern = "\\\\", replacement = "/")

  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  testthat::local_mocked_bindings(
    use_git = function(...) TRUE, .package = 'usethis'
  )
  testthat::local_mocked_bindings(
    use_github = function(...) "This one connects to github", .package = 'usethis'
  )
  testthat::local_mocked_bindings(
    get_git_url = function(...) "https://github.com/username/repo-name"
  )


  initiate_project(path = path, project = "single_study", preregistration = 'secondary')

  expect_true(file.exists(path))
  expect_true(file.exists(file.path(path, "README.Rmd")))
  expect_true(file.exists(file.path(path, ".projectlog")))
  expect_true(file.exists(file.path(path, ".projectlog", "MD5")))
  expect_true(file.exists(file.path(path, "manuscript", "README.Rmd")))
  expect_true(file.exists(file.path(path, "supplement", "README.Rmd")))
  expect_true(file.exists(file.path(path, "materials", "README.Rmd")))
  expect_true(file.exists(file.path(path, "preregistration", "README.Rmd")))
  expect_true(file.exists(file.path(path, "data")))
  expect_true(file.exists(file.path(path, "scripts")))

  setwd(current_wd)
})


test_that("creating a multistudy folder structure works", {

  current_wd <- getwd()
  path = file.path(tempdir(), "temp-repo")

  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  testthat::local_mocked_bindings(
    use_git = function(...) TRUE, .package = 'usethis'
  )
  testthat::local_mocked_bindings(
    use_github = function(...) "This one connects to github", .package = 'usethis'
  )
  testthat::local_mocked_bindings(
    get_git_url = function(...) "https://github.com/username/repo-name"
  )

  initiate_project(path = path, project = "multistudy", preregistration = 'aspredicted')

  expect_true(file.exists(path))
  expect_true(file.exists(file.path(path, ".projectlog")))
  expect_true(file.exists(file.path(path, ".projectlog", "MD5")))
  expect_true(file.exists(file.path(path, "manuscript", "README.Rmd")))
  expect_true(file.exists(file.path(path, "supplement", "README.Rmd")))
  expect_true(file.exists(file.path(path, "study1", "materials", "README.Rmd")))
  expect_true(file.exists(file.path(path, "study1", "preregistration", "README.Rmd")))
  expect_true(file.exists(file.path(path, "study1", "data")))
  expect_true(file.exists(file.path(path, "study1", "scripts")))

  setwd(current_wd)
})
