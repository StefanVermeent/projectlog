test_that("file validation works", {

  changed_files <- c(
    "README.Rmd",
    "scripts/script1",
    "data/data.csv"
  )




  local_mocked_bindings(
    file_size = function(...) 100
  )




  expect_true(validate_files(files = "README.Rmd", changed_files = c("README.Rmd", "scripts/script1", "data/data.csv")))
  expect_true(validate_files(files = c("README.Rmd", "data"), changed_files = changed_files))
  expect_true(validate_files(files = "README", changed_files = changed_files))

  expect_error(validate_files(files = "readme.Rmd", changed_files = changed_files))
  expect_error(validate_files(files = "data.csv", changed_files = changed_files))
  expect_error(validate_files(files = "Rmd", changed_files = changed_files))
})


test_that("tag validation works", {
  # 1. Tag should not end on a number
  # 2. Tags cannot begin or end with, or contain multiple consecutive / characters.
  # 3. They cannot contain any of the following characters \, ?, ~, ^, :, * , [, @.
  # 4. They cannot contain a space.
  # 5. They cannot end with a . or have two consecutive .. anywhere within them.
  # 6. Tags are not case sensitive.
  expect_error(validate_tag("tag1"))
  expect_error(validate_tag("tag1393"))
  expect_error(validate_tag("/tag"))
  expect_error(validate_tag("tag/"))
  expect_error(validate_tag("tag//tag"))
  expect_error(validate_tag("tag\tag"))
  expect_error(validate_tag("?tag"))
  expect_error(validate_tag("~tag"))
  expect_error(validate_tag("^tag"))
  expect_error(validate_tag(":tag"))
  expect_error(validate_tag("*tag"))
  expect_error(validate_tag("[tag]"))
  expect_error(validate_tag("@tag"))
  expect_error(validate_tag("tag tag"))
  expect_error(validate_tag("tag."))
  expect_error(validate_tag("tag..tag"))

  expect_true(validate_tag("Tag.tag"))
  expect_true(validate_tag("tag/tag"))
  expect_true(validate_tag("123d"))
})
