#' ---
#' title: Goodness of fit statistics
#' author: Maciej Beręsewicz
#' ---
#' 

import scipy.stats as st
from scipy.optimize import minimize
import numpy as np
import pandas as pd


np.random.seed(1)
N = 10000
x = st.nbinom(n = 2, p = 2/(2+3)).rvs(N)
np.mean(x)


x = np.loadtxt("data/nb_sim.txt", dtype = np.int64)
np.mean(x)


def ll_nbinom(par, x):
  pdfnbinom = st.nbinom(par[0],par[1]).logpmf(x)
  return -np.sum(pdfnbinom)

res = minimize(fun=ll_nbinom, x0=[2, 0.5], args = (x), method = "Nelder-Mead")
res


res.x


x_uniq_vals, x_uniq_counts = np.unique(x, return_counts=True)
## we simply use pdf(NB(2.01357331, 0.40157875), x) 
est_pmf = st.nbinom(res.x[0],res.x[1]).pmf(x_uniq_vals) 
est_pmf = est_pmf/np.sum(est_pmf)
np.round(est_pmf*100,)


st.power_divergence(x_uniq_counts, 
                    sum(x_uniq_counts)*est_pmf, 
                    lambda_ = 0, ddof = 2)


st.power_divergence(x_uniq_counts, 
                    sum(x_uniq_counts)*est_pmf, 
                    lambda_ = 1, ddof = 2)


## generate data
X = np.concatenate([np.repeat(i, n) for i, n in enumerate([100, 50, 15, 5, 1])])
## frequency table
X_tab = pd.Series(X).value_counts().sort_index()
## estimated lambda
lambda_hat = np.mean(X)
## fitted counts
n_hat = len(X) * st.poisson.pmf(np.arange(0, 5), lambda_hat)
## pearson residual
r_hat = (X_tab.values - n_hat) / np.sqrt(n_hat)
## store results in data.frame
X_dt = pd.DataFrame({'X': np.arange(0, 5), 'n': X_tab.values, 'n_hat': n_hat, 'r_hat': r_hat})
X_dt


## loglik for n
def ll_nbinom(par, x):
  pdfnbinom = st.nbinom(par[0],par[1]).logpmf(x)
  return -np.sum(pdfnbinom)

res_nb = minimize(fun=ll_nbinom, x0=[2, 0.5], args = (X), method = "Nelder-Mead")
ll_po = sum(st.poisson(np.mean(X)).logpmf(X))
ll_nb = -res_nb.fun
LR_test =  2*ll_nb - 2*ll_po
[LR_test, 1, 1 - st.chi2.cdf(LR_test, 1)]


AIC_po = 2*1 - 2*ll_po
AIC_nb = 2*2 - 2*ll_nb
[AIC_nb, AIC_po]


BIC_po = np.log(len(X))*1 - 2*ll_po
BIC_nb = np.log(len(X))*2 - 2*ll_nb
[BIC_nb, BIC_po]
