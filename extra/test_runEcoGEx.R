context("app-function")

library(shinytest)

test_that("If the app function is working", {

  expect_pass(testApp("apps/ecogex/", compareImages = FALSE))

})
