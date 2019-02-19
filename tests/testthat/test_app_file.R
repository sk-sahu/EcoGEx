context("app-file")

library(shinytest)


test_that("If the app files are present", {

  appDir <- system.file("app", package = "EcoGEx")

  expect_pass(testApp(appDir, compareImages = FALSE))

})
