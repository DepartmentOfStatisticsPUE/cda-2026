#' ---
#' title: Discrete distributions
#' author: Maciej Beręsewicz
#' ---
#' 

using Pkg
Pkg.add(["DataFrames", "Distributions"])


using DataFrames
using Distributions
using Random


Random.seed!(20230228);
rand(Bernoulli(0.7),10)


Random.seed!(20230228);
rand(Binomial(50,0.7),10)


Random.seed!(20230228);
rand(Poisson(1.5),10)


























using CSV, DataFrames, Distributions, Random, Statistics

## read data and filter 3 sections
jvs = CSV.read("../../data/polish-jvs.csv", DataFrame)
jvs3 = filter(r -> r.nace in ["C", "G", "P"], jvs)

## step 1: estimate per-entity lambdas, total rates (Lambda), and pi
lambda_hat = combine(groupby(jvs3, :nace),
    :vacancies => mean => :lambda,
    :vacancies => length => :n_entities)
sort!(lambda_hat, :nace)
lambda_hat.Lambda = lambda_hat.n_entities .* lambda_hat.lambda  ## total Poisson rates
lambda_hat.pi = lambda_hat.Lambda ./ sum(lambda_hat.Lambda)
lambda_hat


## step 2: simulate 1000 independent Poisson draws per section
Random.seed!(123)
n_sim = 1000
sims = Dict(r.nace => rand(Poisson(r.Lambda), n_sim) for r in eachrow(lambda_hat))
totals = sims["C"] .+ sims["G"] .+ sims["P"]
valid = totals .> 0

cond_prop = Dict(s => mean(sims[s][valid] ./ totals[valid]) for s in ["C", "G", "P"])
println("Simulated: ", cond_prop)
println("Theoretical: ", Dict(r.nace => round(r.pi, digits=4) for r in eachrow(lambda_hat)))


## step 3: multinomial -- expected vs observed
obs_totals = combine(groupby(jvs3, :nace), :vacancies => sum => :total)
sort!(obs_totals, :nace)
n_total = sum(obs_totals.total)
expected = n_total .* lambda_hat.pi

DataFrame(nace = lambda_hat.nace, observed = obs_totals.total, expected = round.(expected, digits=1))
