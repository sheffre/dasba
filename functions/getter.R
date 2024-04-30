#getter

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