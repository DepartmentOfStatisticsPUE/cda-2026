#' ---
#' title: Maximum likelihood estimation
#' author: Maciej Beręsewicz
#' ---
#' 

install.packages(c("maxLik", "rootSolve"))


library(maxLik)
library(rootSolve)


ll <- function(par, x) {
  m <- sum(x)*log(par)-length(x)*log(exp(par)-1)
  m
}

ll_min <- function(par, x) {
  m <- sum(x)*log(par)-length(x)*log(exp(par)-1)
  -m
}

## gradient
grad <- function(par, x)  {
  g <- sum(x) / par - length(x)*exp(par)/(exp(par)-1)
  g
}


## hessian
hess <- function(par, x) {
  h <- -sum(x)/par^2 + length(x)*exp(par)/(exp(par)-1)^2 
  h
}

## using pdf

pdf_ztpois <- function(lambda, x) {
    pdfztpoiss <- dpois(x, lambda)/(1-dpois(0, lambda))
    return(-sum(log(pdfztpoiss)))
}


d <-  c(1645,183,37, 13,1,1)
x <- rep(1:6,d)


optim(par = 1, fn = ll_min, x = x, method = "Brent", lower = 0, upper = 6, hessian = T)
optim(par = 1, fn = ll_min, gr = grad, x = x, method = "Brent", lower = 0, upper = 6, hessian = T)
optim(par = 1, fn = pdf_ztpois,  x = x, method = "Brent", lower = 0, upper = 6, hessian = T) 


optimize(f = ll_min, lower = 0, upper = 6, x = x) ## minimization
optimize(f = ll, lower = 0, upper = 6, x = x, maximum = T) ## maximization


nlm(f = ll_min, p = 1, x = x, hessian = T)


maxLik(logLik = ll, start = 1,  x = x) |> summary()
maxLik(logLik = ll, start = 1, grad = grad, hess = hess,  x = x) |> summary()


uniroot(grad, lower = 0.1, upper = 0.9, x = x) 


multiroot(grad, start = 0.1, x = x) 


d <- c(1645, 183, 37, 13, 1, 1)
x <- rep(1:6, d)
ll <- function(par, x) {
  sum(x) * log(par) - length(x) * log(exp(par) - 1)
}
## maxLik uses Newton-Raphson by default (gradient-based, uses Hessian)
res_mle <- maxLik(logLik = ll, start = 1, x = x)
coef_mle <- coef(res_mle)
se_mle <- stdEr(res_mle)
cat("MLE: lambda =", coef_mle, ", SE =", se_mle, "\n")


## moment condition: E[X] - lambda/(1-exp(-lambda)) = 0
xbar <- mean(x)
moment_eq <- function(lambda) {
  xbar - lambda / (1 - exp(-lambda))
}
## uniroot: Brent's bracketing method for 1D root-finding
res_gmm <- uniroot(moment_eq, lower = 0.01, upper = 5)
cat("GMM (1 moment): lambda =", res_gmm$root, "\n")


em_ztpois <- function(x, lambda0 = 1, tol = 1e-8, maxiter = 100) {
  n <- length(x)
  sx <- sum(x)
  lambda <- lambda0
  for (i in 1:maxiter) {
    ## E-step
    n0 <- n * exp(-lambda) / (1 - exp(-lambda))
    ## M-step
    lambda_new <- sx / (n + n0)
    if (abs(lambda_new - lambda) < tol) {
      return(list(lambda = lambda_new, iterations = i, n0 = n0))
    }
    lambda <- lambda_new
  }
  list(lambda = lambda, iterations = maxiter, n0 = n0)
}

res_em <- em_ztpois(x)
cat("EM: lambda =", res_em$lambda, ", iterations =", res_em$iterations,
    ", estimated n0 =", round(res_em$n0), "\n")


lambda_grid <- seq(0.20, 0.45, length.out = 200)
ll_vals <- sapply(lambda_grid, function(l) ll(l, x))
ll_max <- ll(coef_mle, x)

## 95% CI via likelihood ratio
cutoff <- ll_max - qchisq(0.95, 1) / 2
ci_idx <- which(ll_vals >= cutoff)
ci_lower <- lambda_grid[min(ci_idx)]
ci_upper <- lambda_grid[max(ci_idx)]

plot(lambda_grid, ll_vals, type = "l", lwd = 2,
     xlab = expression(lambda), ylab = "log-likelihood",
     main = "Profile log-likelihood for ZT-Poisson")
abline(h = cutoff, col = "red", lty = 2)
abline(v = c(ci_lower, ci_upper), col = "blue", lty = 2)
abline(v = coef_mle, col = "darkgreen", lty = 1)
legend("topright",
       legend = c("Profile LL", "95% CI cutoff", "CI bounds", "MLE"),
       col = c("black", "red", "blue", "darkgreen"),
       lty = c(1, 2, 2, 1), lwd = c(2, 1, 1, 1), cex = 0.8)

cat("Profile likelihood 95% CI: [", ci_lower, ",", ci_upper, "]\n")


## Quasi-score: sum of (x_i - mu(lambda)) / V(mu(lambda)) * mu'(lambda) = 0
mu_zt <- function(lambda) lambda / (1 - exp(-lambda))
mu_zt_deriv <- function(lambda) {
  e <- exp(-lambda)
  (1 - e - lambda * e) / (1 - e)^2
}

quasi_score <- function(lambda) {
  mu <- mu_zt(lambda)
  dmu <- mu_zt_deriv(lambda)
  sum((x - mu) / mu * dmu)
}

## uniroot: Brent's method to solve quasi-score equation
res_qmle <- uniroot(quasi_score, lower = 0.01, upper = 5)
lambda_qmle <- res_qmle$root

## Sandwich SE
mu_hat <- mu_zt(lambda_qmle)
dmu_hat <- mu_zt_deriv(lambda_qmle)
## bread: -sum(dmu^2 / V(mu))
bread <- sum(dmu_hat^2 / mu_hat)
## meat: sum((x - mu)^2 / V(mu)^2 * dmu^2)
meat <- sum((x - mu_hat)^2 / mu_hat^2 * dmu_hat^2)
se_qmle <- sqrt(meat / bread^2)

cat("QMLE: lambda =", lambda_qmle, ", Sandwich SE =", se_qmle, "\n")


results <- data.frame(
  Method = c("MLE", "GMM", "EM", "Profile LR", "QMLE"),
  Lambda = c(coef_mle, res_gmm$root, res_em$lambda, coef_mle, lambda_qmle),
  SE = c(se_mle, NA, NA, NA, se_qmle),
  CI_lower = c(coef_mle - 1.96 * se_mle, NA, NA, ci_lower,
               lambda_qmle - 1.96 * se_qmle),
  CI_upper = c(coef_mle + 1.96 * se_mle, NA, NA, ci_upper,
               lambda_qmle + 1.96 * se_qmle)
)
results
