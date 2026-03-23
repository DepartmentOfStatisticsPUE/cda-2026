#' ---
#' title: Contingency tables and Cramer’s V
#' author: Maciej Beręsewicz
#' ---
#' 

import numpy as np
import scipy.stats as st
import pingouin as pg
import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.graphics.mosaicplot import mosaic
from scipy.stats import chi2_contingency, fisher_exact, chi2


df = pd.read_csv("../../data/polish-jvs.csv", dtype={"id": np.int64, "woj":str, "public":str,"size": str, "nace_division": str, "nace": str})
df.head()


df["vac"] = np.where(df["vacancies"] > 0, True, False)
mosaic(df, ['size', 'vac'])
plt.show()
tab1 = st.contingency.crosstab(df["size"], df["vac"])
row_props = tab1.count / tab1.count.sum(axis=1, keepdims=True)
print(row_props)
col_props = tab1.count / tab1.count.sum(axis=0, keepdims=True)
print(col_props)
res1=st.chi2_contingency(tab1.count)
[res1.statistic, np.sqrt(res1.statistic/np.sum(tab1.count))]
pg.chi2_independence(df, x = "size", y = "vac")


tab = np.array([[1, 9],
                [5, 5]])
tab_df = pd.DataFrame(tab,
                       index=["Treatment", "Control"],
                       columns=["Success", "Failure"])
print(tab_df)

# Expected counts
_, _, _, expected = chi2_contingency(tab, correction=False)
print("\nExpected counts:")
print(pd.DataFrame(expected,
                    index=["Treatment", "Control"],
                    columns=["Success", "Failure"]))

# Pearson chi-squared (no correction)
pearson_stat, pearson_p, _, _ = chi2_contingency(tab, correction=False)

# Yates' continuity correction
yates_stat, yates_p, _, _ = chi2_contingency(tab, correction=True)

# Fisher's exact test
fisher_or, fisher_p = fisher_exact(tab)

# G^2 (log-likelihood ratio)
obs = tab.flatten()
exp_counts = expected.flatten()
G2 = 2 * np.sum(obs * np.log(obs / exp_counts))
p_G2 = 1 - chi2.cdf(G2, df=1)

results = pd.DataFrame({
    "Test":      ["Pearson chi2", "Yates chi2", "G2", "Fisher exact"],
    "Statistic": [pearson_stat, yates_stat, G2, np.nan],
    "p_value":   [pearson_p, yates_p, p_G2, fisher_p]
})
print("\n", results)
