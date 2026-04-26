#' ---
#' title: Categorical variables in regression
#' author: Maciej Beręsewicz
#' ---
#' 

install.packages("car")


library(car)


df <- read.csv("data/polish-jvs.csv", colClasses = c("character", "factor", rep("character", 4), "numeric"))
head(df)


levels(df$woj)


df_wrong <- read.csv("data/polish-jvs.csv")
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


df$size <- factor(df$size)
contrasts(df$size)  ## default treatment contrasts


model_treat <- lm(vacancies ~ size, data = df)
summary(model_treat)


## Verify: coefficients equal group mean differences
group_means_size <- aggregate(vacancies ~ size, data = df, FUN = mean)
group_means_size


model_sum_size <- lm(vacancies ~ size, data = df, contrasts = list(size = contr.sum))
summary(model_sum_size)


## Intercept should equal the grand mean of group means
cat("Grand mean of group means:", mean(group_means_size$vacancies), "\n")


## Create ordered factor: Small < Medium < Large
df$size_ord <- ordered(df$size, levels = c("Small", "Medium", "Large"))
model_poly <- lm(vacancies ~ size_ord, data = df)
summary(model_poly)


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


model_anova_ex <- lm(vacancies ~ size * public + woj, data = df)

## Type I: does the order matter?
cat("Type I -- size first:\n")


anova(lm(vacancies ~ size * public + woj, data = df))


cat("\nType I -- woj first:\n")


anova(lm(vacancies ~ woj + size * public, data = df))


## Type II
cat("\nType II (order-independent):\n")


Anova(model_anova_ex, type = "II")


## Type III with sum contrasts
df_ex <- df
df_ex$size <- factor(df_ex$size)
df_ex$public <- factor(df_ex$public)
contrasts(df_ex$size) <- contr.sum(3)
contrasts(df_ex$public) <- contr.sum(2)
model_anova_ex_sum <- lm(vacancies ~ size * public + woj, data = df_ex)
cat("\nType III (sum contrasts):\n")


Anova(model_anova_ex_sum, type = "III")


model_anova_nace <- lm(vacancies ~ size * public + woj + nace, data = df)
cat("Type II with nace:\n")


Anova(model_anova_nace, type = "II")


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
