```
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
```

Зависимости: [[query_generator]]

Данная функция запрашивает из СУБД данные, удовлетворяющие временному промежутку.
Функция принимает на вход параметры подключения к СУБД (listed_con) и границы временного отрезка в векторном виде (output_vec). В теле функции производится подключение к СУБД, запрашивается набор данных, удовлетворяющих условию *(запрос создается функцией query_generator)* и после возвращается с разрывом подключения.  