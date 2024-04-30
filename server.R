#server

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
