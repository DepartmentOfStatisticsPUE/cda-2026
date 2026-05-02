#' ---
#' title: "Generalized linear models: logistic regression"
#' author: "Maciej Beręsewicz"
#' ---
#' 

install.packages("marginaleffects")
install.packages("modelsummary")
install.packages("performance")
install.packages("pROC")
install.packages("car")
install.packages("broom")


library(marginaleffects)
library(modelsummary)
library(performance)
library(pROC)
library(broom)


df <- read.csv("data/polish-jvs.csv",
               colClasses = c("character", "factor", rep("character", 4), "numeric"))
df$size        <- factor(df$size,   levels = c("Large", "Medium", "Small"))
df$public      <- factor(df$public)
df$nace        <- factor(df$nace)
df$has_vacancy <- as.integer(df$vacancies > 0)
head(df)


c(n         = nrow(df),
  prop_yes  = mean(df$has_vacancy),
  prop_pub  = mean(df$public == "1"))


lpm <- lm(has_vacancy ~ size + public + nace, data = df)
preds_lpm <- predict(lpm)
c(min      = round(min(preds_lpm), 4),
  max      = round(max(preds_lpm), 4),
  n_below0 = sum(preds_lpm < 0),
  n_above1 = sum(preds_lpm > 1))


tab <- table(public = df$public, has_vacancy = df$has_vacancy)
tab


odds_pub  <- tab["1", "1"] / tab["1", "0"]
odds_priv <- tab["0", "1"] / tab["0", "0"]
c(odds_public  = round(odds_pub,  4),
  odds_private = round(odds_priv, 4),
  OR           = round(odds_pub / odds_priv, 4),
  log_OR       = round(log(odds_pub / odds_priv), 4))


m1 <- glm(has_vacancy ~ public, data = df, family = binomial(link = "logit"))
summary(m1)


round(exp(coef(m1)), 4)


m_full <- glm(has_vacancy ~ public + size + nace, data = df,
              family = binomial(link = "logit"))
summary(m_full)


modelsummary(list(`logit (public)` = m1,
                  `logit (full)`   = m_full),
             exponentiate = TRUE,
             statistic    = "({std.error})",
             gof_omit     = "F|RMSE")


car::Anova(m_full, type = 2) |> broom::tidy()


m_logit   <- glm(has_vacancy ~ public + size + nace, data = df,
                 family = binomial(link = "logit"))
m_probit  <- glm(has_vacancy ~ public + size + nace, data = df,
                 family = binomial(link = "probit"))
m_cloglog <- glm(has_vacancy ~ public + size + nace, data = df,
                 family = binomial(link = "cloglog"))

# Coefficients side-by-side (link scale)
modelsummary(list(logit   = m_logit,
                  probit  = m_probit,
                  cloglog = m_cloglog),
             statistic = "({std.error})",
             gof_omit  = "F|RMSE")


round(coef(m_logit) / coef(m_probit), 3)


avg_slopes(m_full)


slopes(m_full, newdata = "mean")


predictions(m_full,
            newdata = datagrid(public = c("0", "1"),
                               size   = "Medium",
                               nace   = "C")) |>
  as.data.frame() |>
  subset(select = c("public", "size", "nace", "estimate", "conf.low", "conf.high"))


c(deviance     = round(deviance(m_full), 1),
  AIC          = round(AIC(m_full), 1),
  BIC          = round(BIC(m_full), 1),
  null_dev     = round(m_full$null.deviance, 1),
  df_residual  = m_full$df.residual)


performance::r2_mcfadden(m_full)


performance::r2_tjur(m_full)


m_red <- glm(has_vacancy ~ public + size, data = df,
             family = binomial(link = "logit"))
anova(m_red, m_full, test = "LRT")


df$pi_hat <- predict(m_full, type = "response")
roc_obj <- pROC::roc(df$has_vacancy, df$pi_hat, quiet = TRUE)
auc(roc_obj)


plot(roc_obj, main = "ROC for full logistic model")


df$bin <- cut(df$pi_hat,
              breaks = quantile(df$pi_hat, probs = seq(0, 1, by = 0.1)),
              include.lowest = TRUE)
calib <- aggregate(cbind(pi_hat, has_vacancy) ~ bin, data = df, FUN = mean)
plot(calib$pi_hat, calib$has_vacancy,
     xlim = c(0, max(calib$pi_hat) * 1.05),
     ylim = c(0, max(calib$has_vacancy) * 1.05),
     xlab = "Predicted probability (decile mean)",
     ylab = "Observed proportion",
     pch  = 19)
abline(0, 1, lty = 2)


agg <- aggregate(cbind(yes = has_vacancy, n = 1) ~ public + size,
                 data = df, FUN = sum)
agg$no <- agg$n - agg$yes
head(agg)


m_agg <- glm(cbind(yes, no) ~ public + size, data = agg,
             family = binomial(link = "logit"))
round(coef(m_agg), 4)


m_ind <- glm(has_vacancy ~ public + size, data = df,
             family = binomial(link = "logit"))
round(coef(m_ind), 4)
