#' ---
#' title: Marginal effects
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
