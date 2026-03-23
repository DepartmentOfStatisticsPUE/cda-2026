#' ---
#' title: Simpson’s paradox
#' author: Maciej Beręsewicz
#' ---
#' 

install.packages("bayestestR")


library(bayestestR)
library(ggplot2)


example_df <- simulate_simpson(n = 100, groups = 5, r = 0.5)


p1 <- ggplot(data = example_df, aes(x = V1, y = V2)) +
  geom_point() +
  geom_smooth(method = "lm", se = F) 

p1
ggsave(p1, file = "../lectures/fig-simps-1.png", width = 7, height = 5)


p2 <- ggplot(data = example_df, aes(x = V1, y = V2, color = Group)) +
  geom_point() +
  geom_smooth(method = "lm", se = F) 

p2
ggsave(p2, file = "../lectures/fig-simps-2.png", width = 7, height = 5)
