#' ---
#' title: "Classification and regression trees"
#' author: "Maciej Beręsewicz"
#' ---
#' 

install.packages("rpart")
install.packages("rpart.plot")
install.packages("partykit")


library(rpart)
library(rpart.plot)
library(partykit)

set.seed(123)
n <- 300
x <- runif(n)
y <- sin(2 * pi * x) + rnorm(n, sd = 0.3)
d1 <- data.frame(x = x, y = y)


fit_lm   <- lm(y ~ x, data = d1)
set.seed(2026)
fit_tree <- rpart(y ~ x, data = d1,
                  method = "anova",                ## "anova" = regression tree (SSR splits); use "class" for classification
                  control = rpart.control(
                    cp       = 0.01,               ## complexity threshold: refuse a split unless it cuts the (scaled) error by >= cp
                    minsplit = 20))                ## a node with fewer than 20 obs is never split


rpart.plot(fit_tree, type = 4, extra = 1, digits = 2)


xs <- seq(0, 1, length = 400)
yhat_lm   <- predict(fit_lm,   newdata = data.frame(x = xs))
yhat_tree <- predict(fit_tree, newdata = data.frame(x = xs))

plot(x, y, pch = 19, col = "grey60", cex = 0.7,
     xlab = "x", ylab = "y", main = "OLS vs. regression tree")
lines(xs, sin(2 * pi * xs), col = "black", lwd = 2)
lines(xs, yhat_lm,   col = "red",  lwd = 2)
lines(xs, yhat_tree, col = "blue", lwd = 2)
legend("topright",
       legend = c("truth", "OLS", "rpart"),
       col    = c("black", "red", "blue"),
       lwd = 2, bty = "n")


c(OLS  = mean((d1$y - predict(fit_lm))^2),
  tree = mean((d1$y - predict(fit_tree))^2))

## exercise 1
set.seed(123)
n <- 300
x <- runif(n)
y <- (x - 0.5)^2 + rnorm(n, sd = 0.3)
d2 <- data.frame(x = x, y = y)
fit_lm2   <- lm(y ~ x, data = d2)
fit_lm2.1   <- lm(y ~ x + I(x^2), data = d2)
fit_tree2 <- rpart(y ~ x, data = d2,
                  method = "anova", 
                  control = rpart.control(
                    cp       = 0.01,
                    minsplit = 20))  
rpart.plot(fit_tree2, type = 4, extra = 1, digits = 2)

c(OLS  = mean((d2$y - predict(fit_lm2))^2),
  OLS_2  = mean((d2$y - predict(fit_lm2.1))^2),
  tree = mean((d2$y - predict(fit_tree2))^2))

xs <- seq(0, 1, length = 400)
fit_lm2.1   <- predict(fit_lm2.1,   newdata = data.frame(x = xs))
yhat_tree2 <- predict(fit_tree2, newdata = data.frame(x = xs))

plot(x, y, pch = 19, col = "grey60", cex = 0.7,
     xlab = "x", ylab = "y", main = "OLS vs. regression tree")
lines(xs, (xs - 0.5)^2, col = "black", lwd = 2)
lines(xs, fit_lm2.1,   col = "red",  lwd = 2)
lines(xs, yhat_tree2, col = "blue", lwd = 2)
legend("topright",
       legend = c("truth", "OLS", "rpart"),
       col    = c("black", "red", "blue"),
       lwd = 2, bty = "n")


####
set.seed(123)
n <- 500
x <- runif(n)
p <- 0.5 + 0.4 * sin(2 * pi * x)
y <- rbinom(n, size = 1, prob = p)
d2 <- data.frame(x = x, y = factor(y))


fit_logit <- glm(y ~ x, data = d2, family = binomial())
fit_ctree <- rpart(y ~ x, data = d2,
                   method = "class",                ## "class" = classification tree (Gini splits by default)
                   control = rpart.control(
                     cp        = 0.005,             ## smaller cp than the default 0.01 -> allow a deeper tree
                     minbucket = 20))               ## every leaf must contain at least 20 obs


rpart.plot(fit_ctree, type = 4, extra = 104, digits = 3)


xs <- seq(0, 1, length = 400)
p_logit <- predict(fit_logit, newdata = data.frame(x = xs), type = "response")
p_tree  <- predict(fit_ctree, newdata = data.frame(x = xs), type = "prob")[, "1"]

plot(xs, 0.5 + 0.4 * sin(2 * pi * xs),
     type = "l", lwd = 2, ylim = c(0, 1),
     xlab = "x", ylab = "P(Y = 1 | x)", main = "Logistic vs. classification tree")
lines(xs, p_logit, col = "red",  lwd = 2)
lines(xs, p_tree,  col = "blue", lwd = 2)
points(x, as.numeric(as.character(d2$y)), pch = "|", col = "grey60")
legend("topright",
       legend = c("truth", "logit", "tree"),
       col    = c("black", "red", "blue"),
       lwd = 2, bty = "n")


err_logit <- mean((predict(fit_logit, type = "response") > 0.5) != (d2$y == "1"))
err_tree  <- mean(predict(fit_ctree, type = "class") != d2$y)
c(logit = err_logit, tree = err_tree)


n <- 1000
x1 <- rbinom(n, 1, 0.5)
x2 <- rbinom(n, 1, 0.5)
p  <- ifelse(x1 == x2, 0.85, 0.15)
y  <- rbinom(n, 1, p)
d3 <- data.frame(x1 = factor(x1), x2 = factor(x2), y = factor(y))


addmargins(prop.table(table(x1 = d3$x1, x2 = d3$x2, y = d3$y), c(1, 2)), 3)


fit_logit_main <- glm(y ~ x1 + x2,    data = d3, family = binomial())   ## main effects only -> blind to XOR
fit_logit_int  <- glm(y ~ x1 * x2,    data = d3, family = binomial())   ## "x1 * x2" expands to x1 + x2 + x1:x2
fit_tree3      <- rpart(y ~ x1 + x2,  data = d3, method = "class")      ## defaults: cp = 0.01, minsplit = 20, minbucket = round(minsplit/3)


rpart.plot(fit_tree3, type = 4, extra = 104, digits = 3)


err <- function(pred, y) mean(pred != y)
c(logit_main = err(predict(fit_logit_main, type = "response") > 0.5, d3$y == "1"),
  logit_int  = err(predict(fit_logit_int,  type = "response") > 0.5, d3$y == "1"),
  tree       = err(predict(fit_tree3, type = "class"), d3$y))


df <- read.csv("data/polish-jvs.csv",
               colClasses = c("character", "factor", rep("character", 4), "numeric"))
df$size        <- factor(df$size, levels = c("Large", "Medium", "Small"))
df$public      <- factor(df$public)
df$nace        <- factor(df$nace)
df$has_vacancy <- as.integer(df$vacancies > 0)
nrow(df)


## Gotcha: with method = "class" on a heavily imbalanced binary outcome
## (88% zeros), rpart's cp filter is based on misclassification cost.
## Because no single split flips the majority class in any leaf, every
## split is scored as "zero improvement" and rpart returns the root only.
## Fix: fit as a regression tree on the 0/1 indicator -- for binary Y the
## SSR criterion is equivalent to Gini (var(Y) = p(1 - p) = Gini / 2).
jvs_toy <- rpart(has_vacancy ~ size + public, data = df,
                 method = "anova",                  ## regression on 0/1 = Gini classification for binary Y
                 control = rpart.control(
                   maxdepth = 2,                    ## stop at depth 2 (root = depth 0)
                   cp       = 0))                   ## let depth (not cp) bind; leaf values are p(has_vacancy = 1)
rpart.plot(jvs_toy, type = 4, extra = 101, digits = 3)


aggregate(cbind(n = rep(1, nrow(df)),
                p_has = df$has_vacancy,
                mean_vac = df$vacancies)
          ~ size + public, data = df, FUN = sum) -> .agg
within(.agg, {p_has <- p_has / n; mean_vac <- mean_vac / n})


## Same gotcha as above: fit as anova on the 0/1 indicator so that rpart
## actually grows a tree on this heavily imbalanced outcome.
jvs_big <- rpart(has_vacancy ~ size + public + nace_division + woj, data = df,
                 method = "anova",                  ## regression on 0/1; leaf values are p(has_vacancy = 1)
                 control = rpart.control(
                   cp        = 0.0005,              ## very small cp -> grow an over-large tree, prune it back below
                   minbucket = 50))                 ## min 50 obs per leaf, otherwise the deeper splits are unstable
printcp(jvs_big)                                    ## CV table of (cp, |T|, train error, xerror, xstd)


plotcp(jvs_big)                                     ## visualises the same table with the 1-SE bar


cp1se <- jvs_big$cptable[, "CP"][which.min(jvs_big$cptable[, "xerror"])]
jvs_pruned <- prune(jvs_big, cp = cp1se)
c(leaves_full   = sum(jvs_big$frame$var == "<leaf>"),
  leaves_pruned = sum(jvs_pruned$frame$var == "<leaf>"))


ct <- partykit::ctree(factor(has_vacancy) ~ size + public + nace,
                      data = df,
                      control = partykit::ctree_control(
                        maxdepth     = 3,           ## maximum tree depth
                        mincriterion = 0.99))       ## 1 - p-value cut-off; only split when the permutation test p < 0.01
print(ct)
