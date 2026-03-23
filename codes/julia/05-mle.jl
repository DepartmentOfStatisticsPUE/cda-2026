#' ---
#' title: Maximum likelihood estimation
#' author: Maciej Beręsewicz
#' ---
#' 

using Pkg
Pkg.add(["Optim", "Roots"])


using Distributions
using DataFrames
using Random
using Optim
using Roots


## logL - minimization
function ll(par, x)
  par = par[1]
  m = sum(x)*log(par)-length(x)*log(exp(par)-1)
  return -m
end


## gradient
function grad!(G,par,x) 
  par = par[1]
  G[1] = -(sum(x) / par - length(x)*exp(par)/(exp(par)-1))
  return G
end 

## hessian
function hess!(H,par, x)
  par = par[1]
  H[1] = -sum(x)/par^2 + length(x)*exp(par)/(exp(par)-1)^2 
  return H
end

fun_opt = TwiceDifferentiable(par -> ll(par, x), 
                              (G, par) -> grad!(G, par, x), 
                              (H, par) -> hess!(H, par, x), 
                              [0.5])

function grad(par,x) 
  par = par[1]
  g = -(sum(x) / par - length(x)*exp(par)/(exp(par)-1))
  return g
end 



d = [1645,183,37, 13,1,1]
x = vcat(fill.(1:6, d)...)


res = optimize(fun_opt, [0.5])


Optim.minimizer(res)


find_zero(z -> grad(z, x), 0.2)


d = [1645, 183, 37, 13, 1, 1]
x = vcat(fill.(1:6, d)...)

function ll_zt(par, x)
    return -(sum(x) * log(par) - length(x) * log(exp(par) - 1))
end

## Brent's method: bounded scalar optimizer; avoids invalid log(λ<0)
res_mle = optimize(par -> ll_zt(par, x), 0.01, 10.0)
lambda_mle = Optim.minimizer(res_mle)
println("MLE: lambda = ", round(lambda_mle, digits=6))


xbar = mean(x)

function moment_eq(lam)
    return xbar - lam / (1 - exp(-lam))
end

## find_zero: secant method by default for scalar root-finding
lambda_gmm = find_zero(moment_eq, 0.5)
println("GMM (1 moment): lambda = ", round(lambda_gmm, digits=6))


function em_ztpois(x; lambda0=1.0, tol=1e-8, maxiter=100)
    n = length(x)
    sx = sum(x)
    lam = lambda0
    for i in 1:maxiter
        ## E-step
        n0 = n * exp(-lam) / (1 - exp(-lam))
        ## M-step
        lam_new = sx / (n + n0)
        if abs(lam_new - lam) < tol
            return (lambda=lam_new, iterations=i, n0=n0)
        end
        lam = lam_new
    end
    return (lambda=lam, iterations=maxiter, n0=n0)
end

res_em = em_ztpois(x)
println("EM: lambda = ", round(res_em.lambda, digits=6),
        ", iterations = ", res_em.iterations,
        ", estimated n0 = ", round(Int, res_em.n0))


lambda_grid = range(0.20, 0.45, length=200)
ll_func(l) = sum(x) * log(l) - length(x) * log(exp(l) - 1)
ll_vals = [ll_func(l) for l in lambda_grid]
ll_max_val = ll_func(lambda_mle)

## 95% CI via likelihood ratio
cutoff = ll_max_val - quantile(Chisq(1), 0.95) / 2
ci_idx = findall(ll_vals .>= cutoff)
ci_lower = lambda_grid[first(ci_idx)]
ci_upper = lambda_grid[last(ci_idx)]

println("Profile likelihood 95% CI: [", round(ci_lower, digits=4),
        ", ", round(ci_upper, digits=4), "]")


function mu_zt(lam)
    return lam / (1 - exp(-lam))
end

function mu_zt_deriv(lam)
    e = exp(-lam)
    return (1 - e - lam * e) / (1 - e)^2
end

function quasi_score(lam)
    mu = mu_zt(lam)
    dmu = mu_zt_deriv(lam)
    return sum((x .- mu) ./ mu .* dmu)
end

## find_zero: secant method to solve quasi-score equation
lambda_qmle = find_zero(quasi_score, 0.5)

## Sandwich SE
mu_hat = mu_zt(lambda_qmle)
dmu_hat = mu_zt_deriv(lambda_qmle)
bread = sum(dmu_hat^2 / mu_hat)
meat = sum((x .- mu_hat).^2 ./ mu_hat^2 .* dmu_hat^2)
se_qmle = sqrt(meat / bread^2)

println("QMLE: lambda = ", round(lambda_qmle, digits=6),
        ", Sandwich SE = ", round(se_qmle, digits=5))


DataFrame(
    Method = ["MLE", "GMM", "EM", "Profile LR", "QMLE"],
    Lambda = round.([lambda_mle, lambda_gmm, res_em.lambda, lambda_mle, lambda_qmle], digits=6),
    Note = ["Full distribution", "1 moment condition", "Latent zeros", "LR-based CI", "Sandwich SE"]
)
