#' ---
#' title: "Generalized linear models: logistic regression"
#' author: "Maciej Beręsewicz"
#' ---
#' 

import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf
from sklearn.metrics import roc_auc_score, roc_curve


df = pd.read_csv("data/polish-jvs.csv",
                 dtype={"id": np.int64, "woj": str, "public": str,
                        "size": str, "nace_division": str, "nace": str})
df["size"]        = pd.Categorical(df["size"], categories = ["Large", "Medium", "Small"])
df["has_vacancy"] = (df["vacancies"] > 0).astype(int)
df.head()


{"n":        len(df),
 "prop_yes": df["has_vacancy"].mean(),
 "prop_pub": (df["public"] == "1").mean()}


lpm = smf.ols("has_vacancy ~ C(size) + C(public) + C(nace)", data = df).fit()
preds_lpm = lpm.predict(df)
{"min":      round(preds_lpm.min(), 4),
 "max":      round(preds_lpm.max(), 4),
 "n_below0": int((preds_lpm < 0).sum()),
 "n_above1": int((preds_lpm > 1).sum())}


tab = pd.crosstab(df["public"], df["has_vacancy"])
tab


odds_pub  = tab.loc["1", 1] / tab.loc["1", 0]
odds_priv = tab.loc["0", 1] / tab.loc["0", 0]
{"odds_public":  round(odds_pub,  4),
 "odds_private": round(odds_priv, 4),
 "OR":           round(odds_pub / odds_priv, 4),
 "log_OR":       round(np.log(odds_pub / odds_priv), 4)}


m1 = smf.glm("has_vacancy ~ C(public)", data = df,
             family = sm.families.Binomial()).fit()
print(m1.summary())


np.exp(m1.params).round(4)


m_full = smf.glm("has_vacancy ~ C(public) + C(size) + C(nace)", data = df,
                 family = sm.families.Binomial()).fit()
print(m_full.summary())


m_logit  = smf.glm("has_vacancy ~ C(public) + C(size) + C(nace)", data = df,
                   family = sm.families.Binomial(sm.families.links.Logit())).fit()
m_probit = smf.glm("has_vacancy ~ C(public) + C(size) + C(nace)", data = df,
                   family = sm.families.Binomial(sm.families.links.Probit())).fit()
ratio = (m_logit.params / m_probit.params).round(3)
print(ratio)


mfx = m_full.get_margeff(at = "overall", method = "dydx")
print(mfx.summary())


mfx_mean = m_full.get_margeff(at = "mean", method = "dydx")
print(mfx_mean.summary())


{"deviance":     round(m_full.deviance, 1),
 "AIC":          round(m_full.aic, 1),
 "BIC":          round(m_full.bic_llf, 1),
 "null_dev":     round(m_full.null_deviance, 1),
 "df_residual":  int(m_full.df_resid)}


m_red = smf.glm("has_vacancy ~ C(public) + C(size)", data = df,
                family = sm.families.Binomial()).fit()
LR = 2 * (m_full.llf - m_red.llf)
df_diff = int(m_red.df_resid - m_full.df_resid)
from scipy import stats
{"LR_stat": round(LR, 2),
 "df":      df_diff,
 "p_value": stats.chi2.sf(LR, df_diff)}


pi_hat = m_full.predict(df)
auc = roc_auc_score(df["has_vacancy"], pi_hat)
round(auc, 4)


agg = (df.groupby(["public", "size"], observed = True)["has_vacancy"]
         .agg(yes = "sum", n = "size")
         .reset_index())
agg["no"] = agg["n"] - agg["yes"]
agg


m_agg = smf.glm("yes + no ~ C(public) + C(size)", data = agg,
                family = sm.families.Binomial()).fit()
m_agg.params.round(4)
