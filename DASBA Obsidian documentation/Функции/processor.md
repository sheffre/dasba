```
processor <- function(df) {
  df$timestamp_char <- as.character(round_date(df$timestamp, unit = "second"))
  
  df$timestamp_rounded = round_date(df$timestamp, "5 minutes")
  df_5min <- aggregate(co2_partial_pressure ~ timestamp_rounded, data = df, FUN = mean)
  ls <- list(df = df, df_5min = df_5min)
  return(ls)
}
```
Core-функция кода. Обрабатывает получаемые из СУБД сырые суточные данные.