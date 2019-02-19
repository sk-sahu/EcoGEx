runEcoGEx <- function() {
 
 appDir <- system.file("app", package = "EcoGEx")

  shiny::runApp(appDir, display.mode = "normal")
}
