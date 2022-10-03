.old_wd <- setwd(tempdir())

latent <- list(visual = paste0("x", 1:3),
               textual = paste0("x", 4:6),
               speed = paste0("x", 7:9))

regression <- list(ageyr = c("visual", "textual", "speed"),
                   grade = c("visual", "textual", "speed"))

HS.model <- write_lavaan(latent = latent, regression = regression)

library(lavaan)
fit <- sem(HS.model, data = HolzingerSwineford1939)
nice.table <- nice_fit(fit, nice_table = TRUE)

#   ____________________________________________________________________________
#   Tests                                                                   ####

test_that("nice_fit save for Word", {
  skip_on_cran()
  expect_silent(
    save_as_docx(nice.table, path = "table.docx")
  )
})

test_that("nice_fit save for PPT", {
  skip_on_cran()
  expect_silent(
    save_as_pptx(nice.table, path = "table.pptx")
  )
})

test_that("nice_fit save for html", {
  skip_on_cran()
  expect_silent(
    save_as_html(nice.table, path = "table.html")
  )
})

test_that("nice_fit save for image", {
  skip_on_cran()
  expect_failure(expect_error(
    save_as_image(nice.table, path = "table.png")
  ))
})

setwd(.old_wd)
