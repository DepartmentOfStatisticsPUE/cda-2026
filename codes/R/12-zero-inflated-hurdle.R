#' ---
#' title: "Generalized linear models: zero-inflated and hurdle models"
#' author: "Maciej Beręsewicz"
#' ---
#' 

install.packages("pscl")
install.packages("countreg", repos="http://R-Forge.R-project.org")
install.packages("topmodels", repos="http://R-Forge.R-project.org") ## rootogram
install.packages("distributions3")
install.packages("modelsummary")
install.packages("marginaleffects")
install.packages("performance")
install.packages("rstudioapi")


library(MASS) ## glm.nb
library(countreg)
library(pscl)
library(topmodels)
library(modelsummary)
library(boot)
library(marginaleffects)
library(performance)


df <- read.csv("data/polish-jvs.csv", colClasses = c("character", "factor", rep("character", 4), "numeric"))
head(df)


mean(df$vacancies == 0) ## share of 0s in our data


table(df$vacancies == 0) ## freq of 0s in our data


m1 <- pscl::zeroinfl(formula = vacancies ~ size + public,
                     dist = "poisson", ## E(Y|X) -- that is why the model is called zero-inflation poisson regression
                     link = "logit",   ## P(Y = 0 | X) -- logistic regression
                     data = df)


summary(m1)


exercise1 <- pscl::zeroinfl(formula = vacancies ~ nace,
                     dist = "poisson", ## E(Y|X) -- that is why the model is called zero-inflation poisson regression
                     link = "logit",   ## P(Y = 0 | X) -- logistic regression
                     data = df)
summary(exercise1)


## count: naceJ         2.6053     0.1130  23.052  < 2e-16 ***
## zi: naceJ           -0.92210    0.14460  -6.377 1.81e-10 ***


rootogram(m1, plot = "base", xlim = c(0,11))


avg_slopes(m1, type = "zero") ## P(Y=0|X)


avg_slopes(m1, type = "response") ## AME for E(Y|X)


ex2_po <- glm(formula = vacancies ~ size + nace,
              family = poisson(), data=df)

ex2_zip <- pscl::zeroinfl(formula = vacancies ~ size + nace,
                          dist = "poisson",  link = "logit",  data = df)

data.frame(AIC = AIC(ex2_po, ex2_zip), BIC = BIC(ex2_po, ex2_zip))


par(mfrow=c(1,2))
rootogram(ex2_po, plot = "base", xlim = c(0,11), main = "Poisson")
rootogram(ex2_zip, plot = "base", xlim = c(0,11), main = "ZIP")


m2 <- pscl::zeroinfl(formula = vacancies ~ size + public,
                     dist = "negbin",
                     link = "logit",
                     data = df)


summary(m2)


BIC(m1, ## ZI poisson
    m2  ## ZI neg bin
    )


rootogram(m2, plot = "base", xlim = c(0,11))


BIC(m1, m2)


ex2_po <- glm(formula = vacancies ~ size + nace,
              family = poisson(), data=df)

ex2_zip <- pscl::zeroinfl(formula = vacancies ~ size + nace,
                          dist = "poisson",  link = "logit",  data = df)

ex2_nb <- glm.nb(formula = vacancies ~ size + nace, data=df)

ex2_zinb <- pscl::zeroinfl(formula = vacancies ~ size + nace,
                          dist = "negbin",  link = "logit",  data = df)


data.frame(AIC = AIC(ex2_po, ex2_zip, ex2_nb, ex2_zinb),
           BIC = BIC(ex2_po, ex2_zip, ex2_nb, ex2_zinb))


par(mfrow=c(1,2))
rootogram(ex2_po, plot = "base", xlim = c(0,11), main = "Poisson")
rootogram(ex2_zip, plot = "base", xlim = c(0,11), main = "ZIP")


rootogram(ex2_nb, plot = "base", xlim = c(0,11), main = "NegBin")
rootogram(ex2_zinb, plot = "base", xlim = c(0,11), main = "ZINB")


ex2_zip <- pscl::zeroinfl(formula = vacancies ~ size + nace | nace,
                          dist = "poisson",  link = "logit",  data = df)
summary(ex2_zip)


m1 <- countreg::hurdle(formula = vacancies ~ size + public,
                   dist = "poisson", ## vacancies ~ zero-truncated Poisson distribution
                   link = "logit", ## P(Y > 0 | Z) | w oneinf P(Y = 0 | Z)
                   data = df)
summary(m1)


m1a <- countreg::zeroinfl(formula = vacancies ~ size + public,
                   dist = "poisson",
                   link = "logit",
                   data = df)


modelsummary(list("ZIP"=m1a, "HP"=m1))


BIC(m1, m1a)


# avg_slopes(m1, type = "zero") # P(Y > 0 | Z) not working


avg_slopes(m1, type = "response")


m2 <- pscl::hurdle(formula = vacancies ~ size + public,
                     dist = "negbin", ## zero-truncated NB vs zeroinf mamy NB
                     link = "logit",
                     data = df)


summary(m2)


BIC(m1, m2) #hurdle Poisson vs hurdle NB


m3 <- pscl::zeroinfl(formula = vacancies ~ size + public,
                     dist = "negbin",
                     link = "logit",
                     data = df)

summary(m3)


BIC(m2,m3)


modelsummary(list("HurdleNB"=m2, "ZINB"=m3))


pR2(m1) |> round(2)


pR2(m1a) |> round(2)


pR2(m2) |> round(2)


pR2(m3) |> round(2)
