library(tidyverse)

iris <- as_tibble(iris)

# playing -----------------------------------------------------------------

setosa <- iris %>% 
  filter(Species == "setosa")

set <- iris %>% 
  filter(str_detect(string = Species, pattern = "set"))


# sample data -------------------------------------------------------------

for(i in 1:3) {
  print(paste0("data_raw/iris", i, ".csv"))
  write_csv(iris[sample(150, 10),], paste0("data_raw/iris", i, ".csv"))
}


# read data ---------------------------------------------------------------

df_iris <- list.files(path = "data_raw",
                      full.names = T) %>% 
  as_tibble() %>% 
  filter(str_detect(value, pattern = "iris")) %>% 
  pull() %>% 
  lapply(FUN = read_csv) %>% 
  bind_rows()
