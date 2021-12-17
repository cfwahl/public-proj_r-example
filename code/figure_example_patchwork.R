
pacman::p_load(tidyverse,
               patchwork)

df_iris <- as_tibble(iris) %>% 
  mutate(Species = str_to_sentence(Species)) # capitalize the first letter


# figure ------------------------------------------------------------------

source("figure_set_theme.R")
theme_set(plt_theme)

g1 <- df_iris %>% 
  ggplot(aes(x = Sepal.Length,
             y = Sepal.Width,
             color = Species)) +
  geom_point() +
  labs(x = "Sepal length (cm)",
       y = "Sepal width (cm)")

g2 <- df_iris %>% 
  ggplot(aes(x = Petal.Length,
             y = Petal.Width,
             color = Species)) +
  geom_point() +
  labs(x = "Sepal length (cm)",
       y = "Petal width (cm)")

g <- g1 + ggtitle("plot 1") + 
  g2 + ggtitle("plot 2") +
  plot_annotation(tag_levels = 'A') +
  plot_layout(guides = "collect", width = c(1,1))

ggsave(g,
       filename = "output/plot.pdf",
       width = 8,
       height = 4)
