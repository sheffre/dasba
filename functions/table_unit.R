#table_unit

table_unit <- function(df) {
  colnames(df)[c(1,3)] = c("pCO2, ppm", "Дата и время")
  return(df[c(1:60), c(1,3)])
}