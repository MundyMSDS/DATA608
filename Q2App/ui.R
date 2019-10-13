
library(shiny)
library(shinyjs)

share <- list(
  title = "Data 608 - CDC Wonder Data",
  image = "",
  description = "",
  twitter_user = ""
)

function(request) {
  fluidPage(
    useShinyjs(),
    title = "Data 608: CDC Wonder Data",
    
    # add custom JS and CSS
    singleton(
      tags$head(
        includeScript(file.path('www', 'message-handler.js')),
        includeScript(file.path('www', 'helper-script.js')),
        includeCSS(file.path('www', 'style.css')),
        tags$meta(name = "twitter:image", content = share$image)
      )
    ),
    
    # enclose the header in its own section to style it nicer
    div(id = "headerSection",
        h1("Data 608: CDC Wonder Data - Quesstion 2"),
        
        # author info
        span(
          style = "font-size: 1.2em",
          span("Created by "),
          a("Jim Mundy", href = ""),
          HTML("&bull;"),
          span("Code"),
          a("on GitHub", href = "https://github.com/MundyMSDS/DATA608"),
          HTML("&bull;"),
          br(),
          
          span("October 2019")
        )
    ),
    
    # show a loading message initially
    div(
      id = "loadingContent",
      h2("Loading...")
    ),	
    
    # all content goes here, and is hidden initially until the page fully loads
    hidden(div(id = "allContent",
               # sidebar - filters for the data
               sidebarLayout(
                 sidebarPanel(
                   h3("Filter data", style = "margin-top: 0;"),
                   
                   # show all the cancers or just specific types?
                   selectInput(
                     "subsetType", "",
                     c("Show all cancer types" = "all",
                       "Select specific types" = "specific"),
                     selected = "specific"),
                   
                   # which cancer types to show
                   conditionalPanel(
                     "input.subsetType == 'specific'",
                     uiOutput("cancerTypeUi")
                   ),
                   
                   selectInput(
                     "subsetType2", "",
                     c("Show all states" = "all",
                       "Select specific states" = "specific"),
                     selected = "specific"),
                   
                   # which states to show
                   conditionalPanel(
                     "input.subsetType2 == 'specific'",
                     uiOutput("stateTypeUi")
                   ),
                   
                   # whether to combine all data in a given year or not
                   checkboxInput("showGrouped",
                                 strong("Group all data in each year"),
                                 FALSE), br(),
                   
                   # what years to show
                   # Note: yearText should use "inline = TRUE" in newer shiny versions,
                   # but since the stats server has an old version I'm doing this in css
                   strong(span("Years:")),
                   textOutput("yearText"), br(),  
                   uiOutput("yearUi"), br(),
                   
                   # what variables to show
                   uiOutput("variablesUi"),
                   
                   # button to update the data
                   shiny::hr(),
                   actionButton("updateBtn", "Update Data"), 
                   
                   # footer - where the data was obtained
                   br(), br(),
                   p("",
                     a("",
                       href = "http://wonder.cdc.gov/cancer.html",
                       target = "_blank")),
                   a(img(src = "", alt = ""),
                     href = "http://wonder.cdc.gov/cancer.html",
                     target = "_blank")
                 ),
                 
                 # main panel has two tabs - one to show the data, one to plot it
                 mainPanel(wellPanel(
                   tabsetPanel(
                     id = "resultsTab", type = "tabs",
                     
                     # tab showing the data in table format
                     tabPanel(
                       title = "Show data", id = "tableTab",
                       
                       br(),
                       downloadButton("downloadData", "Download table"),
                       br(), br(),
                       
                       span("Table format:"),
                       radioButtons(inputId = "tableViewForm",
                                    label = "",
                                    choices = c("Long" = "long", "Wide" = "wide"),
                                    inline = TRUE),
                       br(),
                       
                       tableOutput("dataTable")
                     ),
                     
                     # tab showing the data as plots
                     tabPanel(
                       title = "Plot data", id = "plotTab",
                       br(),
                       h4("Often you are asked whether particular States are improving their mortality rates (per cause)
faster than, or slower than, the national average. Create a visualization that lets your clients
see this for themselves for one cause of death at the time. Keep in mind that the national
average should be weighted by the national population."),
                       downloadButton("downloadPlot", "Save figure"),
                       br(), br(),
                       plotOutput("dataPlot")
                     )

                   )
                 ))
               )
    ))
  )
}