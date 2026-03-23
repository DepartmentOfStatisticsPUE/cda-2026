#' ---
#' title: Categorical data
#' author: Maciej Beręsewicz
#' ---
#' 

df <- data.frame(group = c("A", "B", "C", "B", "A"))
df$group_B <- as.integer(df$group == "B")
df$group_C <- as.integer(df$group == "C")
df


df$group <- factor(df$group)   # reference: A (alphabetical)
model.matrix(~ group, data = df)


df$group <- relevel(df$group, ref = "B")
model.matrix(~ group, data = df)


df <- data.frame(group = factor(c("A", "B", "C", "B", "A")))
contrasts(df$group)


contrasts(df$group) <- contr.treatment(3)
model.matrix(~ group, data = df)


# effects (sum) coding
contrasts(df$group) <- contr.sum(3)
model.matrix(~ group, data = df)


# polynomial coding (ordinal only!)
df$size <- factor(c("S", "M", "L", "M", "S"),
                  levels   = c("S", "M", "L"),
                  ordered  = TRUE)
contrasts(df$size) <- contr.poly(3)
model.matrix(~ size, data = df)
