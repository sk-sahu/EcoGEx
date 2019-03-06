#' Running EcoGEx locally
#'
#' This function will run the EcoGEx shiny app locally
#' @return EcoGEx shinny app
#'
#' @export
runEcoGEx <- function() {

 appDir <- system.file("app", package = "EcoGEx")

  shiny::runApp(appDir, display.mode = "normal")
}
