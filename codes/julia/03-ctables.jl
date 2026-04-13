#' ---
#' title: Contingency tables and Cramer’s V
#' author: Maciej Beręsewicz
#' ---
#' 

using Pkg
Pkg.add(["HypothesisTests", "StatsBase", "CSV", "FreqTables"])


using Random
using Distributions
using HypothesisTests
using StatsBase
using DataFrames
using CSV
using FreqTables


df=CSV.read("../../data/polish-jvs.csv", DataFrame, 
            types = Dict(:id => Int64, :woj=> String, :public=> String, 
                         :size => String, :nace_division => String, :nace => String));
first(df, 5)


df.vac = ifelse.(df.vacancies .> 0, true, false);
tab1=freqtable(df, :size, :vac)


res1=ChisqTest(tab1)


sqrt(res1.stat / sum(tab1))


tab = [1 9;
       5 5]


println("Observed counts:")


display(tab)



# Expected counts
n = sum(tab)


row_sums = sum(tab, dims=2)


col_sums = sum(tab, dims=1)


expected = row_sums * col_sums / n


println("\nExpected counts:")


display(expected)



# Pearson chi-squared (no correction)
pearson = ChisqTest(tab)


pearson_stat = pearson.stat


pearson_p = pvalue(pearson)



# Yates' continuity correction
obs = vec(tab)


exp_counts = vec(expected)


yates_stat = sum((abs.(obs .- exp_counts) .- 0.5).^2 ./ exp_counts)


yates_p = 1 - cdf(Chisq(1), yates_stat)



# G^2 (log-likelihood ratio)
G2 = 2 * sum(obs .* log.(obs ./ exp_counts))


p_G2 = 1 - cdf(Chisq(1), G2)



# Fisher's exact test
fisher = FisherExactTest(tab[1,1], tab[1,2], tab[2,1], tab[2,2])


fisher_p = pvalue(fisher)



results = DataFrame(
    Test      = ["Pearson chi2", "Yates chi2", "G2", "Fisher exact"],
    Statistic = [pearson_stat, yates_stat, G2, missing],
    p_value   = [pearson_p, yates_p, p_G2, fisher_p]
)


println("\n")


display(results)
