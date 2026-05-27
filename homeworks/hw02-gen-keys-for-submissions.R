#!/usr/bin/env Rscript
## Generate HW02 keys for the actual submission IDs (email prefixes).
## Usage: Rscript hw02-gen-keys-for-submissions.R <id1> <id2> ...

suppressPackageStartupMessages({
  library(MASS)
  library(marginaleffects)
})

## Read student IDs from a file path supplied as first arg (one ID per line).
args <- commandArgs(trailingOnly = TRUE)
ids_path <- args[1]
ids <- as.integer(readLines(ids_path))
ids <- ids[!is.na(ids)]
cat("Generating keys for", length(ids), "students:", paste(ids, collapse=", "), "\n")

results_hw02 <- lapply(ids, function(sid) {
  set.seed(sid)
  N <- 1500
  size <- factor(
    sample(c("Small","Medium","Large"), N, replace = TRUE,
           prob = c(0.5, 0.3, 0.2)),
    levels = c("Small","Medium","Large")
  )
  region <- factor(sample(c("North","South","East","West"), N, replace = TRUE),
                   levels = c("North","South","East","West"))
  loyalty_program <- rbinom(N, 1, 0.4)
  experience_years <- runif(N, 0, 20)
  size_eff   <- c(Small = 0, Medium = 5, Large = 12)[as.character(size)]
  region_eff <- c(North = 0, South = 3, East = -2, West = 1)[as.character(region)]
  monthly_revenue <- 20 + size_eff + region_eff +
    2 * loyalty_program + 0.5 * experience_years +
    0.3 * loyalty_program * experience_years + rnorm(N, 0, 5)
  mu_c <- exp(0.8 + 0.2 * (size == "Large") - 0.1 * (size == "Small"))
  complaints <- rnbinom(N, mu = mu_c, size = 2)
  retail <- data.frame(size, region, loyalty_program, experience_years,
                       complaints, monthly_revenue)

  x <- retail$complaints
  x_mean <- mean(x); x_var <- var(x); disp <- x_var / x_mean
  lam <- x_mean
  grp <- factor(ifelse(x >= 4, "4+", as.character(x)),
                levels = c("0","1","2","3","4+"))
  obs <- as.integer(table(grp))
  p_theo <- c(dpois(0:3, lam), 1 - ppois(3, lam))
  exp_f <- N * p_theo
  chi2  <- sum((obs - exp_f)^2 / exp_f)
  df    <- length(obs) - 1 - 1
  pval  <- pchisq(chi2, df, lower.tail = FALSE)
  fit_pois <- glm(complaints ~ 1, family = poisson, data = retail)
  fit_nb   <- tryCatch(glm.nb(complaints ~ 1, data = retail),
                       error = function(e) NULL)
  aic_pois <- AIC(fit_pois)
  aic_nb   <- if (is.null(fit_nb)) NA_real_ else AIC(fit_nb)

  m1 <- lm(monthly_revenue ~ size + region + loyalty_program + experience_years,
           data = retail)
  retail_sum <- retail
  contrasts(retail_sum$size) <- contr.sum(3)
  m2 <- lm(monthly_revenue ~ size + region + loyalty_program + experience_years,
           data = retail_sum)
  retail_wref <- retail
  retail_wref$region <- relevel(retail_wref$region, ref = "West")
  m3 <- lm(monthly_revenue ~ size + region + loyalty_program + experience_years,
           data = retail_wref)
  m4 <- lm(monthly_revenue ~ size + region + loyalty_program * experience_years,
           data = retail)

  ame_all <- avg_slopes(m4, variables = "experience_years")
  ame_by  <- avg_slopes(m4, variables = "experience_years", by = "loyalty_program")
  pred <- predictions(
    m4,
    newdata = datagrid(size = "Small", region = "North",
                       loyalty_program = 0, experience_years = 10)
  )

  data.frame(
    student_id                   = sid,
    disp_index                   = round(disp, 4),
    pois_lambda                  = round(lam, 4),
    chi2_stat                    = round(chi2, 4),
    chi2_df                      = df,
    chi2_pval                    = round(pval, 6),
    pois_aic                     = round(aic_pois, 4),
    nb_aic                       = round(aic_nb, 4),
    lm_r2                        = round(summary(m1)$r.squared, 4),
    size_medium_coef             = round(coef(m1)[["sizeMedium"]], 4),
    sum_intercept                = round(coef(m2)[["(Intercept)"]], 4),
    sum_size1_coef               = round(coef(m2)[["size1"]], 4),
    region_north_coef_releveled  = round(coef(m3)[["regionNorth"]], 4),
    interaction_coef             = round(coef(m4)[["loyalty_program:experience_years"]], 4),
    ame_exp                      = round(ame_all$estimate, 4),
    ame_exp_loyal0               = round(ame_by$estimate[ame_by$loyalty_program == 0], 4),
    ame_exp_loyal1               = round(ame_by$estimate[ame_by$loyalty_program == 1], 4),
    pred_small_north_nolp_exp10  = round(pred$estimate, 4)
  )
})

key <- do.call(rbind, results_hw02)
out_path <- "hw02-answer-key-emailids.csv"
write.csv(key, out_path, row.names = FALSE)
cat("Saved", out_path, "with", nrow(key), "rows\n")
