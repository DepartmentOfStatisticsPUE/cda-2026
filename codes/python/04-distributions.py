#' ---
#' title: Discrete distributions
#' author: Maciej Beręsewicz
#' ---
#' 

import scipy.stats as st
import numpy as np
import pandas as pd


np.random.seed(20230228)
st.bernoulli(0.7).rvs(10)


np.random.seed(20230228)
st.binom(50,0.7).rvs(10)


np.random.seed(20230228)
st.poisson(1.5).rvs(10)


import pandas as pd
import numpy as np
from scipy import stats

## read data and filter 3 sections
jvs = pd.read_csv("../../data/polish-jvs.csv")
jvs3 = jvs[jvs["nace"].isin(["C", "G", "P"])]

## step 1: estimate per-entity lambdas, total rates (Lambda), and pi
lambda_hat = jvs3.groupby("nace")["vacancies"].mean()
n_entities = jvs3.groupby("nace")["vacancies"].count()
Lambda_hat = n_entities * lambda_hat  ## total Poisson rates
pi_hat = Lambda_hat / Lambda_hat.sum()
print("Lambda (per-entity):", lambda_hat.to_dict())


print("Lambda (total):", Lambda_hat.to_dict())


print("Pi:", pi_hat.to_dict())


## step 2: simulate 1000 independent Poisson draws per section
np.random.seed(123)
n_sim = 1000
sim = {s: stats.poisson(Lambda_hat[s]).rvs(n_sim) for s in ["C", "G", "P"]}
totals = sim["C"] + sim["G"] + sim["P"]
valid = totals > 0

cond_prop = {s: np.mean(sim[s][valid] / totals[valid]) for s in ["C", "G", "P"]}
print("Simulated proportions:", {k: round(v, 4) for k, v in cond_prop.items()})


print("Theoretical pi:", {k: round(v, 4) for k, v in pi_hat.items()})


## step 3: multinomial -- expected vs observed
obs_totals = jvs3.groupby("nace")["vacancies"].sum()
n_total = obs_totals.sum()
expected = n_total * pi_hat

print("Observed:", obs_totals.to_dict())


print("Expected:", {k: round(v, 1) for k, v in expected.items()})


## simulate from multinomial
np.random.seed(123)
mult_draws = np.random.multinomial(n_total, pi_hat.values, size=1000)
print("Multinomial means:", dict(zip(pi_hat.index, mult_draws.mean(axis=0).round(1))))
