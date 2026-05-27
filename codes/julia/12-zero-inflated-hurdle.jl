#' ---
#' title: "Generalized linear models: zero-inflated and hurdle models"
#' author: "Maciej Beręsewicz"
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


df=CSV.read("data/polish-jvs.csv", DataFrame,
            types = Dict(:id => Int64, :woj=> String, :public=> String,
                         :size => String, :nace_division => String, :nace => String));
first(df, 5)
