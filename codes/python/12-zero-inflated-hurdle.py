#' ---
#' title: "Generalized linear models: zero-inflated and hurdle models"
#' author: "Maciej Beręsewicz"
#' ---
#' 

from patsy import dmatrices
import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf


df = pd.read_csv("data/polish-jvs.csv", dtype={"id": np.int64, "woj":str, "public":str,"size": str, "nace_division": str, "nace": str})
df.head()


y, x = dmatrices("vacancies ~ size + public", df, return_type='dataframe')


m1 = sm.ZeroInflatedPoisson(endog=y, exog=x, exog_infl=x, inflation='logit').fit(maxiter = 100)


print(m1.summary())


m2 = sm.ZeroInflatedNegativeBinomialP(endog=y, exog=x, exog_infl=x, inflation='logit').fit(maxiter = 500)


print(m2.summary())


y, x = dmatrices("vacancies ~ size + public", df, return_type='dataframe')


m1 = HurdleCountModel(endog=y, exog=x, exog_infl=x, inflation='logit').fit(maxiter = 100)
print(m1.summary())
