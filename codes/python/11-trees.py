#' ---
#' title: "Classification and regression trees"
#' author: "Maciej Beręsewicz"
#' ---
#' 

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.tree import DecisionTreeRegressor, DecisionTreeClassifier, plot_tree
from sklearn.linear_model import LinearRegression, LogisticRegression
np.random.seed(123)


n = 300
x = np.random.uniform(0, 1, n)
y = np.sin(2 * np.pi * x) + np.random.normal(0, 0.3, n)
X = x.reshape(-1, 1)


fit_lm   = LinearRegression().fit(X, y)
fit_tree = DecisionTreeRegressor(
    max_depth         = 4,   ## hard cap on tree depth; None = grow until pure
    min_samples_split = 20   ## a node with fewer than 20 obs is never split
).fit(X, y)


fig, ax = plt.subplots(figsize = (8, 5))
plot_tree(fit_tree, filled = True, rounded = True, feature_names = ["x"], ax = ax)
plt.show()


xs = np.linspace(0, 1, 400).reshape(-1, 1)
plt.figure(figsize = (7, 4))
plt.scatter(x, y, color = "grey", s = 12)
plt.plot(xs, np.sin(2 * np.pi * xs),  color = "black", lw = 2, label = "truth")
plt.plot(xs, fit_lm.predict(xs),      color = "red",   lw = 2, label = "OLS")
plt.plot(xs, fit_tree.predict(xs),    color = "blue",  lw = 2, label = "tree")
plt.xlabel("x"); plt.ylabel("y"); plt.legend(); plt.title("OLS vs. regression tree")
plt.show()


{"OLS":  float(((y - fit_lm.predict(X))**2).mean()),
 "tree": float(((y - fit_tree.predict(X))**2).mean())}


n = 500
x = np.random.uniform(0, 1, n)
p = 0.5 + 0.4 * np.sin(2 * np.pi * x)
y = np.random.binomial(1, p)
X = x.reshape(-1, 1)


fit_logit = LogisticRegression().fit(X, y)
fit_ctree = DecisionTreeClassifier(
    max_depth        = 4,    ## hard cap on tree depth
    min_samples_leaf = 20    ## every leaf must contain at least 20 obs
).fit(X, y)


fig, ax = plt.subplots(figsize = (8, 5))
plot_tree(fit_ctree, filled = True, rounded = True,
          feature_names = ["x"], class_names = ["0", "1"], ax = ax)
plt.show()


xs = np.linspace(0, 1, 400).reshape(-1, 1)
plt.figure(figsize = (7, 4))
plt.plot(xs, 0.5 + 0.4 * np.sin(2 * np.pi * xs.ravel()),
         color = "black", lw = 2, label = "truth")
plt.plot(xs, fit_logit.predict_proba(xs)[:, 1], color = "red",  lw = 2, label = "logit")
plt.plot(xs, fit_ctree.predict_proba(xs)[:, 1], color = "blue", lw = 2, label = "tree")
plt.scatter(x, y, color = "grey", s = 4)
plt.xlabel("x"); plt.ylabel("P(Y = 1 | x)"); plt.legend()
plt.title("Logistic vs. classification tree")
plt.show()


{"logit": float((fit_logit.predict(X) != y).mean()),
 "tree":  float((fit_ctree.predict(X) != y).mean())}


n = 1000
x1 = np.random.binomial(1, 0.5, n)
x2 = np.random.binomial(1, 0.5, n)
p  = np.where(x1 == x2, 0.85, 0.15)
y  = np.random.binomial(1, p)
X  = np.column_stack([x1, x2])


fit_logit_main = LogisticRegression(C = 1e6).fit(X, y)              ## C = 1 / penalty; large C ≈ unpenalised MLE
X_int = np.column_stack([x1, x2, x1 * x2])                          ## add the x1 * x2 interaction column by hand
fit_logit_int  = LogisticRegression(C = 1e6).fit(X_int, y)
fit_tree3      = DecisionTreeClassifier(max_depth = 2).fit(X, y)    ## depth 2 is exactly enough for a 2x2 XOR


fig, ax = plt.subplots(figsize = (8, 5))
plot_tree(fit_tree3, filled = True, rounded = True,
          feature_names = ["x1", "x2"], class_names = ["0", "1"], ax = ax)
plt.show()


{"logit_main": float((fit_logit_main.predict(X)     != y).mean()),
 "logit_int":  float((fit_logit_int.predict(X_int)  != y).mean()),
 "tree":       float((fit_tree3.predict(X)          != y).mean())}


df = pd.read_csv("data/polish-jvs.csv",
                 dtype = {"id": str, "woj": str, "public": str,
                          "size": str, "nace_division": str, "nace": str})
df["size"]        = pd.Categorical(df["size"], categories = ["Large", "Medium", "Small"])
df["has_vacancy"] = (df["vacancies"] > 0).astype(int)
len(df)


from sklearn.preprocessing import OrdinalEncoder
enc = OrdinalEncoder(categories = [["Large", "Medium", "Small"], ["0", "1"]])
X_toy = enc.fit_transform(df[["size", "public"]].astype(str))
y_toy = df["has_vacancy"].to_numpy()
jvs_toy = DecisionTreeClassifier(max_depth = 2).fit(X_toy, y_toy)   ## depth 2 ⇒ at most 4 leaves; matches the slide
fig, ax = plt.subplots(figsize = (8, 5))
plot_tree(jvs_toy, filled = True, rounded = True,
          feature_names = ["size", "public"], class_names = ["0", "1"], ax = ax)
plt.show()


(df.groupby(["size", "public"], observed = True)
   .agg(n = ("has_vacancy", "size"),
        p_has = ("has_vacancy", "mean"),
        mean_vac = ("vacancies", "mean"))
   .round(3))


from sklearn.tree import DecisionTreeClassifier
features_py = ["size", "public", "nace_division", "woj"]
enc_py = OrdinalEncoder(handle_unknown = "use_encoded_value", unknown_value = -1)
X_py   = enc_py.fit_transform(df[features_py].astype(str))
y_py   = df["has_vacancy"].to_numpy()

tree_full = DecisionTreeClassifier(
    min_samples_leaf = 50,        ## min 50 obs per leaf
    random_state     = 123        ## seed for tie-breaking among splits with equal impurity
)
path = tree_full.cost_complexity_pruning_path(X_py, y_py)    ## returns the (alpha, total_impurity) pruning path
alphas = path.ccp_alphas[::max(1, len(path.ccp_alphas) // 20)]   ## subsample ~20 alphas along the path for a quick scan

scores = []
for a in alphas:
    t = DecisionTreeClassifier(
        min_samples_leaf = 50,
        ccp_alpha        = a,     ## cost-complexity pruning weight; sklearn's name for rpart's `cp`
        random_state     = 123
    )
    t.fit(X_py, y_py)
    scores.append({"alpha": float(a),
                   "leaves": int(t.get_n_leaves()),
                   "train_err": float((t.predict(X_py) != y_py).mean())})


pd.DataFrame(scores)


from sklearn.ensemble import RandomForestClassifier
rf = RandomForestClassifier(
    n_estimators     = 200,   ## number of bootstrap trees in the forest
    min_samples_leaf = 50,    ## min 50 obs per leaf in every tree
    random_state     = 123,   ## seed for bootstrapping and the random feature subset at each split
    n_jobs           = -1     ## -1 = use all available CPU cores
).fit(X_py, y_py)
imp = pd.Series(rf.feature_importances_, index = features_py).sort_values(ascending = False)
imp.round(3)
