library(shiny)

ui <- fluidPage(

  titlePanel("Arabidopsis WWE-MAP"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("agi", "Entre AGI ID:"),
      actionButton("find", "Find"),
      helpText("After entring the ID sit back and wait.
               It will take some time table gets load")
      ),
    
    
    mainPanel(
    h2("Table", align = "center"),
    DT::dataTableOutput("mytable")
    )
  )

)


server <- function(input, output) {
  
  library(data.table)
  library(maptools)
  library(maps)
  library(ggmap)
  library(ggplot2)
  library(DT)
  
  observe({
    
    agi_id <- toupper(input$agi)
    expr <- read.csv("expr.csv", sep = "\t", row.names = 1)
    cord <- read.csv("665_cord.csv")
    gene <- t(expr[agi_id,])
    gene_df <- as.data.frame(gene)
    gene_expr <- setDT(gene_df, keep.rownames = TRUE)[]
    colnames(gene_expr)[1] <- "gene_id"
	  all <- merge(x=gene_expr, y=cord, by= "gene_id", all=TRUE)
	  all_combined <- na.omit(all)
	    
	   output$mytable = DT::renderDataTable({
	     all_combined
	   })
  })
}

shinyApp(ui = ui, server = server)
