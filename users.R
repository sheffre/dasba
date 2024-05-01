#users data
user_base <- tibble::tibble(
  user = c("polukhin", "khoroshilov", "admin"),
  password = sapply(c("polukhin_dasba", "khoroshilov_dasba", "admin"), sodium::password_store),
  permissions = c("standard", "admin", "admin"),
  name = c("Alexander A. Polukhin", "Yuriy A. Khoroshilov", "admin")
)

db_users_con <- tibble::tibble(
  user = c("polukhin", "khoroshilov"),
  password = c("polukhin_dasba", "khoroshilov_dasba"),
  user_cal = c("polukhincal", "khoroshilovcal"),
  password_cal = c("polukhin_dasba_cal", "khoroshilov_dasba_cal")
)
