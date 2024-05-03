library(shiny)
library(shinydashboard)
library(bslib)
library(DBI)
library(RPostgres)
library(lubridate)
library(shinyWidgets)
library(plotly)
library(shinyauthr)
library(shinyjs)
library(DT)
library(daterangepicker)


ui <- dashboardPage(
  skin = "green",
  
  dashboardHeader(
    title = "DASBA v. 0.1",
    tags$li(class = "dropdown",
            style = "padding: 8px; color: #00a876;",
            shinyauthr::logoutUI("logout"))
  ),
  
  dashboardSidebar(
    collapsed = TRUE, 
    sidebarMenuOutput("sidebar")
  ),
  
  
  dashboardBody(
    shinyjs::useShinyjs(),
    
    # put the shinyauthr login ui module here
    shinyauthr::loginUI("login"),
    
    # setup any tab pages you want after login here with uiOutputs
    tabItems(
      tabItem(tabName = "dashboard", 
              fluidPage(
                box(width = 12, height = "600px",
                    plotlyOutput(outputId = 'plot', height = "600px")),
                box(width = 2,
                    radioButtons("avg", "Выберите тип осреднения:",
                                 c("1 секунда" = "sec",
                                   "5 минут" = "5min"))),
              )
      ),
      tabItem(tabName = "metrics",
              fluidPage(
                column(width = 6,
                       box(title = "Текущие значения содержания CO2", height = "900px", solidHeader = T,
                           column(width = 12, 
                                  DT::dataTableOutput('table'), style = "height:800px; overflow-y: scroll")
                       )),
                column(width = 6, 
                       box(title = "Максимальное значение CO2\nза сутки",
                           span(textOutput('max'), style = "color:#00a876; font-size:72px; text-align: center; vertical-align: baseline; height:300px; width: 90px")),
                       box(title = "Среднее значение CO2\nза сутки",
                           span(textOutput('avg_val'), style = "color:#00a876; font-size:72px; text-align: center; vertical-align: baseline; height:300px; width: 90px")),
                       box(title = "Минимальное значение CO2\nза сутки",
                           span(textOutput('min'), style = "color:#00a876; font-size:72px; text-align: center; vertical-align: baseline; height:300px; width: 90px")),
                       box(title = "Загрузка данных за определенное время\n ",
                           daterangepicker(
                             inputId = "daterange",
                             label = "Выберите даты:",
                             start = Sys.Date() - 30, end = Sys.Date(),
                             style = "width:100%; border-radius:4px",
                             icon = icon("calendar")
                           ),
                           downloadButton("downloadCal", "Загрузить данные за выбранный период")))
              ))
    )
  )
)