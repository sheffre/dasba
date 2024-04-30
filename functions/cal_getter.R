#calendar getter

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