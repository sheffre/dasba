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


server <- function(input, output, session) {
  # login status and info will be managed by shinyauthr module and stores here
  credentials <- callModule(shinyauthr::login, "login", 
                            data = user_base,
                            user_col = user,
                            pwd_col = password,
                            sodium_hashed = T,
                            log_out = reactive(logout_init()))
  
  # logout status managed by shinyauthr module and stored here
  logout_init <- callModule(shinyauthr::logout, "logout", reactive(credentials()$user_auth))
  
  # this opens or closes the sidebar on login/logout
  observe({
    if(credentials()$user_auth) {
      shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
    } else {
      shinyjs::addClass(selector = "body", class = "sidebar-collapse")
    }
  })
  
  output$table <- DT::renderDataTable(table_unit(processor(getter(list(drv = RPostgres::Postgres(),
                                                                       host     = '81.31.246.77',
                                                                       user     = subset(db_users_con$user, db_users_con$user == credentials()$info$user),
                                                                       password = subset(db_users_con$password, db_users_con$user == credentials()$info$user),
                                                                       dbname   = "default_db")))$df))
  output$min <- renderText({
    req(credentials()$user_auth)
    min(processor(getter(list(drv = RPostgres::Postgres(),
                              host     = '81.31.246.77',
                              user     = subset(db_users_con$user, db_users_con$user == credentials()$info$user),
                              password = subset(db_users_con$password, db_users_con$user == credentials()$info$user),
                              dbname   = "default_db")))$df$co2_partial_pressure)})
  output$max <- renderText({
    req(credentials()$user_auth)
    max(processor(getter(list(drv = RPostgres::Postgres(),
                              host     = '81.31.246.77',
                              user     = subset(db_users_con$user, db_users_con$user == credentials()$info$user),
                              password = subset(db_users_con$password, db_users_con$user == credentials()$info$user),
                              dbname   = "default_db")))$df$co2_partial_pressure)})
  output$avg_val <- renderText({
    req(credentials()$user_auth)
    expr = rd_mean(as.numeric(processor(getter(list(drv = RPostgres::Postgres(),
                                                    host     = '81.31.246.77',
                                                    user     = subset(db_users_con$user, db_users_con$user == credentials()$info$user),
                                                    password = subset(db_users_con$password, db_users_con$user == credentials()$info$user),
                                                    dbname   = "default_db")))$df$co2_partial_pressure))})
  
  
  
  observe({
    if(credentials()$user_auth) {
      invalidateLater(5000)
      
      listed_conn <- list(drv = RPostgres::Postgres(),
                          host     = '81.31.246.77',
                          user     = subset(db_users_con$user, db_users_con$user == credentials()$info$user),
                          password = subset(db_users_con$password, db_users_con$user == credentials()$info$user),
                          dbname   = "default_db")
      
      listed_conn_cal <- list(drv = RPostgres::Postgres(),
                              host     = '81.31.246.77',
                              user     = subset(db_users_con$user_cal, db_users_con$user == credentials()$info$user),
                              password = subset(db_users_con$password_cal, db_users_con$user == credentials()$info$user),
                              dbname   = "default_db")
      
      ls <- processor(getter(listed_conn))
      output$table <- DT::renderDataTable(table_unit(ls$df))
      output$min <- renderText({
        req(credentials()$user_auth)
        min(ls$df$co2_partial_pressure)})
      output$max <- renderText({
        req(credentials()$user_auth)
        max(ls$df$co2_partial_pressure)})
      output$avg_val <- renderText({
        req(credentials()$user_auth)
        expr = rd_mean(as.numeric(ls$df$co2_partial_pressure))})
    }
  })
  
  output$plot <- renderPlotly({
    req(credentials()$user_auth)
    plotter_plotly(ls = processor(
      getter(
        list(drv = RPostgres::Postgres(),
             host     = '81.31.246.77',
             user     = subset(db_users_con$user, db_users_con$user == credentials()$info$user),
             password = subset(db_users_con$password, db_users_con$user == credentials()$info$user),
             dbname   = "default_db"))), method = input$avg)})
  
  output$downloadCal <- downloadHandler(
    filename = function() {
      paste(getwd(), "/dasba_export/SBA_data_from ", format(input$daterange[1]), " to ", format(input$daterange[2]), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(x = cal_getter(listed_con = list(drv = RPostgres::Postgres(),
                                                 host     = '81.31.246.77',
                                                 user     = subset(db_users_con$user_cal, db_users_con$user == credentials()$info$user),
                                                 password = subset(db_users_con$password_cal, db_users_con$user == credentials()$info$user),
                                                 dbname   = "default_db"), 
                               output_vec = input$daterange), file = file)
    }
  )
  
  # only when credentials()$user_auth is TRUE, render your desired sidebar menu
  output$sidebar <- renderMenu({
    req(credentials()$user_auth)
    sidebarMenu(
      id = "tabs",
      menuItem("График", tabName = "dashboard"),
      menuItem("Метрики", tabName = "metrics")
    )
  })
}