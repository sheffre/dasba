```
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}
```
Функция, устанавливающая необходимые пакеты. Принимает на вход список пакетов.