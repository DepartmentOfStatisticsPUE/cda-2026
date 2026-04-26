#' ---
#' title: Categorical variables in regression
#' author: Maciej Beręsewicz
#' ---
#' 

import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf


df = pd.read_csv("data/polish-jvs.csv", dtype={"id": np.int64, "woj":str, "public":str,"size": str, "nace_division": str, "nace": str})
df.head()


df_wrong = pd.read_csv("data/polish-jvs.csv")
df_wrong.head()


model1 = smf.ols("vacancies ~ woj", data = df_wrong).fit()
print(model1.summary())


model2 = smf.ols("vacancies ~ woj", data = df).fit()
print(model2.summary())


model3 = smf.ols("vacancies ~ C(woj, Treatment(reference='30'))", data = df).fit()
print(model3.summary())


model4 = smf.ols("vacancies ~ C(woj, Sum)", data = df).fit()
print(model4.summary())


model_treat = smf.ols("vacancies ~ C(size, Treatment)", data=df).fit()
print(model_treat.summary())


## Group means
print(df.groupby("size")["vacancies"].mean())


model_sum_size = smf.ols("vacancies ~ C(size, Sum)", data=df).fit()
print(model_sum_size.summary())


## Polynomial coding requires specifying the order
from patsy import Poly
model_poly = smf.ols("vacancies ~ C(size, Poly)", data=df).fit()
print(model_poly.summary())


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


model_anova_ex = smf.ols("vacancies ~ size * public + woj", data=df).fit()

## Type I: order matters
print("Type I -- size first:")


print(sm.stats.anova_lm(smf.ols("vacancies ~ size * public + woj", data=df).fit(), typ=1))


print("\nType I -- woj first:")


print(sm.stats.anova_lm(smf.ols("vacancies ~ woj + size * public", data=df).fit(), typ=1))


## Type II
print("\nType II:")


print(sm.stats.anova_lm(model_anova_ex, typ=2))


## Type III with sum contrasts
model_anova_ex_sum = smf.ols("vacancies ~ C(size, Sum) * C(public, Sum) + woj", data=df).fit()
print("\nType III (sum contrasts):")


print(sm.stats.anova_lm(model_anova_ex_sum, typ=3))


## Add nace
model_anova_nace = smf.ols("vacancies ~ size * public + woj + nace", data=df).fit()
print("Type II with nace:")


print(sm.stats.anova_lm(model_anova_nace, typ=2))


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
