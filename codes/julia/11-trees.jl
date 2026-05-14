#' ---
#' title: "Classification and regression trees"
#' author: "Maciej Beręsewicz"
#' ---
#' 

using Pkg
Pkg.add(["DecisionTree", "GLM", "DataFrames", "CSV", "CategoricalArrays",
         "Statistics", "Random", "Plots", "Distributions"])


using DecisionTree
using GLM
using DataFrames
using CSV
using CategoricalArrays
using Statistics
using Random
using Distributions
Random.seed!(123);


n = 300;
x = rand(n);
y = sin.(2 * pi .* x) .+ randn(n) .* 0.3;
X = reshape(x, n, 1);


fit_lm   = lm(@formula(y ~ x), DataFrame(x = x, y = y));
fit_tree = DecisionTreeRegressor(
    max_depth         = 4,    ## hard cap on tree depth; -1 = grow until pure
    min_samples_split = 20    ## a node with fewer than 20 obs is never split
);
DecisionTree.fit!(fit_tree, X, y);


print_tree(fit_tree, 3)


yhat_lm   = GLM.predict(fit_lm);
yhat_tree = DecisionTree.predict(fit_tree, X);
(OLS  = mean((y .- yhat_lm).^2),
 tree = mean((y .- yhat_tree).^2))


n = 500;
x = rand(n);
p = 0.5 .+ 0.4 .* sin.(2 * pi .* x);
y = Int.(rand(n) .< p);
X = reshape(x, n, 1);


fit_logit = glm(@formula(y ~ x), DataFrame(x = x, y = y), Binomial(), LogitLink());
fit_ctree = DecisionTreeClassifier(
    max_depth        = 4,     ## hard cap on tree depth
    min_samples_leaf = 20     ## every leaf must contain at least 20 obs
);
DecisionTree.fit!(fit_ctree, X, y);


print_tree(fit_ctree, 3)


yhat_logit = Int.(GLM.predict(fit_logit) .> 0.5);
yhat_tree  = DecisionTree.predict(fit_ctree, X);
(logit = mean(yhat_logit .!= y),
 tree  = mean(yhat_tree  .!= y))


n = 1000;
x1 = rand(0:1, n);
x2 = rand(0:1, n);
p  = ifelse.(x1 .== x2, 0.85, 0.15);
y  = Int.(rand(n) .< p);
X  = hcat(x1, x2);


df3 = DataFrame(x1 = x1, x2 = x2, y = y);
fit_logit_main = glm(@formula(y ~ x1 + x2), df3, Binomial(), LogitLink());   ## main effects only -> blind to XOR


fit_logit_int  = glm(@formula(y ~ x1 * x2), df3, Binomial(), LogitLink());   ## "x1 * x2" expands to x1 + x2 + x1&x2


fit_tree3 = DecisionTreeClassifier(max_depth = 2);                           ## depth 2 is exactly enough for a 2x2 XOR


DecisionTree.fit!(fit_tree3, X, y);


print_tree(fit_tree3, 3)


yhat_main = Int.(GLM.predict(fit_logit_main) .> 0.5);
yhat_int  = Int.(GLM.predict(fit_logit_int)  .> 0.5);
yhat_tree = DecisionTree.predict(fit_tree3, X);
(logit_main = mean(yhat_main .!= y),
 logit_int  = mean(yhat_int  .!= y),
 tree       = mean(yhat_tree .!= y))


df = CSV.read("data/polish-jvs.csv", DataFrame,
              types = Dict(:id => String, :woj => String, :public => String,
                           :size => String, :nace_division => String, :nace => String));
df.size        = categorical(df.size, levels = ["Large", "Medium", "Small"]);
df.public      = categorical(df.public);
df.has_vacancy = ifelse.(df.vacancies .> 0, 1, 0);
nrow(df)


size_code   = levelcode.(df.size);
public_code = levelcode.(df.public);
X_toy = hcat(size_code, public_code);             ## ";" suppresses printing the 57480x2 matrix


y_toy = df.has_vacancy;
jvs_toy = DecisionTreeClassifier(max_depth = 2)   ## depth 2 ⇒ at most 4 leaves; matches the slide


DecisionTree.fit!(jvs_toy, X_toy, y_toy);
print_tree(jvs_toy, 3)                            ## second argument = max depth to print (truncates display, not the model)


combine(groupby(df, [:size, :public]),
        nrow => :n,
        :has_vacancy => mean => :p_has,
        :vacancies   => mean => :mean_vac)


size_c = levelcode.(df.size);
pub_c  = levelcode.(df.public);
nace_c = levelcode.(categorical(df.nace_division));
woj_c  = levelcode.(categorical(df.woj));
X_full = hcat(size_c, pub_c, nace_c, woj_c);          ## ";" suppresses the big matrix print


y_full = df.has_vacancy;

depths = [2, 4, 6, 8, 10]


results = DataFrame(max_depth = Int[], train_err = Float64[])


for d in depths
    t = DecisionTreeClassifier(
        max_depth        = d,    ## sweep depth as a proxy for cost-complexity pruning (DecisionTree.jl has no ccp_alpha)
        min_samples_leaf = 50    ## min 50 obs per leaf
    )
    DecisionTree.fit!(t, X_full, y_full)
    push!(results, (d, mean(DecisionTree.predict(t, X_full) .!= y_full)))
end
results


rf = RandomForestClassifier(
    n_trees          = 200,    ## number of trees in the forest
    partial_sampling = 0.7,    ## fraction of training rows used to grow each tree (bootstrap subsample fraction)
    min_samples_leaf = 50      ## min 50 obs per leaf in every tree
);
DecisionTree.fit!(rf, X_full, y_full);
mean(DecisionTree.predict(rf, X_full) .!= y_full)
