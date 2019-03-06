library(shiny)

ui <- fluidPage(
  
  titlePanel("Arabidopsis EcoGEx 0.6"),
  br(),
  
  sidebarLayout(
    sidebarPanel(
      
      textInput("agi", "Entre your AGI:"),
      helpText("AGI: Arabidopsis Gene Identifier
               Example: AT5G61590"),
      actionButton("find", "Find"),
      helpText("This will take some time to scan your gene.
               Please be patient once after clicking the Find button."),
      uiOutput("download2"),
      br(),
      uiOutput("download1")
      
      ),
    
    mainPanel(
      h3("Ecotype specific Gene Expression", align = "center"),
      br(),
      
      
      tabsetPanel(type = "tabs",
                  tabPanel("Interactive Plot", 
                           plotOutput("plot", click = "plot_click"),
                           verbatimTextOutput("info")
                  ),
                  
                  tabPanel("Table", dataTableOutput("table")),
                  
                  tabPanel("About", 
                           fluidRow(
                             includeMarkdown("about.md")
                           )
                  )
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
  library(plyr)
  library(markdown)
  
  observeEvent(input$find, {
    
    withProgress(message = 'Processing:', value = 0, {
      
      incProgress(1/2, detail = paste("Finding your gene")) ###########Progress step
      
      #Read data.
      expr <- read.csv("GSE80744_gene_expression.csv", sep = "\t", row.names = 1)
      cord <- read.csv("665_geo_coordinates.csv")
      
      #Taking the AGI ID and process the table.
      agi_id <- toupper(input$agi)
      gene <- t(expr[agi_id,])
      gene_df <- as.data.frame(gene)
      gene_expr <- setDT(gene_df, keep.rownames = TRUE)[]
      colnames(gene_expr)[1] <- "gene_id"
      all <- merge(x=gene_expr, y=cord, by= "gene_id", all=TRUE)
      all_combined <- na.omit(all)
      colnames(all_combined)[1] <- "Ecotype_ID"
      colnames(all_combined)[2] <- "Gene_expression"
      
      top20 <- head(arrange(all_combined, desc(all_combined$Gene_expression)) , n = 20)
      last20 <- tail(arrange(all_combined, desc(all_combined$Gene_expression)) , n = 20)
      
      incProgress(2/2, detail = paste("Printing table"))  ###########Progress step
      
      #Printing the table to screen on table tab
      output$table = renderDataTable({
        all_combined
      })
      
      
      #Downlord the table
      output$tabledownload <- downloadHandler(
        filename = function() {
          paste(toupper(input$agi), "_Table.csv", sep = "")
        },
        content = function(file) {
          write.csv(all_combined, file, row.names = FALSE)
        }
      )
      
      #Downlord button (for table)
      output$download1 <- renderUI({
        if(!is.null(input$agi)) {
          downloadButton("tabledownload", "Download Table")
        }
      })
      
      mapWorld <- borders("world", colour="gray50", fill="gray50") # create a layer of borders
      mp <- ggplot() +   mapWorld
      mp <- mp+ geom_point(aes(x=all_combined$longitude, y=all_combined$latitude) ,color="blue", size=3) 
      mp <- mp+ geom_point(aes(x=top20$longitude, y=top20$latitude) ,color="red", size=3)
      mp <- mp+ geom_point(aes(x=last20$longitude, y=last20$latitude) ,color="green", size=3)
      
      output$plot <- renderPlot({
        mp
      })
      
      
      # Plot
      plotInput <- reactive({
        mp
      })
      
      
      
      #Downlord button (for plot)
      output$download2 <- renderUI({
        if(!is.null(input$agi)) {
          downloadButton("downloadPlot", "Download Map")
        }
      })
      
      # Downlord plot
      output$downloadPlot <- downloadHandler(
        filename = function() { 
          paste(input$agi, '_Map.png', sep='') 
        },
        content = function(file) {
          ggsave(file, plot = plotInput(), device = "png", width = 7, height = 4)
        }
      )
      
      # Plot Click
      output$info <- renderText({
        paste("########### Interactive Plot Details ###########",
              "\nClick Anywhere on the map to get the Corrdinates",
              "\nLongitude=", input$plot_click$x, 
              "\nLatitude=", input$plot_click$y,
              "\n\n########### Note ###########",
              "\nRed: High Expression of Top 20 gene.",
              "\nGreen: Low Expression Least 20 gene.",
              "\nBlue: Moderate Expression"
        )
        
      })
      
      
      
      ################### After this withProgress and observeEvent ################
      
    }) ## withProcess
  })  ## observeEvent
  
}

shinyApp(ui = ui, server = server)