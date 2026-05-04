#' ---
#' title: "Generalized linear models: count data"
#' author: "Maciej Beręsewicz"
#' ---
#' 

install.packages("MASS")
install.packages("AER")
install.packages("lmtest")
install.packages("performance")
install.packages("marginaleffects")
install.packages("modelsummary")


library(MASS)
library(AER)
library(lmtest)
library(performance)
library(marginaleffects)
library(modelsummary)


df <- read.csv("data/polish-jvs.csv",
               colClasses = c("character", "factor", rep("character", 4), "numeric"))
df$size   <- factor(df$size,   levels = c("Large", "Medium", "Small"))
df$public <- factor(df$public)
df$nace   <- factor(df$nace)
head(df)


c(mean      = mean(df$vacancies),
  var       = var(df$vacancies),
  prop_zero = mean(df$vacancies == 0))


ols <- lm(vacancies ~ size + public + nace, data = df)
preds_ols <- predict(ols)
cat("Min OLS prediction:", round(min(preds_ols), 3), "\n")


cat("Number negative   :", sum(preds_ols < 0),
    "out of", length(preds_ols), "\n")


fit_log_c <- function(c_val) {
  m <- lm(log(vacancies + c_val) ~ size + public, data = df)
  exp(coef(m))
}
cmp <- cbind(`c=1`     = fit_log_c(1),
             `c=0.5`   = fit_log_c(0.5),
             `c=0.001` = fit_log_c(0.001))
round(cmp, 3)


pois_simple <- glm(vacancies ~ size + public, data = df, family = poisson())
round(exp(coef(pois_simple)), 3)


pois <- glm(vacancies ~ size + public + nace, data = df,
            family = poisson(link = "log"))
summary(pois)


round(exp(coef(pois)), 3)


modelplot(pois, exponentiate = TRUE) +
  ggplot2::geom_vline(xintercept = 1, linetype = 2)


phi <- sum(residuals(pois, type = "pearson")^2) / df.residual(pois)
round(phi, 2)


AER::dispersiontest(pois, trafo = 1)


performance::check_overdispersion(pois)


qp  <- glm(vacancies ~ size + public + nace, data = df,
           family = quasipoisson(link = "log"))


nb2 <- MASS::glm.nb(vacancies ~ size + public + nace, data = df)
nb2$theta  # this is k in our notation


modelsummary(list(Poisson       = pois,
                  `Quasi-Poiss` = qp,
                  NB2           = nb2),
             exponentiate = TRUE,
             statistic    = "({std.error})",
             gof_omit     = "F|RMSE")


lr_stat <- 2 * (logLik(nb2) - logLik(pois))
lr_pval <- pchisq(as.numeric(lr_stat), df = 1, lower.tail = FALSE)
cat("LR statistic:", round(as.numeric(lr_stat), 1), "\n")
cat("p-value     :", format.pval(lr_pval), "\n")


lmtest::lrtest(pois, nb2)


data.frame(
  Model = c("Poisson", "NB2"),
  AIC   = round(c(AIC(pois), AIC(nb2)), 1),
  BIC   = round(c(BIC(pois), BIC(nb2)), 1)
)


avg_slopes(nb2, variables = "size")


predictions(nb2,
            newdata = datagrid(nace   = unique(df$nace),
                               size   = "Medium",
                               public = "0")) |>
  as.data.frame() |>
  subset(select = c("nace", "estimate", "conf.low", "conf.high"))
