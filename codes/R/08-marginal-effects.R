#' ---
#' title: Marginal effects
#' author: Maciej Beręsewicz
#' ---
#' 

install.packages("marginaleffects")
install.packages("car")


library(marginaleffects)
library(car)


df <- read.csv("../../data/polish-jvs.csv", colClasses = c("character", "factor", rep("character", 4), "numeric"))
head(df)


model5 <- lm(vacancies ~ woj*size + woj*public, df)
summary(model5)


avg_slopes(model5)


avg_slopes(model5, newdata = "mean")


avg_slopes(model5, variables = "size", by = "public")


predictions(model5,
            newdata = datagrid(woj = unique(df$woj), size = "Medium", public = "0"))
