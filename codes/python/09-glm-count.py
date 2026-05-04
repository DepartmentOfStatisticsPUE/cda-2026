#' ---
#' title: "Generalized linear models: count data"
#' author: "Maciej Beręsewicz"
#' ---
#' 

import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf


df = pd.read_csv("data/polish-jvs.csv",
                 dtype={"id": np.int64, "woj": str, "public": str,
                        "size": str, "nace_division": str, "nace": str})
df["size"] = pd.Categorical(df["size"], categories=["Large", "Medium", "Small"])
df.head()


{"mean":      df["vacancies"].mean(),
 "var":       df["vacancies"].var(),
 "prop_zero": (df["vacancies"] == 0).mean()}


ols = smf.ols("vacancies ~ C(size) + C(public) + C(nace)", data=df).fit()
preds_ols = ols.predict(df)
print("Min OLS prediction:", round(preds_ols.min(), 3))


print("Number negative   :", int((preds_ols < 0).sum()),
      "out of", len(preds_ols))


def fit_log_c(c_val):
    df["log_y"] = np.log(df["vacancies"] + c_val)
    m = smf.ols("log_y ~ C(size) + C(public)", data=df).fit()
    return np.exp(m.params)

cmp = pd.DataFrame({"c=1":     fit_log_c(1),
                    "c=0.5":   fit_log_c(0.5),
                    "c=0.001": fit_log_c(0.001)})
cmp.round(3)


pois_simple = smf.glm("vacancies ~ C(size) + C(public)", data=df,
                      family=sm.families.Poisson()).fit()
np.exp(pois_simple.params).round(3)


pois = smf.glm("vacancies ~ C(size) + C(public) + C(nace)", data=df,
               family=sm.families.Poisson()).fit()
print(pois.summary())


np.exp(pois.params).round(3)


mu_hat = pois.fittedvalues
pearson = (df["vacancies"] - mu_hat) / np.sqrt(mu_hat)
phi_py = float((pearson ** 2).sum() / pois.df_resid)
round(phi_py, 2)


## Iterative NB2 via GLM: estimate alpha from Poisson residuals, then refit
alpha_hat = ((pois.resid_pearson ** 2).sum() / pois.df_resid - 1) / pois.fittedvalues.mean()
for _ in range(25):
    nb2 = smf.glm("vacancies ~ C(size) + C(public) + C(nace)", data=df,
                  family=sm.families.NegativeBinomial(alpha=alpha_hat)).fit()
    alpha_hat = ((nb2.resid_pearson ** 2).sum() / nb2.df_resid - 1) / nb2.fittedvalues.mean()

print(nb2.summary())
print(f"\nEstimated alpha (1/k): {alpha_hat:.4f}")


qp = smf.glm("vacancies ~ C(size) + C(public) + C(nace)",
             data = df, family = sm.families.Poisson()).fit(scale = "X2")
qp.bse.head()


## NB2 GLM log-likelihood is conditional on estimated alpha;
## valid for LR test once alpha has converged
lr_stat = 2 * (nb2.llf - pois.llf)
from scipy.stats import chi2
lr_pval = chi2.sf(lr_stat, df=1)
print(f"LR statistic: {lr_stat:.1f}")
print(f"p-value     : {lr_pval:.2e}")


pd.DataFrame({
    "Model": ["Poisson", "NB2"],
    "AIC":   [round(pois.aic, 1), round(nb2.aic, 1)],
    "BIC":   [round(pois.bic, 1), round(nb2.bic, 1)]
})


from marginaleffects import avg_slopes
avg_slopes(pois, variables = "size").to_pandas()
