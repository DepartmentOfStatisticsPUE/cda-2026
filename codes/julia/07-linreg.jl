#' ---
#' title: Categorical variables in regression and marginal effects
#' author: Maciej Beręsewicz
#' ---
#' 

using Pkg
Pkg.add(["Effects", "StatsBase", "CSV", "CategoricalArrays", "GLM"])


using Effects
using StatsBase
using CSV
using CategoricalArrays
using GLM
using Statistics
using DataFrames


df=CSV.read("../../data/polish-jvs.csv", DataFrame,
            types = Dict(:id => String, :woj=> String, :public=> String,
                         :size => String, :nace_division => String, :nace => String));
first(df, 5)


df_wrong=CSV.read("../../data/polish-jvs.csv", DataFrame);
first(df_wrong, 5)


model1 = lm(@formula(vacancies ~ woj), df_wrong)


model2 = lm(@formula(vacancies ~ woj), df)


model3 = lm(@formula(vacancies ~ woj), df, contrasts = Dict(:woj => DummyCoding(base="30")))


model4 = lm(@formula(vacancies ~ woj), df, contrasts = Dict(:woj => EffectsCoding()))


model_int1 = lm(@formula(vacancies ~ size * public), df)


## Cell means
cell_means = combine(groupby(df, [:size, :public]), :vacancies => mean => :mean_vac)
println(cell_means)

## Reconstruct from coefficients
## Note: Julia also uses alphabetical order, so Large is the reference level
b = coef(model_int1)
println("Large, private: ", b[1])
println("Medium, private: ", b[1] + b[2])
println("Small, private: ", b[1] + b[3])
println("Large, public: ", b[1] + b[4])
println("Medium, public: ", b[1] + b[2] + b[4] + b[5])
println("Small, public: ", b[1] + b[3] + b[4] + b[6])


## Type I via nested model comparison
model_null = lm(@formula(vacancies ~ 1), df)
model_size = lm(@formula(vacancies ~ size), df)
model_add  = lm(@formula(vacancies ~ size + public), df)
ftest(model_null.model, model_size.model, model_add.model, model_int1.model)


## Type II via manual model comparisons
## SS(size | public): compare (public) vs (size + public)
model_public = lm(@formula(vacancies ~ public), df)
ftest(model_public.model, model_add.model)

## SS(public | size): compare (size) vs (size + public)
ftest(model_size.model, model_add.model)

## SS(size:public | size, public): compare (size + public) vs (size * public)
ftest(model_add.model, model_int1.model)


## Type III via manual model comparisons
## SS(size | public, size:public): compare (public) vs (size * public)
## This tests whether adding size (and the interaction) improves over public alone
## For a proper Type III test, we need the model without size but with public and interaction
## In practice, Type III tests each term "last" -- for main effects in presence of interaction
## this requires dropping the main effect while keeping the interaction, which is unusual.
## A simpler approach: use the F-statistics from the coefficient table directly.
coeftable(model_int1)


nace_counts = combine(groupby(df, :nace_division), nrow => :n_firms)
df = leftjoin(df, nace_counts, on = :nace_division)
first(df[:, [:nace_division, :size, :n_firms, :vacancies]], 5)


model_par = lm(@formula(vacancies ~ size + n_firms), df)


model_slopes = lm(@formula(vacancies ~ size * n_firms), df)

## Slopes by group
b = coef(model_slopes)
println("Slope for Large: ", b[4])
println("Slope for Medium: ", b[4] + b[5])
println("Slope for Small: ", b[4] + b[6])


df.n_firms_c = df.n_firms .- mean(df.n_firms)

model_cent = lm(@formula(vacancies ~ size * n_firms_c), df)


## R-squared: identical
println("R² (uncentered): ", r2(model_slopes))
println("R² (centered):   ", r2(model_cent))

## Interaction coefficients: identical
println("\nInteraction coefs (uncentered): ", coef(model_slopes)[5:6])
println("Interaction coefs (centered):   ", coef(model_cent)[5:6])

## Main-effect coefficients: different
println("\nMain effects (uncentered): ", coef(model_slopes)[1:3])
println("Main effects (centered):   ", coef(model_cent)[1:3])


df.n_firms_s = (df.n_firms .- mean(df.n_firms)) ./ std(df.n_firms)

model_std = lm(@formula(vacancies ~ size * n_firms_s), df)


model5 = lm(@formula(vacancies ~ woj*size + woj*public), df)


vcat(
  effects(Dict(:woj => sort(unique(df.woj))), model5),
  effects(Dict(:public => sort(unique(df.public))), model5),
  effects(Dict(:size => sort(unique(df.size))), model5),
  cols = :union
)


effects(Dict(:size => sort(unique(df.size))), model5)


effects(Dict(:woj => sort(unique(df.woj)),
             :size => ["Medium"],
             :public => ["0"]), model5)


## Model A -- woj treated as numeric (wrong)
model_a = lm(@formula(vacancies ~ woj), df_wrong)


## Model B -- woj treated as factor (correct)
model_b = lm(@formula(vacancies ~ woj), df)


## Compare R-squared
println("R-squared (numeric): ", r2(model_a))
println("R-squared (factor):  ", r2(model_b))


model6 = lm(@formula(vacancies ~ size * public + woj), df)
println("Number of parameters: ", length(coef(model6)))


effects(Dict(:size => sort(unique(df.size))), model6)


model7 = lm(@formula(vacancies ~ nace + size + public), df)


effects(Dict(:nace => sort(unique(df.nace)),
             :size => ["Medium"],
             :public => ["0"]), model7)


model8 = lm(@formula(vacancies ~ nace * size + public), df)


effects(Dict(:nace => sort(unique(df.nace)),
             :size => ["Medium"],
             :public => ["0"]), model8)
