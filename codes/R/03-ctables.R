#' ---
#' title: Contingency tables and Cramer’s V
#' author: Maciej Beręsewicz
#' ---
#' 

install.packages("vcd")


library(vcd)


df <- read.csv("../../data/polish-jvs.csv", colClasses = c(rep("character", 6), "numeric"))
head(df)


df$vac <- df$vacancies > 0
table(df$size, df$vac)


tab1 <- with(df, table(size, vac))
tab1


prop.table(tab1, margin=1)


prop.table(tab1, margin=1) |> addmargins()


prop.table(tab1, margin=2)


prop.table(tab1, margin=2) |> addmargins()


mosaicplot(tab1)


chisq.test(tab1)


assocstats(tab1) ## vcd


xtabs(~size+vac, df) |> summary()


tab1 |> summary()


tab <- matrix(c(1, 5, 9, 5), nrow = 2, byrow = TRUE,
              dimnames = list(c("Treatment", "Control"),
                              c("Success", "Failure")))
tab


cat("\nExpected counts:\n")


chisq.test(tab, correct = FALSE)$expected


pearson <- chisq.test(tab, correct = FALSE)
yates   <- chisq.test(tab, correct = TRUE)
fisher  <- fisher.test(tab)

obs <- as.vector(tab)
exp_counts <- as.vector(chisq.test(tab, correct = FALSE)$expected)
G2 <- 2 * sum(obs * log(obs / exp_counts))
p_G2 <- 1 - pchisq(G2, df = 1)

results <- data.frame(
  Test      = c("Pearson chi2", "Yates chi2", "G2", "Fisher exact"),
  Statistic = c(pearson$statistic, yates$statistic, G2, NA),
  p_value   = c(pearson$p.value, yates$p.value, p_G2, fisher$p.value)
)
results
