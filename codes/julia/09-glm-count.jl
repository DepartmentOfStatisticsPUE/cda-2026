#' ---
#' title: "Generalized linear models: count data"
#' author: "Maciej Beręsewicz"
#' ---
#' 

using Pkg
Pkg.add(["GLM", "CSV", "DataFrames", "CategoricalArrays", "Statistics", "StatsBase"])


using GLM
using CSV
using DataFrames
using CategoricalArrays
using Statistics
using StatsBase


df = CSV.read("data/polish-jvs.csv", DataFrame,
              types = Dict(:id => String, :woj => String, :public => String,
                           :size => String, :nace_division => String, :nace => String));
df.size   = categorical(df.size, levels = ["Large", "Medium", "Small"]);
df.public = categorical(df.public);
df.nace   = categorical(df.nace);
first(df, 5)


(mean      = mean(df.vacancies),
 var       = var(df.vacancies),
 prop_zero = mean(df.vacancies .== 0))


ols = lm(@formula(vacancies ~ size + public + nace), df)


preds_ols = predict(ols)


println("Min OLS prediction: ", round(minimum(preds_ols), digits = 3))


println("Number negative   : ", sum(preds_ols .< 0), " out of ", length(preds_ols))


function fit_log_c(c_val)
    df.log_y = log.(df.vacancies .+ c_val)
    m = lm(@formula(log_y ~ size + public), df)
    return exp.(coef(m))
end



(c_1    = fit_log_c(1),
 c_05   = fit_log_c(0.5),
 c_0001 = fit_log_c(0.001))


pois_simple = glm(@formula(vacancies ~ size + public), df, Poisson(), LogLink())


exp.(coef(pois_simple))


pois = glm(@formula(vacancies ~ size + public + nace), df, Poisson(), LogLink())


exp.(coef(pois))


mu_hat = predict(pois)


phi_jl = sum((df.vacancies .- mu_hat) .^ 2 ./ mu_hat) / dof_residual(pois)


round(phi_jl, digits = 2)


nb2 = negbin(@formula(vacancies ~ size + public + nace), df, LogLink())


using Effects
effects(Dict(:size => ["Large", "Medium", "Small"]), pois)
