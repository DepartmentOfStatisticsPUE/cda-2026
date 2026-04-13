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


df = pd.read_csv("../../data/polish-jvs.csv", dtype={"id": np.int64, "woj":str, "public":str,"size": str, "nace_division": str, "nace": str})
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


model6 = smf.ols("vacancies ~ size * public + woj", data = df).fit()
print(f"Number of parameters: {len(model6.params)}")


avg_slopes(model6, variables = "size").to_pandas()


avg_slopes(model6, variables = "size", by = "public").to_pandas()


model7 = smf.ols("vacancies ~ nace + size + public", data = df).fit()


from marginaleffects import predictions, datagrid
pred7 = predictions(model7,
                    newdata = datagrid(model7, nace = df["nace"].unique(), size = "Medium", public = "0"))
pred7_df = pred7.to_pandas().sort_values("estimate", ascending=False)
print("Top 3:", pred7_df.head(3)[["nace", "estimate"]].to_string())


print("Bottom 3:", pred7_df.tail(3)[["nace", "estimate"]].to_string())


model8 = smf.ols("vacancies ~ nace * size + public", data = df).fit()
pred8 = predictions(model8,
                    newdata = datagrid(model8, nace = df["nace"].unique(), size = "Medium", public = "0"))
pred8.to_pandas().sort_values("estimate", ascending=False).head(3)[["nace", "estimate"]]
