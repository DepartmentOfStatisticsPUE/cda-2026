#' ---
#' title: Categorical data
#' author: Maciej Beręsewicz
#' ---
#' 

import pandas as pd

df = pd.DataFrame({"group": ["A", "B", "C", "B", "A"]})
df["group_B"] = (df["group"] == "B").astype(int)
df["group_C"] = (df["group"] == "C").astype(int)
df


from patsy import dmatrix

df["group"] = pd.Categorical(df["group"])   # reference: A (alphabetical)
dmatrix("C(group)", df, return_type="dataframe")


dmatrix("C(group, Treatment(reference='B'))", df, return_type="dataframe")


import pandas as pd
from patsy import dmatrix

df = pd.DataFrame({"group": pd.Categorical(["A", "B", "C", "B", "A"])})

# treatment (default)
dmatrix("C(group)", df, return_type="dataframe")


# treatment coding -- explicit
dmatrix("C(group, Treatment)", df, return_type="dataframe")


# effects (sum) coding
dmatrix("C(group, Sum)", df, return_type="dataframe")


# polynomial coding (ordinal only!)
df["size"] = pd.Categorical(["S", "M", "L", "M", "S"],
                             categories=["S", "M", "L"],
                             ordered=True)
dmatrix("C(size, Poly)", df, return_type="dataframe")
