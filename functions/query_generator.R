#query generator for calendar output

query_generator <- function(borders) {
  query <- paste0("SELECT * 
                  FROM avg_hour_values 
                  WHERE upper_time <= ", "date_trunc('day', TIMESTAMP '", as.character(borders[2]), "') 
                  AND upper_time >= ", "date_trunc('day', TIMESTAMP '", as.character(borders[1]), "') 
                  ORDER BY upper_time DESC")
  return(query)
}