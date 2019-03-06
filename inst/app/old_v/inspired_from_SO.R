ui <- fluidPage(
  
  titlePanel("Arabidopsis EcoGEx 0.6"),
  br(),
  
  sidebarLayout(
    sidebarPanel(
      
      textInput("agi", "Entre your AGI:"),
      helpText("AGI: Arabidopsis Gene Identifier."),
      helpText("Example: AT5G61590"),
      actionButton("find", "Find"),
      helpText("This will take some time to scan your gene.
               Please be patient once after clicking the Find button.")
  #    br(),
  #   uiOutput("download_map"),
  #    br(),
  #    uiOutput("download_table")
      
      ),
    
    mainPanel(
      h3("Ecotype specific Gene Expression", align = "center"),
      br(),
      
      
      tabsetPanel(type = "tabs",
                  tabPanel("Interactive Plot", 
                           plotOutput("plot", click = "plot_click",
                                      height = 300,
                                      dblclick = "plot_dblclick",
                                      brush = brushOpts(
                                        id = "plot_brush",
                                        resetOnNew = TRUE
                                      )),
                           verbatimTextOutput("info")
                           #plotOutput("hist_plot")
                  ),
                  
                  tabPanel("Table", dataTableOutput("table")),
                  
                  #tabPanel("Ecotype Comparison", 
                  #        uiOutput("dropdown_box1"),
                  #        uiOutput("dropdown_box2"),
                  #        uiOutput("dropdown_box3"),
                  #        plotOutput("bar_plot"),
                  #        verbatimTextOutput("value1"),
                  #        verbatimTextOutput("value2"),
                  #        verbatimTextOutput("value3")
                  #),
                  
                  tabPanel("About", 
                           fluidRow(
                             includeMarkdown("about.md")
                           )
                  )
      ) #tabstPanel ends here
      
    ) # mainPanel ends here
  ) 
  
)

#######################   Server funtion starts from here ############################

# Loading packages
library(data.table)
library(maptools)
library(maps)
library(ggmap)
library(ggplot2)
library(plyr)
library(markdown)

server <- function(input, output) {
  
  ranges <- reactiveValues(x = NULL, y = NULL)
  
  mp_table <- eventReactive(input$find, { # "Find" button event
    
    withProgress(message = 'Processing:', value = 0, {
      
      incProgress(1/2, detail = paste("Finding your gene")) ###################### Progress step 1
      
    # Read data (Time taking step)
    expr <- read.csv("GSE80744_gene_expression.csv", sep = "\t", row.names = 1)
    cord <- read.csv("665_geo_coordinates.csv")
    
    ##### Taking the AGI ID and process the final table (All Primary data) #####
    
    agi_id <- toupper(input$agi)
    gene <- t(expr[agi_id,]) # Making a list with Ecotype_id as row name and corospoding Expression value in one column for given agi_id as header.
    gene_df <- as.data.frame(gene)
    gene_expr <- setDT(gene_df, keep.rownames = TRUE)[] # data table made with Ecotype_id as col 1 and Expression value col 2
    colnames(gene_expr)[1] <- "gene_id"
    all <- merge(x=gene_expr, y=cord, by= "gene_id", all=TRUE)
    all_combined <- na.omit(all)
    colnames(all_combined)[1] <- "Ecotype_ID"
    colnames(all_combined)[2] <- "Gene_expression"
    
    all_combined
    
    }) # progress bar end
  
  })
  
  ############## Map Generation, printing and Download ####################
  
  # Generating Map
  mp <- reactive({
    all_combined <- mp_table()
    top20 <- head(arrange(all_combined, desc(all_combined$Gene_expression)) , n = 20)
    last20 <- tail(arrange(all_combined, desc(all_combined$Gene_expression)) , n = 20)
    
    mapWorld <- borders("legacy_world", colour="gray50", fill="gray50") # create a layer of borders
    mp <- ggplot() +   mapWorld #+ ggtitle(bquote("Exotype specific Gene expression of"== .(input$agi)))
    mp <- mp+ geom_point(aes(x=all_combined$longitude, y=all_combined$latitude) ,color="blue", size=3)+
      coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE)  
    mp <- mp+ geom_point(aes(x=top20$longitude, y=top20$latitude) ,color="red", size=3)
    mp <- mp+ geom_point(aes(x=last20$longitude, y=last20$latitude) ,color="green", size=3)
    mp
  })
  
  # Printing Map to screen
  output$plot <- renderPlot({
    mp()
  }) 
  
  
  ################# Interactive Plot (Map) modifications #################
  
  # Plot Click
  output$info <- renderText({
    paste("\nLongitude=", input$plot_click$x, 
          "\nLatitude=", input$plot_click$y
    )
  })
  
  # Zoom
  # When a double-click happens, check if there's a brush on the plot.
  # If so, zoom to the brush bounds; if not, reset the zoom.
  observeEvent(input$plot_dblclick, {
    brush <- input$plot_brush
    if (!is.null(brush)) {
      ranges$x <- c(brush$xmin, brush$xmax)
      ranges$y <- c(brush$ymin, brush$ymax)
      
    } else {
      ranges$x <- NULL
      ranges$y <- NULL
    }
  })
  
  ############ Printing the table to screen on table tab #########
  output$table = renderDataTable({
    mp_table()
  })
  
} # server end

shinyApp(ui,server)