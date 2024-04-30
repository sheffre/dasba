#auth
install.packages("shinyauthr")

library(shiny)
library(shinyauthr)

user_base <- tibble::tibble(
  user = c("Polukhin", "Khoroshilov"),
  password = sapply(c("polukhin_dasba", "khoroshilov_dasba"), sodium::password_store),
  permissions = c("standard", "admin"),
  name = c("Alexander A. Polukhin", "Yuriy A. Khoroshilov")
)

db_users_con <- tibble::tibble(
  user = c("Polukhin", "Khoroshilov"),
  password = c("polukhin_dasba", "khoroshilov_dasba"),
  user_cal = c("polukhin_cal", "khoroshilov_cal"),
  password_cal = c("polukhin_dasba_cal", "khoroshilov_dasba_cal")
)

subset(db_users_cal_con$user_db, db_users_cal_con$user == "Polukhin")

ui <- fluidPage(
  # logout button
  div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
  
  # login section
  shinyauthr::loginUI(id = "login",
                      title = "Пожалуйста, введите имя пользователя и пароль:",
                      user_title = "Имя пользователя:",
                      pass_title = "Пароль:",
                      login_title = "Войти",
                      error_message = "Ошибка: неверное имя пользователя или пароль!",
                      cookie_expiry = 7),
  
  # Sidebar to show user info after login
  uiOutput("sidebarpanel"),
  
  # Plot to show user info after login
  plotOutput("distPlot"),
  
  tableOutput("user_table")
  
)

server <- function(input, output, session) {
  
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    sodium_hashed = TRUE,
    log_out = reactive(logout_init())
  )
  
  # Logout to hide
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )
  
  
  output$sidebarpanel <- renderUI({
    
    # Show only when authenticated
    req(credentials()$user_auth)
    
    tagList(
      # Sidebar with a slider input
      column(width = 4,
             sliderInput("obs",
                         "Number of observations:",
                         min = 0,
                         max = 1000,
                         value = 500)
      ),
      
      column(width = 4,
             p(paste("You have", credentials()$info[["permissions"]],"permission"))
      )
    )
    
  })
  
  # Plot
  output$distPlot <- renderPlot({
    
    # Show plot only when authenticated
    req(credentials()$user_auth)
    
    if(!is.null(input$obs)) {
      hist(rnorm(input$obs)) 
    }
    
  })
  
  output$user_table <- renderTable({
    # use req to only render results when credentials()$user_auth is TRUE
    req(credentials()$user_auth)
    credentials()$info
  })
  
  
}

test_app <- shinyApp(ui = ui, server = server)
shiny::runApp(test_app, 
              launch.browser = getOption("shiny.launch.browser", interactive()))
