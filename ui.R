#UI

ui <- page_sidebar(
  shinyjs::useShinyjs(),
  
 
  
  
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
    # login section
    shinyauthr::loginUI("login"),
    
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