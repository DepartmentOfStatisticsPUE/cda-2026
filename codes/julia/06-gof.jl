#' ---
#' title: Goodness of fit statistics
#' author: Maciej Beręsewicz
#' ---
#' 

using Pkg
Pkg.add(["HypothesisTests", "StatsBase"])


using Distributions
using Random
using HypothesisTests
using Optim
using StatsBase
using DelimitedFiles
using DataFrames


Random.seed!(123);
n = 10000;
x = rand(NegativeBinomial(2, 2/(2+3)), n);
mean(x)


x = readdlm("../../data/nb_sim.txt", Int);
x = vec(x);
mean(x)


function llnb(par, data)
  ll = logpdf.(NegativeBinomial(par[1], par[2]), data)
  return -sum(ll)
end



res = optimize(par -> llnb(par, x), [0.01, 0.01], [100.0, 0.99], [2.0, 0.5])


res.minimizer


x_uniq_dict = sort(countmap(x));
x_uniq_vals = Int.(keys(x_uniq_dict));
x_uniq_counts = Int.(values(x_uniq_dict));
x_params = res.minimizer;
est_pmf = pdf.(NegativeBinomial(x_params[1], x_params[2]), x_uniq_vals);
est_pmf = est_pmf ./ sum(est_pmf);


PowerDivergenceTest(x_uniq_counts, lambda = 0.0, theta0 = est_pmf) 


Multinomial Likelihood Ratio Test
---------------------------------
Population details:
    parameter of interest:   Multinomial Probabilities
    value under h_0:         [0.162756, 0.192213, 0.171812, 0.137132, 0.102889, 0.074243, 0.0521512, 0.03592, 0.0243722, 0.0163424, 0.0108539, 0.00715202, 0.0046816, 0.00304727, 0.00197386, 0.00127317, 0.000818163, 0.000334669, 3.4335e-5]
    point estimate:          [0.16, 0.195, 0.17, 0.137, 0.114, 0.068, 0.052, 0.033, 0.019, 0.02, 0.006, 0.014, 0.005, 0.002, 0.001, 0.001, 0.001, 0.001, 0.001]
    95% confidence interval: [(0.131, 0.1891), (0.166, 0.2241), (0.141, 0.1991), (0.108, 0.1661), (0.085, 0.1431), (0.039, 0.09709), (0.023, 0.08109), (0.004, 0.06209), (0.0, 0.04809), (0.0, 0.04909), (0.0, 0.03509), (0.0, 0.04309), (0.0, 0.03409), (0.0, 0.03109), (0.0, 0.03009), (0.0, 0.03009), (0.0, 0.03009), (0.0, 0.03009), (0.0, 0.03009)]

Test summary:
    outcome with 95% confidence: fail to reject h_0
    one-sided p-value:           0.4174

Details:
    Sample size:        1000
    statistic:          18.591632916708782
    degrees of freedom: 18
    residuals:          [-0.216012, 0.200997, -0.138238, -0.0112519, 1.09536, -0.724547, -0.0209416, -0.487213, -1.08818, 0.904765, -1.47332, 2.56064, 0.147156, -0.599932, -0.693168, -0.242094, 0.201031, 1.15008, 5.21144]
    std. residuals:     [-0.236076, 0.223635, -0.151902, -0.0121131, 1.15647, -0.75304, -0.02151, -0.496206, -1.10169, 0.91225, -1.48139, 2.56985, 0.147502, -0.600848, -0.693853, -0.242248, 0.201113, 1.15028, 5.21153]


1-cdf(Chisq(16), 18.591632916708782)


PowerDivergenceTest(x_uniq_counts, lambda = 1.0, theta0 = est_pmf)


Pearson's Chi-square Test
-------------------------
Population details:
    parameter of interest:   Multinomial Probabilities
    value under h_0:         [0.162756, 0.192213, 0.171812, 0.137132, 0.102889, 0.074243, 0.0521512, 0.03592, 0.0243722, 0.0163424, 0.0108539, 0.00715202, 0.0046816, 0.00304727, 0.00197386, 0.00127317, 0.000818163, 0.000334669, 3.4335e-5]
    point estimate:          [0.16, 0.195, 0.17, 0.137, 0.114, 0.068, 0.052, 0.033, 0.019, 0.02, 0.006, 0.014, 0.005, 0.002, 0.001, 0.001, 0.001, 0.001, 0.001]
    95% confidence interval: [(0.131, 0.1891), (0.166, 0.2241), (0.141, 0.1991), (0.108, 0.1661), (0.085, 0.1431), (0.039, 0.09709), (0.023, 0.08109), (0.004, 0.06209), (0.0, 0.04809), (0.0, 0.04909), (0.0, 0.03509), (0.0, 0.04309), (0.0, 0.03409), (0.0, 0.03109), (0.0, 0.03009), (0.0, 0.03009), (0.0, 0.03009), (0.0, 0.03009), (0.0, 0.03009)]

Test summary:
    outcome with 95% confidence: reject h_0
    one-sided p-value:           0.0010

Details:
    Sample size:        1000
    statistic:          42.242072813765624
    degrees of freedom: 18
    residuals:          [-0.216012, 0.200997, -0.138238, -0.0112519, 1.09536, -0.724547, -0.0209416, -0.487213, -1.08818, 0.904765, -1.47332, 2.56064, 0.147156, -0.599932, -0.693168, -0.242094, 0.201031, 1.15008, 5.21144]
    std. residuals:     [-0.236076, 0.223635, -0.151902, -0.0121131, 1.15647, -0.75304, -0.02151, -0.496206, -1.10169, 0.91225, -1.48139, 2.56985, 0.147502, -0.600848, -0.693853, -0.242248, 0.201113, 1.15028, 5.21153]


1-cdf(Chisq(16), 42.242072813765624)


X = vcat([fill(i-1,n) for (i, n) in enumerate([100,50,15,5,1])]...);
X_tab = sort(countmap(X));
lambda_hat = mean(X);
n_hat = length(X) * pdf.(Poisson(lambda_hat), 0:4);
r_hat = (values(X_tab) .- n_hat) ./ sqrt.(n_hat);
X_dt = DataFrame(X = 0:4, n = values(X_tab).*1, n_hat = n_hat, r_hat = r_hat)


## fit NB
function llnb_jl(par, data)
  ll = logpdf.(NegativeBinomial(par[1], par[2]), data)
  return -sum(ll)
end



res_nb = optimize(par -> llnb_jl(par, X), [0.01, 0.01], [100.0, 0.99], [2.0, 0.5])


nb_params = Optim.minimizer(res_nb)



## log-likelihoods
ll_po = sum(logpdf.(Poisson(lambda_hat), X))


ll_nb = -Optim.minimum(res_nb)



## AIC and BIC
n_obs = length(X)


AIC_po = 2*1 - 2*ll_po


AIC_nb = 2*2 - 2*ll_nb


BIC_po = log(n_obs)*1 - 2*ll_po


BIC_nb = log(n_obs)*2 - 2*ll_nb



println("AIC: Poisson = ", round(AIC_po, digits=4), ", NB = ", round(AIC_nb, digits=4))


println("BIC: Poisson = ", round(BIC_po, digits=4), ", NB = ", round(BIC_nb, digits=4))



## LR test (Poisson nested in NB)
LR_test = 2*ll_nb - 2*ll_po


LR_pval = 1 - cdf(Chisq(1), LR_test)


println("LR test: ", round(LR_test, digits=4), ", p-value: ", round(LR_pval, digits=4))
