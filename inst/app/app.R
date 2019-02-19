library(shiny)

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
               Please be patient once after clicking the Find button."),
      br(),
      uiOutput("download_map"),
      br(),
      uiOutput("download_table")

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
                           verbatimTextOutput("info"),
                           plotOutput("hist_plot")
                  ),

                  tabPanel("Table", dataTableOutput("table")),

                  tabPanel("Comparison",
                           uiOutput("dropdown_box1"),
                           uiOutput("dropdown_box2"),
                           uiOutput("dropdown_box3"),
                           plotOutput("bar_plot"),
                           verbatimTextOutput("value1"),
                           verbatimTextOutput("value2"),
                           verbatimTextOutput("value3")
                  ),

                  tabPanel("About",
                           fluidRow(
                             includeMarkdown("README.md")
                           )
                  )
      ) #tabstPanel ends here

    ) # mainPanel ends here
  )

)

#######################   Server funtion starts from here ############################

# Loading packages
library(data.table)
library(maps)
library(ggplot2)
library(plyr)

server <- function(input, output) {

  ranges <- reactiveValues(x = NULL, y = NULL)

  observeEvent(input$find, { # "Find" button event

    withProgress(message = 'Processing:', value = 0, {

      incProgress(1/2, detail = paste("Finding your gene")) ###################### Progress step 1

      # Read data (Time taking step)
      expr <- read.csv("data/GSE80744_gene_expression.csv", sep = "\t", row.names = 1)
      cord <- read.csv("data/665_geo_coordinates.csv")

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
      top20 <- head(arrange(all_combined, desc(all_combined$Gene_expression)) , n = 20)
      last20 <- tail(arrange(all_combined, desc(all_combined$Gene_expression)) , n = 20)

      incProgress(2/2, detail = paste("Printing results"))  ######################## Progress step 2

      ################ Printing and Downloading table ################

      # Printing the table to screen on table tab
      output$table = renderDataTable({
        all_combined
      })

      # download the table
      output$tabledownload <- downloadHandler(
        filename = function() {
          paste(toupper(input$agi), "_Table.csv", sep = "")
        },
        content = function(file) {
          write.csv(all_combined, file, row.names = FALSE)
        }
      )

      #download button (for table)
      output$download_table <- renderUI({
        if(!is.null(input$agi)) {
          downloadButton("tabledownload", "Download Table")
        }
      })

      ############## Map Generation, printing and Download ####################

      # Generating Map
      mapWorld <- borders("world", colour="gray50", fill="gray50") # create a layer of borders
      mp <- ggplot() +   mapWorld + ggtitle(bquote("Ecotype/ Accession specific Gene expression for" == .(input$agi)))
      mp <- mp+ geom_point(aes(x=all_combined$longitude, y=all_combined$latitude) ,color="blue", size=3)+
        coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE)
      mp <- mp+ geom_point(aes(x=top20$longitude, y=top20$latitude) ,color="red", size=3)
      mp <- mp+ geom_point(aes(x=last20$longitude, y=last20$latitude) ,color="green", size=3)

      # Printing Map to screen
      output$plot <- renderPlot({
        mp
      })

      # Object for next step (Map Download)
      Map <- reactive({
        mp
      })

      # download Map
      output$downloadPlot <- downloadHandler(
        filename = function() {
          paste(input$agi, '_Map.png', sep='')
        },
        content = function(file) {
          ggsave(file, plot = Map(), device = "png", width = 7, height = 4)
        }
      )

      # download button (for Map)
      output$download_map <- renderUI({
        if(!is.null(input$agi)) {
          downloadButton("downloadPlot", "Download Map")
        }
      })

      ################# Interactive Plot (Map) modifications #################

      # Plot Click
      output$info <- renderText({
        paste("########### Interactive Plot Details ###########",
              "\nClick Anywhere on the map to get the coordinates",
              "\nLongitude=", input$plot_click$x,
              "\nLatitude=", input$plot_click$y,
              "\n\n########### Note ###########",
              "\nRed: Top 20 Accessions (High Expression) ",
              "\nGreen: Least 20 Accessions (Low Expression) ",
              "\nBlue: Moderate Expression"
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

      ######################## Histogram #################################

      # Priting histogram
      output$hist_plot <- renderPlot({
        exp_hist <- hist(all_combined$Gene_expression, col = "cyan3",
                         main = bquote("Gene Expression Value Distribution for" == .(input$agi)),
                         xlab = "Gene Expression",
                         ylab = "In number of Accessions."
        )
      })

      ####################### Ecotype Comparison  ########################

      # Doropdown box 1
      output$dropdown_box1 <- renderUI({
        # Copy the line below to make a select box
        selectInput("var1", label = "Select Accession 1",
                    choices = sort(all_combined$Ecotype_name),
                    selected = "Col-0")
      })

      # Dropdown box 2
      output$dropdown_box2 <- renderUI({
        selectInput("var2", label = "Select Accession 2",
                    choices = sort(all_combined$Ecotype_name),
                    selected = "Zu-1")
      })

      # Dropdown box 3
      output$dropdown_box3 <- renderUI({
        selectInput("var3", label = "Select Accession 3",
                    choices = sort(all_combined$Ecotype_name),
                    selected = "Spro 2")
      })

      # Create object for reactive values to be uused in next step
      rv <- reactiveValues(
        stored_var1 = character(),
        stored_var2 = character(),
        stored_var3 = character()
      )

      # When input change -> update
      observe({
        rv$stored_var1 <- input$var1
        filter_row1 <- all_combined[all_combined$Ecotype_name == rv$stored_var1]
        rv$stored_var2 <- input$var2
        filter_row2 <- all_combined[all_combined$Ecotype_name == rv$stored_var2]
        rv$stored_var3 <- input$var3
        filter_row3 <- all_combined[all_combined$Ecotype_name == rv$stored_var3]

        # Combine all the dropbox selections for borplot
        barplot_matrix <- rbind(filter_row1, filter_row2, filter_row3)

        output$bar_plot <- renderPlot({
          barplot(barplot_matrix$Gene_expression, names.arg = barplot_matrix$Ecotype_name,
                  main = "Comparison of Gene Expression among Accessions",
                  xlab = "Accessions", ylab = "Gene Expression", col = "darkseagreen1")
        })

      })

      ################### After this End of withProgress and observeEvent ################

    }) # withProgress ends here
  })  # observeEvent ends here

} # Server fucntion ends here

shinyApp(ui = ui, server = server)
