#' ---
#' title: Discrete distributions
#' author: Maciej Beręsewicz
#' ---
#' 

install.packages("distributions3")


library(distributions3)


set.seed(20230228)
rbinom(n=10,size=1,prob=0.7)


set.seed(20230228)
rbinom(n=10,size=50,prob=0.7)


set.seed(20230228)
rpois(n=10,lambda=1.5)


rpois(10,1.5)


set.seed(20230228)
X <- Bernoulli(0.7)
random(X, 10)


set.seed(20230228)
X <- Binomial(50, 0.7)
random(X, 10)


set.seed(20230228)
X <- Poisson(1.5)
random(X, 10)


## read data and filter 3 sections
jvs <- read.csv("../../data/polish-jvs.csv")
jvs3 <- jvs[jvs$nace %in% c("C", "G", "P"), ]

## step 1: estimate per-entity lambdas, total rates (Lambda), and pi
lambda_hat <- tapply(jvs3$vacancies, jvs3$nace, mean)
n_entities <- tapply(jvs3$vacancies, jvs3$nace, length)
Lambda_hat <- n_entities * lambda_hat  ## total Poisson rates
pi_hat <- Lambda_hat / sum(Lambda_hat)
lambda_hat


Lambda_hat


pi_hat


## step 2: simulate 1000 independent Poisson draws per section
set.seed(123)
n_sim <- 1000
sim_C <- rpois(n_sim, Lambda_hat["C"])
sim_G <- rpois(n_sim, Lambda_hat["G"])
sim_P <- rpois(n_sim, Lambda_hat["P"])

## conditional proportions (exclude cases where total = 0)
totals <- sim_C + sim_G + sim_P
valid <- totals > 0
cond_prop <- data.frame(
  C = mean(sim_C[valid] / totals[valid]),
  G = mean(sim_G[valid] / totals[valid]),
  P = mean(sim_P[valid] / totals[valid])
)
## compare with theoretical pi
rbind(simulated = unlist(cond_prop), theoretical = pi_hat)


## step 3: multinomial -- expected vs observed
obs_totals <- tapply(jvs3$vacancies, jvs3$nace, sum)
n_total <- sum(obs_totals)
expected <- n_total * pi_hat

rbind(observed = obs_totals, expected = expected)


## simulate from multinomial
set.seed(123)
mult_draws <- rmultinom(1000, size = n_total, prob = pi_hat)
rownames(mult_draws) <- names(pi_hat)
## compare means of multinomial draws with observed
data.frame(
  observed = obs_totals,
  mult_mean = rowMeans(mult_draws)
)
