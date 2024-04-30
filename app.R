#app to release
source(file = paste0(getwd(), "/functions/source_functions.R"))

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
library(bslib)
library(DBI)
library(RPostgres)
library(lubridate)
library(shinyWidgets)
library(plotly)
library(daterangepicker)
library(shinyauthr)

user_base <- tibble::tibble(
  user = c("polukhin", "khoroshilov"),
  password = sapply(c("polukhin_dasba", "khoroshilov_dasba"), sodium::password_store),
  permissions = c("standard", "admin"),
  name = c("Alexander A. Polukhin", "Yuriy A. Khoroshilov")
)

db_users_con <- tibble::tibble(
  user = c("polukhin", "khoroshilov"),
  password = c("polukhin_dasba", "khoroshilov_dasba"),
  user_cal = c("polukhincal", "khoroshilovcal"),
  password_cal = c("polukhin_dasba_cal", "khoroshilov_dasba_cal")
)


dasba <- shinyApp(ui, server)
shiny::runApp(dasba, 
              launch.browser = getOption("shiny.launch.browser", interactive()))
