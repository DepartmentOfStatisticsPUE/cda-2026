#' ---
#' title: Marginal effects
#' author: Maciej Beręsewicz
#' ---
#' 

import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf
from marginaleffects import *


df = pd.read_csv("data/polish-jvs.csv", dtype={"id": np.int64, "woj":str, "public":str,"size": str, "nace_division": str, "nace": str})
df.head()


model5 = smf.ols("vacancies ~ woj*size + woj*public", data = df).fit()
print(model5.summary())


model5_ame = avg_slopes(model5)
model5_ame.to_pandas().head()


model5_mem = avg_slopes(model5, newdata="mean")
model5_mem.to_pandas().head()


avg_slopes(model5, variables = "size", by = "public").to_pandas()


from marginaleffects import predictions, datagrid
pred = predictions(model5,
                   newdata = datagrid(model5, woj = df["woj"].unique(), size = "Medium", public = "0"))
pred.to_pandas().head()
