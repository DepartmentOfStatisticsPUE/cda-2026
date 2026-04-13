#' ---
#' title: Categorical variables in regression
#' author: Maciej Beręsewicz
#' ---
#' 

using Pkg
Pkg.add(["StatsBase", "CSV", "CategoricalArrays", "GLM"])


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


model_treat = lm(@formula(vacancies ~ size), df)  ## default DummyCoding


model_sum_size = lm(@formula(vacancies ~ size), df, contrasts = Dict(:size => EffectsCoding()))


## Julia does not have built-in polynomial coding in StatsModels.jl
## We can construct the contrast matrix manually for 3 ordered levels
using StatsModels
poly_contrasts = [-1/sqrt(2) 1/sqrt(6); 0 -2/sqrt(6); 1/sqrt(2) 1/sqrt(6)]


## Or use HelmertCoding as an alternative for ordered contrasts
model_helm = lm(@formula(vacancies ~ size), df, contrasts = Dict(:size => HelmertCoding()))


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


## Type I via nested models (order matters)
m_null = lm(@formula(vacancies ~ 1), df)


m_size = lm(@formula(vacancies ~ size), df)


m_sp = lm(@formula(vacancies ~ size + public), df)


m_spi = lm(@formula(vacancies ~ size * public), df)


m_spiw = lm(@formula(vacancies ~ size * public + woj), df)


println("Type I (sequential):")


ftest(m_null.model, m_size.model, m_sp.model, m_spi.model, m_spiw.model)


## Model A -- woj treated as numeric (wrong)
model_a = lm(@formula(vacancies ~ woj), df_wrong)


## Model B -- woj treated as factor (correct)
model_b = lm(@formula(vacancies ~ woj), df)


## Compare R-squared
println("R-squared (numeric): ", r2(model_a))


println("R-squared (factor):  ", r2(model_b))
