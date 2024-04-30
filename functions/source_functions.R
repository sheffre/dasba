install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

getter <- function(listed_con) {
  conn <- dbConnect(drv = listed_con$drv,
                    host     = listed_con$host,
                    user     = listed_con$user,
                    password = listed_con$password,
                    dbname   = listed_con$dbname)
  
  query <- "SELECT co2_partial_pressure, timestamp
            FROM co2_atm_data
WHERE timestamp >= (DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'GMT+3') - INTERVAL '3 hours')
      AND timestamp AT TIME ZONE 'GMT+3' < DATE_TRUNC('day', ((CURRENT_TIMESTAMP + INTERVAL '1 day')) AT TIME ZONE 'GMT+3') ORDER BY timestamp DESC;" 
  
  df <- dbGetQuery(conn, query)
  df$timestamp <- as.POSIXct(df$timestamp, tz = "Europe/Moscow")
  return(df)
}

processor <- function(df) {
  df$timestamp_char <- as.character(round_date(df$timestamp, unit = "second"))
  
  df$timestamp_rounded = round_date(df$timestamp, "5 minutes")
  df_5min <- aggregate(co2_partial_pressure ~ timestamp_rounded, data = df, FUN = mean)
  ls <- list(df = df, df_5min = df_5min)
  return(ls)
}

plotter_plotly <- function(method, ls) {
  switch(method,
         "sec" = {fig <- plot_ly(ls$df, type = "scatter", mode = "lines") %>%
           add_trace(x = ~timestamp, y = ~co2_partial_pressure, name = 'Содержание CO2',
                     hovertemplate = 'pCO2: %{y:ppm}\nВремя: %{x}<extra></extra>')%>%
           layout(showlegend = F)
         
         fig <- fig %>%
           layout(
             colorway = "#00a876",
             title = "Суточный ход содержания CO2",
             xaxis = list(zerolinecolor = '#838383',
                          zerolinewidth = 2,
                          gridcolor = '#838383',
                          title = "Дата и время"
             ),
             yaxis = list(zerolinecolor = '#838383',
                          zerolinewidth = 2,
                          gridcolor = '#838383',
                          title = "Парциальное давление CO2, ppm"
             ),
             plot_bgcolor='#ffffff')
         
         
         },
         "5min" = {
           fig <- plot_ly(ls$df_5min, type = "scatter", mode = "lines") %>%
             add_trace(x = ~timestamp_rounded, 
                       y = ~co2_partial_pressure, 
                       name = 'Содержание CO2',
                       hovertemplate = 'pCO2: %{y:ppm}\nВремя: %{x}<extra></extra>')%>%
             layout(showlegend = F)
           
           fig <- fig %>%
             layout(
               colorway = "#00a876",
               title = "Суточный ход содержания CO2",
               xaxis = list(zerolinecolor = '#838383',
                            zerolinewidth = 2,
                            gridcolor = '#838383',
                            title = "Дата и время"
               ),
               yaxis = list(zerolinecolor = '#838383',
                            zerolinewidth = 2,
                            gridcolor = '#838383',
                            title = "Парциальное давление CO2, ppm"
               ),
               plot_bgcolor='#ffffff')
         }
  )
  return(fig)
}

table_unit <- function(df) {
  colnames(df)[c(1,3)] = c("pCO2, ppm", "Дата и время")
  return(df[c(1:60), c(1,3)])
}

rd_mean <- function(vec) {
  round(mean(vec), digits = 0)
}

query_generator <- function(borders) {
  query <- paste0("SELECT * 
                  FROM avg_hour_values 
                  WHERE upper_time <= ", "date_trunc('day', TIMESTAMP '", as.character(borders[2]), "') 
                  AND upper_time >= ", "date_trunc('day', TIMESTAMP '", as.character(borders[1]), "') 
                  ORDER BY upper_time DESC")
  return(query)
}

cal_getter <- function(listed_con, output_vec) {
  con <- dbConnect(drv = listed_con$drv,
                   host = listed_con$host,
                   user = listed_con$user,
                   password = listed_con$password,
                   dbname = listed_con$dbname)
  result <- dbGetQuery(conn = con, statement = query_generator(output_vec))
  dbDisconnect(con)
  return(result)
}

