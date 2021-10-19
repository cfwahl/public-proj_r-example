
pacman::p_load(tidyverse,
               patchwork)

df_iris <- as_tibble(iris)


# figure ------------------------------------------------------------------

source("figure_set_theme.R")
theme_set(plt_theme)

g1 <- df_iris %>% 
  ggplot(aes(x = Sepal.Length,
             y = Sepal.Width,
             color = Species)) +
  geom_point()

g2 <- df_iris %>% 
  ggplot(aes(x = Sepal.Length,
             y = Petal.Length,
             color = Species)) +
  geom_point() +
  ylab(expression(alpha[2]))

g <- g1 + ggtitle("plot 1") + 
  g2 + ggtitle("plot 2") +
  plot_annotation(tag_levels = 'A') +
  plot_layout(guides = "collect", width = c(2,1))

ggsave(g,
       filename = "output/plot.pdf",
       width = 8,
       height = 6)
