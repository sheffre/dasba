#second try
source("source_functions.R")

library(shiny)
library(shinydashboard)
library(bslib)
library(DBI)
library(RPostgres)
library(lubridate)
library(shinyWidgets)
library(plotly)
library(daterangepicker)
library(shinyauthr)

source("users.R")

source("ui.R")

source("server.R")

shiny::shinyApp(ui, server)

