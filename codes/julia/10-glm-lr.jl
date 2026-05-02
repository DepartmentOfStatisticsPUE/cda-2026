#' ---
#' title: "Generalized linear models: logistic regression"
#' author: "Maciej Beręsewicz"
#' ---
#' 

using Pkg
Pkg.add(["GLM", "CSV", "DataFrames", "CategoricalArrays", "Statistics", "StatsBase", "Effects"])


using GLM
using CSV
using DataFrames
using CategoricalArrays
using Statistics
using StatsBase


df = CSV.read("data/polish-jvs.csv", DataFrame,
              types = Dict(:id => String, :woj => String, :public => String,
                           :size => String, :nace_division => String, :nace => String));
df.size        = categorical(df.size, levels = ["Large", "Medium", "Small"]);
df.public      = categorical(df.public);
df.nace        = categorical(df.nace);
df.has_vacancy = ifelse.(df.vacancies .> 0, 1, 0);
first(df, 5)


(n        = nrow(df),
 prop_yes = mean(df.has_vacancy),
 prop_pub = mean(df.public .== "1"))


lpm = lm(@formula(has_vacancy ~ size + public + nace), df)


preds_lpm = predict(lpm)


(min      = round(minimum(preds_lpm), digits = 4),
 max      = round(maximum(preds_lpm), digits = 4),
 n_below0 = sum(preds_lpm .< 0),
 n_above1 = sum(preds_lpm .> 1))


tab = combine(groupby(df, [:public, :has_vacancy]), nrow => :n)


unstack(tab, :public, :has_vacancy, :n)


n11 = sum((df.public .== "1") .& (df.has_vacancy .== 1));
n10 = sum((df.public .== "1") .& (df.has_vacancy .== 0));
n01 = sum((df.public .== "0") .& (df.has_vacancy .== 1));
n00 = sum((df.public .== "0") .& (df.has_vacancy .== 0));
odds_pub  = n11 / n10;
odds_priv = n01 / n00;
(odds_public  = round(odds_pub,  digits = 4),
 odds_private = round(odds_priv, digits = 4),
 OR           = round(odds_pub / odds_priv, digits = 4),
 log_OR       = round(log(odds_pub / odds_priv), digits = 4))


m1 = glm(@formula(has_vacancy ~ public), df, Bernoulli(), LogitLink())


exp.(coef(m1))


m_full = glm(@formula(has_vacancy ~ public + size + nace), df,
             Bernoulli(), LogitLink())


m_logit  = glm(@formula(has_vacancy ~ public + size + nace), df,
               Bernoulli(), LogitLink())


m_probit = glm(@formula(has_vacancy ~ public + size + nace), df,
               Bernoulli(), ProbitLink())


round.(coef(m_logit) ./ coef(m_probit), digits = 3)


pi_hat = predict(m_full)


g_hat  = pi_hat .* (1 .- pi_hat)         # logistic density g(eta) = pi*(1-pi)


beta   = coef(m_full)


ame_public = mean(g_hat) * beta[2]


round(ame_public, digits = 4)


(deviance    = round(deviance(m_full), digits = 1),
 aic         = round(aic(m_full), digits = 1),
 bic         = round(bic(m_full), digits = 1),
 df_residual = dof_residual(m_full))


agg = combine(groupby(df, [:public, :size]),
              :has_vacancy => sum => :yes,
              nrow => :n);
agg.no = agg.n .- agg.yes;
first(agg, 6)
