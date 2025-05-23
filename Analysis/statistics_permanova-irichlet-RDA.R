# R script to run univariate and multivariate PERMANOVAs, Dirichlet regression, and RDA. 
# install.packages("readxl")
# install.packages("dplyr")
# install.packages("vegan")
# install.packages("DirichletReg")

library(readxl)
library(dplyr)
library(vegan)
library(DirichletReg)
library(car) 
library(ggplot2)
library(tidyr)
library(lubridate)

url <- "https://raw.githubusercontent.com/sannatitus/Afruca-tangeri_captive-behaviour/main/Data/instantaneous-behaviour-raw-data.csv"
df <- read_csv(url)
sessionInfo()
warnings()

df_active <- df %>% filter(`crab ID` != "NV")

active_instant_order <- c(
  'foraging',
  'walking', 'entering seawater', 'exiting seawater', 'vertical extension',
  'maintaining burrow', 'entering burrow', 'exiting burrow', 'protecting burrow',
  'attacking burrow', 'defending burrow', 'threat encounter',
  'shoreline resting', 'mudbank resting',
  'submerged', 
  'burrowing'
)

df_active <- df_active %>% filter(`instantaneous behaviour` %in% active_instant_order)

# Aggregate by crab ID, video file, and observation window 
agg <- df_active %>%
  group_by(`video file`, `selected observation period start`, `crab ID`, `instantaneous behaviour`) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(`video file`, `selected observation period start`, `crab ID`) %>%
  mutate(total_obs = sum(count),
         proportion = count / total_obs) %>%
  ungroup()

# Pivot to wide format (behaviours as columns, proportions as values)
behaviour_wide <- agg %>%
  select(`video file`, `selected observation period start`, `crab ID`, `instantaneous behaviour`, proportion) %>%
  pivot_wider(names_from = `instantaneous behaviour`, values_from = proportion, values_fill = 0) %>%
  { .[, c("video file", "selected observation period start", "crab ID", active_instant_order)] }

# Aggregate predictors, including new variables
predictors <- df_active %>%
  group_by(`video file`, `selected observation period start`, `crab ID`) %>%
  summarise(
    crabitat = first(crabitat),
    `day type` = first(`day type`),
    # Human visible: Y if any minute in the window is Y, else N
    `human visible` = ifelse(any(`human visible?` == "Y"), "Y", "N"),
    photoperiod = first(photoperiod),
    `tide type` = first(`tide type`),
    `tide regime` = first(`tide regime`),
    present.population = first(`present population`),
    calculated.sex.ratio = first(ifelse(`present females` == 0, `present males`,
                                        ifelse(`present males` == 0, 0, `present males` / `present females`))),
    sex = first(sex),
    hour.of.day = first(hour(`real time`))
  ) %>% ungroup()

behaviour_data <- behaviour_wide %>%
  left_join(predictors, by = c("video file", "selected observation period start", "crab ID"))

Y <- as.matrix(behaviour_data[, active_instant_order])
X <- behaviour_data %>%
  select(
    crabitat, `day type`, `human visible`,
    photoperiod, `tide type`, `tide regime`,
    present.population, calculated.sex.ratio, hour.of.day, sex
  )

# Set up behavioural categories 
behaviour_category <- c(
  'foraging' = 'foraging',
  'walking' = 'locomotion',
  'entering seawater' = 'locomotion',
  'exiting seawater' = 'locomotion',
  'vertical extension' = 'locomotion',
  'attacking burrow' = 'conspecific contact',
  'defending burrow' = 'conspecific contact',
  'threat encounter' = 'conspecific contact',
  'maintaining burrow' = 'burrow activity',
  'entering burrow' = 'burrow activity',
  'exiting burrow' = 'burrow activity',
  'protecting burrow' = 'burrow activity',
  'shoreline resting' = 'resting',
  'mudbank resting' = 'resting',
  'submerged' = 'submerged',
  'burrowing' = 'burrowing'
)

df_active$behaviour_category <- dplyr::recode(df_active$`instantaneous behaviour`, !!!behaviour_category)

agg_cat <- df_active %>%
  group_by(`video file`, `selected observation period start`, `crab ID`, behaviour_category) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(`video file`, `selected observation period start`, `crab ID`) %>%
  mutate(total_obs = sum(count),
         proportion = count / total_obs) %>%
  ungroup()

cat_order <- c('foraging', 'locomotion', 'burrow activity', 'conspecific contact', 'resting', 'submerged', 'burrowing')
cat_wide <- agg_cat %>%
  select(`video file`, `selected observation period start`, `crab ID`, behaviour_category, proportion) %>%
  pivot_wider(names_from = behaviour_category, values_from = proportion, values_fill = 0) %>%
  { .[, c("video file", "selected observation period start", "crab ID", cat_order)] }

cat_data <- cat_wide %>%
  left_join(predictors, by = c("video file", "selected observation period start", "crab ID"))

###################################################
# DATA FIT TEST (for PERMANOVA) 
###################################################
# For instantaneous behaviours
bc_dist <- vegdist(Y, method = "bray")

## For each categorical variable:
cat_vars <- c("crabitat", "day type", "human visible", "photoperiod", "tide type", "tide regime", "sex")
for (var in cat_vars) {
  disp <- betadisper(bc_dist, X[[var]])
  print(paste("Testing dispersion for", var))
  print(anova(disp))
  plot(disp, main = paste("Dispersion for", var))
}

## Collinierity (numeric predictors only)
num_vars <- c("present.population", "calculated.sex.ratio", "hour.of.day")
print("Correlation matrix for numeric predictors:")
print(cor(X[, num_vars], use = "complete.obs"))

## For all predictors (VIF, requires factors to be numeric or dummy-coded)
X_vif <- X
for (var in cat_vars) {
  X_vif[[var]] <- as.numeric(as.factor(X_vif[[var]]))
}
vif_model <- lm(present.population ~ . , data = X_vif)  # Use any numeric variable as response
print("Variance Inflation Factors (VIF):")
print(vif(vif_model))

## Group sizes (categorical predictors)
for (var in cat_vars) {
  print(paste("Group sizes for", var))
  print(table(X[[var]]))
}

## Zero-inflation in response matrix
print("Summary of Y (behaviour matrix):")
print(summary(as.vector(Y)))
hist(as.vector(Y), breaks = 50, main = "Distribution of behaviour proportions", xlab = "Proportion")

## Sample size per group (for categorical predictors)
for (var in cat_vars) {
  group_sizes <- table(X[[var]])
  if (any(group_sizes < 5)) {
    warning(paste("Some groups in", var, "have fewer than 5 samples!"))
  }
}

## Check for missing data
print("Any missing values in predictors?")
print(colSums(is.na(X)))
print("Any missing values in Y?")
print(sum(is.na(Y)))

cat("\nDiagnostics complete. Review outputs above for any issues before interpreting PERMANOVA results.\n")

cat("Data diagnostics for instantaneous behaviours:\nData diagnostics indicated that most assumptions for PERMANOVA and related multivariate analyses were met:\nThere was no missing data in predictors or response variables, and all categorical groups had sufficient sample sizes (nmin=33).\nThe behaviour matrix was zero-inflated, with the majority of instantaneous behaviour proportions within a given window at or near zero (see Supplementary Figure X), which is typical for behavioural datasets and was addressed by using Bray-Curtis dissimilarity and a small fill value for Dirichlet regression.\nTests for homogeneity of multivariate dispersion (betadisper) revealed significant differences in dispersion for crabitat, photoperiod, and tide regime (p < 0.001), indicating that PERMANOVA results for these variables may partially reflect differences in within-group variance rather than group centroids alone. Dispersion was homogeneous for all other categorical predictors (p > 0.05).\nCollinearity diagnostics showed moderate to high variance inflation factors (VIF) for crabitat (VIF = 7.9) and tide regime (VIF = 9.6), suggesting redundancy among predictors. Correlations among numeric predictors were all below 0.7.")

# Based on these diagnostics for instantaneous behaviours, crabitat and tide regime were excluded from subsequent multivariate models to reduce collinearity, while photoperiod was retained as a key ecological variable. All other predictors were retained for further analysis.

# Check for behavioural categories
cat_order <- c('foraging', 'locomotion', 'burrow activity', 'conspecific contact', 'resting', 'submerged', 'burrowing')
Y_cat <- as.matrix(cat_data[, cat_order])
X_cat <- cat_data %>%
  select(
    crabitat, `day type`, `human visible`,
    photoperiod, `tide type`, `tide regime`,
    present.population, calculated.sex.ratio, hour.of.day, sex
  )

## Homogeneity of multivariate dispersion
bc_dist_cat <- vegdist(Y_cat, method = "bray")
cat_vars <- c("crabitat", "day type", "human visible", "photoperiod", "tide type", "tide regime", "sex")
for (var in cat_vars) {
  disp <- betadisper(bc_dist_cat, X_cat[[var]])
  print(paste("Testing dispersion for", var, "(behavioural categories)"))
  print(anova(disp))
  plot(disp, main = paste("Dispersion for", var, "(behavioural categories)"))
}

## Collinearity (numeric predictors only)
num_vars_cat <- c("present.population", "calculated.sex.ratio", "hour.of.day")
print("Correlation matrix for numeric predictors (behavioural categories):")
print(cor(X_cat[, num_vars_cat], use = "complete.obs"))

## VIF for all predictors
X_vif_cat <- X_cat
for (var in cat_vars) {
  X_vif_cat[[var]] <- as.numeric(as.factor(X_vif_cat[[var]]))
}
vif_model_cat <- lm(present.population ~ . , data = X_vif_cat)
print("Variance Inflation Factors (VIF) (behavioural categories):")
print(vif(vif_model_cat))

## Group sizes (categorical predictors)
for (var in cat_vars) {
  print(paste("Group sizes for", var, "(behavioural categories)"))
  print(table(X_cat[[var]]))
}

## Zero-inflation in response matrix
print("Summary of Y (behavioural categories matrix):")
print(summary(as.vector(Y_cat)))
hist(as.vector(Y_cat), breaks = 50, main = "Distribution of behaviour category proportions", xlab = "Proportion")

## Sample size per group (for categorical predictors)
for (var in cat_vars) {
  group_sizes <- table(X_cat[[var]])
  if (any(group_sizes < 5)) {
    warning(paste("Some groups in", var, "have fewer than 5 samples!"))
  }
}

## Check for missing data
print("Any missing values in predictors? (behavioural categories)")
print(colSums(is.na(X_cat)))
print("Any missing values in Y? (behavioural categories)")
print(sum(is.na(Y_cat)))

cat("\nDiagnostics complete for behavioural categories. Review outputs above for any issues before interpreting PERMANOVA or related results.\n")

cat("Data diagnostics for instantaneous behaviours = Data diagnostics for instantaneous behaviours") 

###################################################
# PERMANOVA (adonis2)
###################################################
# Istantaneous behaviours
## Univariate PERMANOVA for each predictor
#adonis2(Y ~ crabitat, data = X, permutations = 999)
adonis2(Y ~ `day type`, data = X, permutations = 999)
adonis2(Y ~ `human visible`, data = X, permutations = 999)
adonis2(Y ~ photoperiod, data = X, permutations = 999)
adonis2(Y ~ `tide type`, data = X, permutations = 999)
#adonis2(Y ~ `tide regime`, data = X, permutations = 999)
adonis2(Y ~ present.population, data = X, permutations = 999)
adonis2(Y ~ calculated.sex.ratio, data = X, permutations = 999)
adonis2(Y ~ hour.of.day, data = X, permutations = 999)
adonis2(Y ~ sex, data = X, permutations = 999)

## Multivariate PERMANOVA using Bray-Curtis dissimilarity
permanova_result <- adonis2(
  Y ~ `day type` + `human visible` + photoperiod + `tide type` + 
    present.population + calculated.sex.ratio + hour.of.day + sex,
  data = X, permutations = 999
)
print(permanova_result)

## Marginal PERMANOVA using Bray-Curtis dissimilarity
permanova_margin <- adonis2(
  Y ~ `day type` + `human visible` + photoperiod + `tide type` + 
    present.population + calculated.sex.ratio + hour.of.day + sex,
  data = X, permutations = 999, by = "margin"
)
print(permanova_margin)

# Behavioural categories

## Univariate PERMANOVA for each predictor (behavioural categories)
#adonis2(Y_cat ~ `day type`, data = X_cat, permutations = 999)
#adonis2(Y_cat ~ `human visible`, data = X_cat, permutations = 999)
#adonis2(Y_cat ~ photoperiod, data = X_cat, permutations = 999)
#adonis2(Y_cat ~ `tide type`, data = X_cat, permutations = 999)
## adonis2(Y_cat ~ `tide regime`, data = X_cat, permutations = 999)
#adonis2(Y_cat ~ present.population, data = X_cat, permutations = 999)
#adonis2(Y_cat ~ calculated.sex.ratio, data = X_cat, permutations = 999)
#adonis2(Y_cat ~ hour.of.day, data = X_cat, permutations = 999)
#adonis2(Y_cat ~ sex, data = X_cat, permutations = 999)

predictors <- c("day type", "human visible", "photoperiod", "tide type", 
                "present.population", "calculated.sex.ratio", "hour.of.day", "sex")

sink("permanova_univariate_summary.txt")
cat("Univariate PERMANOVA results (behavioural categories):\n\n")

for (pred in predictors) {
  formula_str <- paste0("Y_cat ~ `", pred, "`")
  cat("Predictor: ", pred, "\n")
  result <- adonis2(as.formula(formula_str), data = X_cat, permutations = 999)
  print(result)
  cat("\n")
}
### Save 
sink()

## Multivariate PERMANOVA using Bray-Curtis dissimilarity (behavioural categories)
permanova_result_cat <- adonis2(
  Y_cat ~ `day type` + `human visible` + photoperiod + `tide type` +
    present.population + calculated.sex.ratio + hour.of.day + sex,
  data = X_cat, permutations = 999
)
print(permanova_result_cat)

## Marginal PERMANOVA (behavioural categories)
permanova_margin_cat <- adonis2(
  Y_cat ~ `day type` + `human visible` + photoperiod + `tide type` +
    present.population + calculated.sex.ratio + hour.of.day + sex,
  data = X_cat, permutations = 999, by = "margin"
)
print(permanova_margin_cat)

## Save for beahvioural categories 
sink("permanova_multivariate_summary.txt"); summary(permanova_result_cat); sink()
sink("permanova_marginal_summary.txt"); summary(permanova_margin_cat); sink()

############################################
# Dirichlet Regresssion 
############################################
# instantaneous behaviours
## Replace zeros with a small value (Dirichlet regression cannot handle zeros)
Y_dirichlet <- as.matrix(behaviour_data[, active_instant_order])
Y_dirichlet[Y_dirichlet == 0] <- 1e-6
Y_dirichlet <- DR_data(Y_dirichlet)

dirichlet_model_instant <- DirichReg(
  Y_dirichlet ~ `day type` + `human visible` + photoperiod + `tide type` +
    present.population + calculated.sex.ratio + hour.of.day + sex,
  data = behaviour_data
)
summary(dirichlet_model_instant)
plot(dirichlet_model_instant)

# behavioural categories

Y_cat_dirichlet <- as.matrix(cat_data[, cat_order])
Y_cat_dirichlet[Y_cat_dirichlet == 0] <- 1e-6
Y_cat_dirichlet <- DR_data(Y_cat_dirichlet)

dirichlet_model_cat <- DirichReg(
  Y_cat_dirichlet ~ `day type` + `human visible` + photoperiod + `tide type` +
    present.population + calculated.sex.ratio + hour.of.day + sex,
  data = cat_data
)
summary(dirichlet_model_cat)
plot(dirichlet_model_cat)

### Save for behavioural categories 
sink("dirichlet_model_summary.txt"); summary(dirichlet_model_cat); sink()

############################################
# RDA (behavioural categories only)
############################################
## Data fit check for constant columns in Y_cat (all zeros or all the same value)
apply(Y_cat, 2, function(x) length(unique(x)))

rda_predictors <- X_cat %>%
  select(`day type`, `human visible`, photoperiod, `tide type`,
         present.population, calculated.sex.ratio, hour.of.day, sex)

## Convert categorical predictors to factors 
rda_predictors$`day type` <- as.factor(rda_predictors$`day type`)
rda_predictors$`human visible` <- as.factor(rda_predictors$`human visible`)
rda_predictors$photoperiod <- as.factor(rda_predictors$photoperiod)
rda_predictors$`tide type` <- as.factor(rda_predictors$`tide type`)
rda_predictors$sex <- as.factor(rda_predictors$sex)

rda_cat <- rda(Y_cat ~ ., data = rda_predictors)

summary(rda_cat)
png("rda.png", width = 1200, height = 900, res = 150)
plot(rda_cat, scaling = 2, main = "RDA of Behaviour Categories")
dev.off()

## Permutation test for significance of the model
anova(rda_cat, permutations = 999)
anova(rda_cat, by = "axis", permutations = 999)
anova(rda_cat, by = "term", permutations = 999)

### Save 
sink("rda_summary.txt")
summary(rda_cat)
sink()


######################################
#CCA (behavioural categories only)
######################################
# Sticking with RDA (above). Gradient length analysis (DCA1 = 3.38) indicated that both linear (RDA) and unimodal (CCA) ordination methods are justifiable. We present RDA as the primary analysis due to the compositional nature of the data and ease of interpretation, but note that CCA yielded similar results
dca <- decorana(Y_cat)
print(dca) # Look at the lengths of the first axis (if < 3, RDA is preferred. It was 3.38, so both are justifiable)

cca_predictors <- X_cat %>%
  select(`day type`, `human visible`, photoperiod, `tide type`,
         present.population, calculated.sex.ratio, hour.of.day, sex)

cca_predictors$`day type` <- as.factor(cca_predictors$`day type`)
cca_predictors$`human visible` <- as.factor(cca_predictors$`human visible`)
cca_predictors$photoperiod <- as.factor(cca_predictors$photoperiod)
cca_predictors$`tide type` <- as.factor(cca_predictors$`tide type`)
cca_predictors$sex <- as.factor(cca_predictors$sex)

cca_cat <- cca(Y_cat ~ ., data = cca_predictors)

summary(cca_cat)
plot(cca_cat, scaling = 2, main = "CCA of Behaviour Categories")

anova(cca_cat, permutations = 999)
anova(cca_cat, by = "axis", permutations = 999)
anova(cca_cat, by = "term", permutations = 999)

#sink("cca_behaviour_categories_summary.txt")
#summary(cca_cat)
#sink()

