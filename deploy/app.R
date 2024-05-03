#second try
options(repos=c(CRAN="https://cran.r-project.org"))
options(shiny.port = 3838)
options(shiny.host = "82.97.241.77")

setwd("/srv/shiny-server/dasba")
source("source_functions.R")

required_packages <- c("shiny",
                       "bslib",
                       "DBI",
                       "RPostgres",
                       "lubridate",
                       "shinyWidgets",
                       "plotly",
                       "daterangepicker",
                       "shinyauthr",
                       "shinydashboard", 
                       "DT", 
                       "shinyjs")


lapply(required_packages, install_if_missing)

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

source("users.R")

source("ui.R")

source("server.R")

shiny::shinyApp(ui, server)

