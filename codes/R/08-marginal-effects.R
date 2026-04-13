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


model6 <- lm(vacancies ~ size * public + woj, data = df)
summary(model6)


cat("Number of parameters:", length(coef(model6)), "\n")


avg_slopes(model6, variables = "size")


avg_slopes(model6, variables = "size", by = "public")


model7 <- lm(vacancies ~ nace + size + public, data = df)
summary(model7)


pred7 <- predictions(model7,
                     newdata = datagrid(nace = unique(df$nace), size = "Medium", public = "0"))
pred7 <- as.data.frame(pred7)
pred7_sorted <- pred7[order(-pred7$estimate), c("nace", "estimate")]
head(pred7_sorted, 3)


tail(pred7_sorted, 3)


model8 <- lm(vacancies ~ nace * size + public, data = df)


pred8_medium <- predictions(model8,
                            newdata = datagrid(nace = unique(df$nace), size = "Medium", public = "0"))
pred8_large <- predictions(model8,
                           newdata = datagrid(nace = unique(df$nace), size = "Large", public = "0"))
pred8_medium <- as.data.frame(pred8_medium)
pred8_large <- as.data.frame(pred8_large)
cat("Top 3 NACE (Medium):\n")


head(pred8_medium[order(-pred8_medium$estimate), "nace"], 3)


cat("Top 3 NACE (Large):\n")


head(pred8_large[order(-pred8_large$estimate), "nace"], 3)
