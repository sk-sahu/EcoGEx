library(shiny)

ui <- fluidPage(
  
  titlePanel("Arabidopsis EcosGEx"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("agi", "Entre your AGI ID:"),
      helpText("Example: AT5G61590"),
      actionButton("find", "Find"),
      helpText("It will take some time. Be patient after you hit Find."),
      uiOutput("download")
    ),
    
    mainPanel(
      h3("Ecotype specific Gene Expression", align = "center"),
      dataTableOutput("mytable"),
      
      
      tabsetPanel(type = "tabs",
                  tabPanel("Plot", plotOutput("plot")),
                  tabPanel("Table", dataTableOutput("table")),
                  tabPanel("Summary", verbatimTextOutput("summary"))
      )
    )
  )
  
)

###########################################################################
server <- function(input, output) {
  
  #Load packages
  library(data.table)
  library(maptools)
  library(maps)
  library(ggmap)
  library(ggplot2)
  
  observeEvent(input$find, {
    
    withProgress(message = 'Processing:', value = 0, {
      
      incProgress(1/2, detail = paste("Finding your gene"))
      
      #Read data.
      expr <- read.csv("expr.csv", sep = "\t", row.names = 1)
      cord <- read.csv("665_cord.csv")
      
      #Taking the AGI ID and process the table.
      agi_id <- toupper(input$agi)
      gene <- t(expr[agi_id,])
      gene_df <- as.data.frame(gene)
      gene_expr <- setDT(gene_df, keep.rownames = TRUE)[]
      colnames(gene_expr)[1] <- "gene_id"
      all <- merge(x=gene_expr, y=cord, by= "gene_id", all=TRUE)
      all_combined <- na.omit(all)
      colnames(all_combined)[1] <- "Ecotype_ID"
      
      incProgress(2/2, detail = paste("Printing table"))
      
      #Printing the table to screen on table tab
      output$table = renderDataTable({
        all_combined
      })
      
      
      #Downlord the file
      output$tabledownload <- downloadHandler(
        filename = function() {
          paste(toupper(input$agi), ".csv", sep = "")
        },
        content = function(file) {
          write.csv(all_combined, file, row.names = FALSE)
        }
      )
      
      #Downlord button (for table)
      output$download <- renderUI({
        if(!is.null(input$agi)) {
          downloadButton("tabledownload", "Download Table")
        }
      })
      
    })
  })  
}

shinyApp(ui = ui, server = server)