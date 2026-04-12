#' ---
#' title: Categorical variables in regression and marginal effects
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


df_wrong = pd.read_csv("../../data/polish-jvs.csv")
df_wrong.head()


model1 = smf.ols("vacancies ~ woj", data = df_wrong).fit()
print(model1.summary())


model2 = smf.ols("vacancies ~ woj", data = df).fit()
print(model2.summary())


model3 = smf.ols("vacancies ~ C(woj, Treatment(reference='30'))", data = df).fit()
print(model3.summary())


model4 = smf.ols("vacancies ~ C(woj, Sum)", data = df).fit()
print(model4.summary())


model_int1 = smf.ols("vacancies ~ size * public", data = df).fit()
print(model_int1.summary())


## Cell means
cell_means = df.groupby(["size", "public"])["vacancies"].mean()
print(cell_means)

## Reconstruct from coefficients
## Note: Python/statsmodels uses alphabetical order, so Large is the reference level
b = model_int1.params
print(f"Large, private: {b['Intercept']:.4f}")
print(f"Medium, private: {b['Intercept'] + b['size[T.Medium]']:.4f}")
print(f"Small, private: {b['Intercept'] + b['size[T.Small]']:.4f}")
print(f"Large, public: {b['Intercept'] + b['public[T.1]']:.4f}")
print(f"Medium, public: {b['Intercept'] + b['size[T.Medium]'] + b['public[T.1]'] + b['size[T.Medium]:public[T.1]']:.4f}")
print(f"Small, public: {b['Intercept'] + b['size[T.Small]'] + b['public[T.1]'] + b['size[T.Small]:public[T.1]']:.4f}")


## Type I (sequential)
print(sm.stats.anova_lm(model_int1, typ=1))


## Type II
print(sm.stats.anova_lm(model_int1, typ=2))


## Type III
print(sm.stats.anova_lm(model_int1, typ=3))

## Type III with sum contrasts
model_int1_sum = smf.ols("vacancies ~ C(size, Sum) * C(public, Sum)", data = df).fit()
print(sm.stats.anova_lm(model_int1_sum, typ=3))


nace_counts = df.groupby("nace_division").size().reset_index(name="n_firms")
df = df.merge(nace_counts, on="nace_division")
print(df[["nace_division", "size", "n_firms", "vacancies"]].head())


model_par = smf.ols("vacancies ~ size + n_firms", data = df).fit()
print(model_par.summary())


model_slopes = smf.ols("vacancies ~ size * n_firms", data = df).fit()
print(model_slopes.summary())

## Slopes by group
b = model_slopes.params
print(f"Slope for Large: {b['n_firms']:.6f}")
print(f"Slope for Medium: {b['n_firms'] + b['size[T.Medium]:n_firms']:.6f}")
print(f"Slope for Small: {b['n_firms'] + b['size[T.Small]:n_firms']:.6f}")


df["n_firms_c"] = df["n_firms"] - df["n_firms"].mean()

model_cent = smf.ols("vacancies ~ size * n_firms_c", data = df).fit()
print(model_cent.summary())


## R-squared: identical
print(f"R² (uncentered): {model_slopes.rsquared:.6f}")
print(f"R² (centered):   {model_cent.rsquared:.6f}")

## Interaction coefficients: identical
print(f"\nInteraction coefs (uncentered):")
print(model_slopes.params.filter(like=":"))
print(f"Interaction coefs (centered):")
print(model_cent.params.filter(like=":"))

## Main-effect coefficients: different
print(f"\nMain effects (uncentered):")
print(model_slopes.params.iloc[:3])
print(f"Main effects (centered):")
print(model_cent.params.iloc[:3])


df["n_firms_s"] = (df["n_firms"] - df["n_firms"].mean()) / df["n_firms"].std()

model_std = smf.ols("vacancies ~ size * n_firms_s", data = df).fit()
print(model_std.summary())


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


## Model A -- woj treated as numeric (wrong)
model_a = smf.ols("vacancies ~ woj", data = df_wrong).fit()
print(f"R-squared (numeric): {model_a.rsquared:.6f}")
print(f"Number of parameters: {len(model_a.params)}")


## Model B -- woj treated as factor (correct)
model_b = smf.ols("vacancies ~ woj", data = df).fit()
print(f"R-squared (factor): {model_b.rsquared:.6f}")
print(f"Number of parameters: {len(model_b.params)}")


## Verify coefficients equal group mean differences
group_means = df.groupby("woj")["vacancies"].mean()
ref_mean = group_means.iloc[0]
comparison = pd.DataFrame({
    "group_mean": group_means,
    "diff_from_ref": group_means - ref_mean,
    "coef": model_b.params.values
})
comparison.head()


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
