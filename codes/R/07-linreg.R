#' ---
#' title: Categorical variables in regression and marginal effects
#' author: Maciej Beręsewicz
#' ---
#' 

install.packages("marginaleffects")
install.packages("car")


library(marginaleffects)
library(car)


df <- read.csv("../../data/polish-jvs.csv", colClasses = c("character", "factor", rep("character", 4), "numeric"))
head(df)


levels(df$woj)


df_wrong <- read.csv("../../data/polish-jvs.csv")
head(df_wrong)


model1 <- lm(vacancies ~ woj, data = df_wrong)
summary(model1)


model2 <- lm(vacancies ~ woj, data = df)
summary(model2)


tab1 <- aggregate(vacancies ~ woj, data = df, FUN = mean)
tab1$coef_by_hand <- with(tab1, vacancies-vacancies[1])
tab1$coef <- coef(model2)
head(tab1)


model3 <- lm(vacancies ~ relevel(woj, ref = "30"), data = df)
summary(model3)


model4 <- lm(formula = vacancies ~ woj, data = df, contrasts = list(woj = contr.sum))
summary(model4)


mean(tab1$vacancies)


model_int1 <- lm(vacancies ~ size * public, data = df)
summary(model_int1)


## Cell means
cell_means <- aggregate(vacancies ~ size + public, data = df, FUN = mean)
cell_means

## Reconstruct from coefficients
## Note: R uses alphabetical order, so Large is the reference level
b <- coef(model_int1)
cat("Large, private:", b[1], "\n")
cat("Medium, private:", b[1] + b[2], "\n")
cat("Small, private:", b[1] + b[3], "\n")
cat("Large, public:", b[1] + b[4], "\n")
cat("Medium, public:", b[1] + b[2] + b[4] + b[5], "\n")
cat("Small, public:", b[1] + b[3] + b[4] + b[6], "\n")


## Type I (sequential) -- note: order matters!
anova(model_int1)


## Type II
Anova(model_int1, type = "II")


## Type III -- with treatment contrasts (default)
Anova(model_int1, type = "III")

## Type III with sum contrasts for interpretability
df_sum <- df
df_sum$size <- factor(df_sum$size)
df_sum$public <- factor(df_sum$public)
contrasts(df_sum$size) <- contr.sum(3)
contrasts(df_sum$public) <- contr.sum(2)
model_int1_sum <- lm(vacancies ~ size * public, data = df_sum)
Anova(model_int1_sum, type = "III")


nace_counts <- as.data.frame(table(df$nace_division))
names(nace_counts) <- c("nace_division", "n_firms")
df <- merge(df, nace_counts, by = "nace_division")
df$n_firms <- as.numeric(df$n_firms)
head(df[, c("nace_division", "size", "n_firms", "vacancies")])


model_par <- lm(vacancies ~ size + n_firms, data = df)
summary(model_par)


model_slopes <- lm(vacancies ~ size * n_firms, data = df)
summary(model_slopes)

## Slopes by group
b <- coef(model_slopes)
cat("Slope for Large:", b["n_firms"], "\n")
cat("Slope for Medium:", b["n_firms"] + b["sizeMedium:n_firms"], "\n")
cat("Slope for Small:", b["n_firms"] + b["sizeSmall:n_firms"], "\n")


df$n_firms_c <- df$n_firms - mean(df$n_firms)

model_cent <- lm(vacancies ~ size * n_firms_c, data = df)
summary(model_cent)


## R-squared: identical
cat("R² (uncentered):", summary(model_slopes)$r.squared, "\n")
cat("R² (centered):  ", summary(model_cent)$r.squared, "\n")

## Interaction coefficients: identical
cat("\nInteraction coefs (uncentered):\n")
print(coef(model_slopes)[5:6])
cat("Interaction coefs (centered):\n")
print(coef(model_cent)[5:6])

## Main-effect coefficients: different
cat("\nMain effects (uncentered):\n")
print(coef(model_slopes)[1:3])
cat("Main effects (centered):\n")
print(coef(model_cent)[1:3])

## Fitted values: identical
cat("\nFitted values identical?", all.equal(fitted(model_slopes), fitted(model_cent)), "\n")


df$n_firms_s <- as.numeric(scale(df$n_firms))

model_std <- lm(vacancies ~ size * n_firms_s, data = df)
summary(model_std)


model5 <- lm(vacancies ~ woj*size + woj*public, df)
summary(model5)


avg_slopes(model5)


avg_slopes(model5, newdata = "mean")


avg_slopes(model5, variables = "size", by = "public")


predictions(model5,
            newdata = datagrid(woj = unique(df$woj), size = "Medium", public = "0"))


## Model A -- woj treated as numeric (wrong)
model_a <- lm(vacancies ~ woj, data = df_wrong)
summary(model_a)


## Model B -- woj treated as factor (correct)
model_b <- lm(vacancies ~ woj, data = df)
summary(model_b)


## Compare R-squared
cat("R-squared (numeric):", summary(model_a)$r.squared, "\n")
cat("R-squared (factor): ", summary(model_b)$r.squared, "\n")


## Verify coefficients equal group mean differences
group_means <- aggregate(vacancies ~ woj, data = df, FUN = mean)
group_means$diff_from_ref <- group_means$vacancies - group_means$vacancies[1]
group_means$coef <- coef(model_b)
head(group_means)


model6 <- lm(vacancies ~ size * public + woj, data = df)
summary(model6)


cat("Number of parameters:", length(coef(model6)), "\n")


avg_slopes(model6, variables = "size")


avg_slopes(model6, variables = "size", by = "public")


model7 <- lm(vacancies ~ nace + size + public, data = df)
summary(model7)


pred7 <- predictions(model7,
                     newdata = datagrid(nace = unique(df$nace), size = "Medium", public = "0"))
pred7 <- as.data.frame(pred7)
pred7_sorted <- pred7[order(-pred7$estimate), c("nace", "estimate")]
head(pred7_sorted, 3)
tail(pred7_sorted, 3)


model8 <- lm(vacancies ~ nace * size + public, data = df)


pred8_medium <- predictions(model8,
                            newdata = datagrid(nace = unique(df$nace), size = "Medium", public = "0"))
pred8_large <- predictions(model8,
                           newdata = datagrid(nace = unique(df$nace), size = "Large", public = "0"))
pred8_medium <- as.data.frame(pred8_medium)
pred8_large <- as.data.frame(pred8_large)
cat("Top 3 NACE (Medium):\n")
head(pred8_medium[order(-pred8_medium$estimate), "nace"], 3)
cat("Top 3 NACE (Large):\n")
head(pred8_large[order(-pred8_large$estimate), "nace"], 3)
