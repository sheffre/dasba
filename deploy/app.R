#second try
options(repos=c(CRAN="https://cran.r-project.org"))

source("source_functions.R")

required_packages <- c("shiny",
                       "bslib",
                       "DBI",
                       "RPostgres",
                       "lubridate",
                       "shinyWidgets",
                       "plotly",
                       "daterangepicker",
                       "shinyauthr")


lapply(required_packages, install_if_missing)

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

