suppressWarnings(library(lavaan))

latent <- list(
  visual = paste0("x", 1:3),
  textual = paste0("x", 4:6),
  speed = paste0("x", 7:9)
)

regression <- list(
  ageyr = c("visual", "textual", "speed"),
  grade = c("visual", "textual", "speed")
)

HS.model <- write_lavaan(latent = latent, regression = regression)

fit <- sem(HS.model, data = HolzingerSwineford1939)

data_labels <- data.frame(
  x1 = "I have good visual perception",
  x2 = "I have good cube perception",
  x3 = "I have good at lozenge perception",
  x4 = "I have paragraph comprehension",
  x5 = "I am good at sentence completion",
  x6 = "I excel at finding the meaning of words",
  x7 = "I am quick at doing mental additions",
  x8 = "I am quick at counting dots",
  x9 = "I am quick at discriminating straight and curved capitals"
)

#   ____________________________________________________________________________
#   Tests                                                                   ####

test_that("nice_modindices regular", {
  expect_snapshot(
    nice_modindices(fit, maximum.number = 5)
  )
})

test_that("nice_modindices labels", {
  expect_snapshot(
    nice_modindices(
      fit,
      maximum.number = 10,
      labels = data_labels, op = "~~"
    )
  )
})

test_that("nice_modindices auto-labels", {
  skip_if_not_installed("sjlabelled")
  x <- HolzingerSwineford1939
  x <- sjlabelled::set_label(x, label = paste0("I am ", 1:ncol(x), " years old."))
  fit <- sem(HS.model, data = x)

  expect_snapshot(
    nice_modindices(
      fit,
      maximum.number = 10,
      op = "~~"
    )
  )
})
