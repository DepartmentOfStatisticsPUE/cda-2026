#' ---
#' title: Maximum likelihood estimation
#' author: Maciej Beręsewicz
#' ---
#' 

import scipy.stats as st
import numpy as np
import pandas as pd
from scipy.optimize import minimize
from scipy.optimize import fsolve ## finding root(s) of a function -- for scalar parameter


def ll(par,x):
  m = np.sum(x)*np.log(par)-len(x)*np.log(np.exp(par)-1)
  return -m

## gradient
def grad(par,x):
  g = np.sum(x) / par - len(x)*np.exp(par)/(np.exp(par)-1)
  return -g

## hessian
def hess(par,x):
  h = -np.sum(x)/par**2 + len(x)*np.exp(par)/(np.exp(par)-1)**2 
  return h

## pdf
def pdf_ztpois(lam, x):
  pdfztpoiss = st.poisson(lam).pmf(x) / (1 - st.poisson(lam).pmf(0))
  return -np.sum(np.log(pdfztpoiss))


d = np.array([1645,183,37, 13,1,1])
x = np.repeat(np.arange(1,7), d)


res = minimize(fun=ll, x0=[0.5], method = "Newton-CG", jac = grad, hess = hess, args = (x))
res


res = minimize(fun=pdf_ztpois, x0=[0.5], args = (x), method = "Nelder-Mead")
res


res = fsolve(func = grad, x0 = 1, fprime = hess, args = (x,), full_output = True)
res


np.sqrt(1/np.abs(hess(res[0], x)))


d = np.array([1645, 183, 37, 13, 1, 1])
x = np.repeat(np.arange(1, 7), d)

def ll_ztpois(par, x):
    return -(np.sum(x) * np.log(par) - len(x) * np.log(np.exp(par) - 1))

def hess_ztpois(par, x):
    return -np.sum(x) / par**2 + len(x) * np.exp(par) / (np.exp(par) - 1)**2

## Nelder-Mead: gradient-free simplex method; robust but slower convergence
res_mle = minimize(fun=ll_ztpois, x0=[0.5], args=(x,), method="Nelder-Mead")
lambda_mle = res_mle.x[0]
se_mle = np.sqrt(1 / np.abs(hess_ztpois(lambda_mle, x)))
print(f"MLE: lambda = {lambda_mle:.6f}, SE = {se_mle:.5f}")


xbar = np.mean(x)

def moment_eq(lam):
    return xbar - lam / (1 - np.exp(-lam))

## fsolve: hybrid Powell method (modified Newton with line search)
res_gmm = fsolve(moment_eq, x0=0.5, full_output=True)
lambda_gmm = res_gmm[0][0]
print(f"GMM (1 moment): lambda = {lambda_gmm:.6f}")


def em_ztpois(x, lambda0=1.0, tol=1e-8, maxiter=100):
    n = len(x)
    sx = np.sum(x)
    lam = lambda0
    for i in range(1, maxiter + 1):
        ## E-step
        n0 = n * np.exp(-lam) / (1 - np.exp(-lam))
        ## M-step
        lam_new = sx / (n + n0)
        if abs(lam_new - lam) < tol:
            return {"lambda": lam_new, "iterations": i, "n0": n0}
        lam = lam_new
    return {"lambda": lam, "iterations": maxiter, "n0": n0}

res_em = em_ztpois(x)
print(f"EM: lambda = {res_em['lambda']:.6f}, iterations = {res_em['iterations']}, "
      f"estimated n0 = {res_em['n0']:.0f}")


import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

lambda_grid = np.linspace(0.20, 0.45, 200)
ll_func = lambda l: np.sum(x) * np.log(l) - len(x) * np.log(np.exp(l) - 1)
ll_vals = np.array([ll_func(l) for l in lambda_grid])
ll_max = ll_func(lambda_mle)

## 95% CI via likelihood ratio
cutoff = ll_max - st.chi2.ppf(0.95, 1) / 2
ci_idx = np.where(ll_vals >= cutoff)[0]
ci_lower = lambda_grid[ci_idx[0]]
ci_upper = lambda_grid[ci_idx[-1]]

plt.figure(figsize=(8, 5))
plt.plot(lambda_grid, ll_vals, 'k-', lw=2, label='Profile LL')
plt.axhline(y=cutoff, color='r', linestyle='--', label='95% CI cutoff')
plt.axvline(x=ci_lower, color='b', linestyle='--', label='CI bounds')
plt.axvline(x=ci_upper, color='b', linestyle='--')
plt.axvline(x=lambda_mle, color='green', linestyle='-', label='MLE')
plt.xlabel(r'$\lambda$')
plt.ylabel('log-likelihood')
plt.title('Profile log-likelihood for ZT-Poisson')
plt.legend()
plt.tight_layout()
plt.show()


print(f"Profile likelihood 95% CI: [{ci_lower:.4f}, {ci_upper:.4f}]")


def mu_zt(lam):
    return lam / (1 - np.exp(-lam))

def mu_zt_deriv(lam):
    e = np.exp(-lam)
    return (1 - e - lam * e) / (1 - e)**2

def quasi_score(lam):
    mu = mu_zt(lam)
    dmu = mu_zt_deriv(lam)
    return np.sum((x - mu) / mu * dmu)

## fsolve: hybrid Powell method to solve quasi-score equation
res_qmle = fsolve(quasi_score, x0=0.5, full_output=True)
lambda_qmle = res_qmle[0][0]

## Sandwich SE
mu_hat = mu_zt(lambda_qmle)
dmu_hat = mu_zt_deriv(lambda_qmle)
bread = np.sum(dmu_hat**2 / mu_hat)
meat = np.sum((x - mu_hat)**2 / mu_hat**2 * dmu_hat**2)
se_qmle = np.sqrt(meat / bread**2)

print(f"QMLE: lambda = {lambda_qmle:.6f}, Sandwich SE = {se_qmle:.5f}")


results = pd.DataFrame({
    "Method": ["MLE", "GMM", "EM", "Profile LR", "QMLE"],
    "Lambda": [lambda_mle, lambda_gmm, res_em["lambda"], lambda_mle, lambda_qmle],
    "SE": [se_mle, np.nan, np.nan, np.nan, se_qmle],
    "CI_lower": [lambda_mle - 1.96 * se_mle, np.nan, np.nan, ci_lower,
                 lambda_qmle - 1.96 * se_qmle],
    "CI_upper": [lambda_mle + 1.96 * se_mle, np.nan, np.nan, ci_upper,
                 lambda_qmle + 1.96 * se_qmle]
})
results.round(6)
