#app to release


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




ui <- page_sidebar(
  
  # login section
  shinyauthr::loginUI(id = "login",
                      title = "Пожалуйста, введите имя пользователя и пароль:",
                      user_title = "Имя пользователя:",
                      pass_title = "Пароль:",
                      login_title = "Войти",
                      error_message = "Ошибка: неверное имя пользователя или пароль!",
                      cookie_expiry = 7),
  
  
  title = titlePanel(div("Просмотр данных газоанализатора SBA-5", style = "text-align: center")),
  sidebar = sidebar(title = "Меню",
                    div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
                    radioButtons("avg", "Выберите тип осреднения:",
                                 c("1 секунда" = "sec",
                                   "5 минут" = "5min")),
                    downloadButton("downloadData", "Загрузить данные за сутки"),
                    actionBttn('plot_upd', "Обновить график хода"),
                    position = 'right'),
  fluidRow(
    plotlyOutput('plot', height = "500px"),
    layout_columns(
      card(card_header("Текущие значения содержания CO2", style = "text-align: center"),
           tableOutput('table'),
           style = "height:300px; overflow-y: scroll"),
      card(card_header("Максимальное значение CO2\nза сутки", style = "text-align: center"),
           span(textOutput('max'), style = "color:#00a876; font-size:72px; text-align: center; vertical-align: baseline")),
      card(card_header("Среднее значение CO2\nза сутки", style = "text-align: center"),
           span(textOutput('avg_val'), style = "color:#00a876; font-size:72px; text-align: center; vertical-align: baseline")),
      card(card_header("Минимальное значение CO2\nза сутки", style = "text-align: center"),
           span(textOutput('min'), style = "color:#00a876; font-size:72px; text-align: center; vertical-align: baseline")),
      card(card_header("Загрузка данных за определенное время\n "),
           card_footer("Позволяет загрузить почасовые осреднения данных за выбранный период на Ваш ПК."),
           full_screen = T,
           daterangepicker(
             inputId = "daterange",
             label = "Выберите даты:",
             start = Sys.Date() - 30, end = Sys.Date(),
             style = "width:100%; border-radius:4px",
             icon = icon("calendar")
           ),
           downloadButton("downloadCal", "Загрузить данные за выбранный период")
      )
    ),
  )
)



server <- function(input, output, session) {
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    sodium_hashed = TRUE,
    log_out = reactive(logout_init())
  )
  
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
  
  
  conn <- dbConnect(drv = listed_conn$drv,
                    host     = listed_conn$host,
                    user     = listed_conn$user,
                    password = listed_conn$password,
                    dbname   = listed_conn$dbname)
  on.exit(dbDisconnect(conn), add = TRUE)
  
  ls <- processor(getter(listed_conn))
  
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )
  
  observe({
    invalidateLater(5000)
    ls <- processor(getter(listed_conn))
    output$table <- renderTable({
      table_unit(ls$df)
    })
    output$min <- renderText(min(ls$df$co2_partial_pressure))
    output$max <- renderText(max(ls$df$co2_partial_pressure))
    output$avg_val <- renderText(expr = rd_mean(as.numeric(ls$df$co2_partial_pressure)))
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(getwd(), "/dasba_export/SBA_data_for", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(x = ls$df, file =file)
    }
  )
  
  output$downloadCal <- downloadHandler(
    filename = function() {
      paste(getwd(), "/dasba_export/SBA_data_from ", format(input$daterange[1]), " to ", format(input$daterange[2]), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(x = cal_getter(listed_con = listed_conn_cal, 
                               output_vec = input$daterange), file = file)
    }
  )
  
  observeEvent(input$plot_upd, {
    ls <- processor(getter(listed_conn))
    output$plot <- renderPlotly(plotter_plotly(ls, method = input$avg))
  })
  
  output$plot <- renderPlotly({
    req(credentials()$user_auth)
    plotter_plotly(ls, method = input$avg)})
  
  output$table <- renderTable({
    req(credentials()$user_auth)
    table_unit(ls$df)
  })
  output$min <- renderText(min(ls$df$co2_partial_pressure))
  output$max <- renderText(max(ls$df$co2_partial_pressure))
  output$avg_val <- renderText(expr = rd_mean(as.numeric(ls$df$co2_partial_pressure)))
}

dasba <- shinyApp(ui, server)
shiny::runApp(dasba, 
              launch.browser = getOption("shiny.launch.browser", interactive()))
