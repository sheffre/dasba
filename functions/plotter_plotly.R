#plotter_plotly

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