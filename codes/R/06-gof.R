#' ---
#' title: Goodness of fit statistics
#' author: Maciej Beręsewicz
#' ---
#' 

install.packages(c("vcd", "fitdistrplus"))


library(vcd)
library(fitdistrplus)


set.seed(1)
n <- 10000
x <- rnbinom(n, mu = 3, size = 2)
## or
x <- rnbinom(n, prob = 2/(2+3), size = 2)
x_length <- length(table(x))
x_dof <- 1+2
x_fitted <- fitdistr(x = x, densfun = "negative binomial") ## using MASS::fitdistr
x_fitted


fitdist(x, "nbinom")


fitdist(x, "nbinom") |> plot()


cat(x, sep = "\n", file = "data/nb_sim.txt")


gof_nb <- goodfit(x, "nbinomial")
gof_po <- goodfit(x, "poisson")
gof_nb


summary(gof_nb)


summary(gof_po)


rootogram(gof_nb, main = "Negative binomial")


rootogram(gof_po, main = "Poisson")


X <- rep(0:4, c(100,50,15,5,1))
X_tab <- table(X)
X_tab


X_po <- goodfit(X, "poisson")
X_po


lambda_hat <- mean(X)
lambda_hat


n_hat <- length(X)*dpois(0:4, lambda_hat)
n_hat


r_hat <- (as.vector(X_tab)-n_hat)/sqrt(n_hat)
r_hat


X_dt <- data.frame(X = 0:4, n = as.vector(X_tab), n_hat = n_hat, r_hat = r_hat)
X_dt


X_nb <- goodfit(X, "nbinom")
X_nb


summary(X_po)


summary(X_nb)


X_fit_ll_po <- fitdistr(X, "poisson")
X_fit_ll_nb <- fitdistr(X, "negative binomial")


AIC(X_fit_ll_po, X_fit_ll_nb)


BIC(X_fit_ll_po, X_fit_ll_nb)


LR_test <- 2*X_fit_ll_nb$loglik - 2*X_fit_ll_po$loglik
LR_test_p <- pchisq(LR_test, 1, lower.tail = F)
data.frame(LR=LR_test, df = 1, p_val = LR_test_p)
