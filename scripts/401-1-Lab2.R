#--------------------------------------------------------------------------#
# Lab 2
# 401-1-Lab2.R
# 12/19/2021
# Rose Werth, Northwestern University
# Ewurama Okai, Northwestern University
#
# TOPICS: Using scatterplots to assess associations between two variables,
# correlation, basic linear regression code, residuals
#--------------------------------------------------------------------------#


# Set-up ------------------------------------------------------------------

# Load libraries
library(tidyverse)
library(ggplot2)
library(corrr)

# Load data
  load("data_raw/SOC401_W21_Billionaires_v2.rda")

# Rename dataframe to something simpler
# This also keeps the original dataset, untouched, in the environment
  mydata <- SOC401_W21_Billionaires_v2


# Evaluation associations with scatterplots -------------------------------
# In linear regression, we assume that there is a linear relationship between
# our continuous variables and our outcome variable. To verify this, we need
# to check the relationship between y and x. One way to do this is to
# create a scatter graph that visualizes them together.

# Remind myself of the variable names
  names(mydata)

# Scatterplot using ggplot2
# This makes a basic scatter graph of y (dependent variable) on x
# (independent variable). It allows you to gauge - from initial glance -
# whether there is a linear relationship between y and x.
  ggplot(data = mydata, aes(y = wealthworthinbillions, x = age)) +
    geom_point() +
    theme_minimal()

# Linear of Best Fit
# But sometimes, we can't detect a relationship by eye. We need some extra help
# to see the linear association. To do that, we will add a "line of best fit" to
# the graph.
# Note: We are assuming the relationship is linear, so R is fitting a linear
# line of best fit, even if the relationship isn't linear.
  ggplot(data = mydata, aes(y = wealthworthinbillions, x = age)) +
    geom_point() +
    geom_smooth(method = "lm", se = FALSE) + # adds line using linear formula,
  # se = FALSE removes the confidene interval around the line.
    theme_minimal()

# Lowess Smoothing Curve
# If we are worried the relationship is not linear, we can add a 'lowess' curve
# on our graph. The important thing to remember about this command is that it
# creates a line that is weighted to the data. This means it accounts for
# outliers to reveal whether there are aspects of your data that deviate from
# linearity / shows if the relationship isn't linear.
  ggplot(data = mydata, aes(y = wealthworthinbillions, x = age)) +
    geom_point() +
    geom_smooth(method = "loess", se = FALSE) + # adds line using linear formula,
  # se = FALSE removes the confidene interval around the line.
    theme_minimal()

  # RESEARCH NOTE
  # Evaluating linearity - as with many aspects of quantitative research -
  # involves subjective interpretation. Does the result of our previous
  # lowess curve count as a 'linear' relationship? What wouldn't count as
  # linear?

  # Overall, we can judge this line to look pretty close to linear.


# Correlation -------------------------------------------------------------
# Another way we might evaluate for linear regression is the correlation
# between your IV and DV variables. We will also use these commands to look at
# the relationship between various independent variables to make sure they
# do not violate the assumption of independence (collinearity).

  cor(x = mydata$age, y = mydata$wealthworthinbillions,
      use = "complete.obs")
  # Correlation on two variables

  mydata %>%
    select(wealthworthinbillions, age, female) %>%
    cor(use = "complete.obs")
  # Correlation on a set of variables

# The next command is from the "corrr" package, which has better functionality
# than the base cor() function. It uses pair-wise correlation, which
# automatically handles missing data by excluding an observation from the
# correlation calculation of each pair of correlations. i.e. If there are
# missing values on age but not wealth.

  correlate(x = mydata$age, y = mydata$wealthworthinbillions)
  # Correlation on two variables

  mydata %>%
    select(wealthworthinbillions, age, female) %>% # a quick temporary subset
    correlate()
  # Correlation on a set of variables


# Running (and reading) a regression --------------------------------------
# At this point, you've checked the linearity of associations between your
# continuous independent and dependent variables, as well as checked the
# correlations between all the variables for your analysis. It is now time to
# run your first regression. There are two ways to run this in R.

# Linear regression using lm()
  fit_lm <- lm(wealthworthinbillions ~ female + age, data = mydata)
    # Run model and save results as object. As you can see, the command is
    # relatively straight forward.
    # Remember: the dependent variable always comes first before the ~.
    # (the logic being that you are regressing y on x, plus it mimics the equation
    # y = x1 + x2 + x3). The #outputs# below (with hashtags) are what you will
    # likely spend the most time analyzing.
  summary(fit_lm)
    # Look at model results

  # Call:
  #   lm(formula = wealthworthinbillions ~ female + age, data = mydata)
  #
  # Residuals:
  #   Min     1Q Median     3Q    Max
  # -3.764 -2.217 -1.507 -0.091 72.480
  #
  # Coefficients:
  #               Estimate    Std. Error t value  Pr(>|t|)
  #   (Intercept) 1.461568      0.557531   2.622     #0.00881 **#
  #   female      #0.430905#    0.389897   1.105     #0.26920
  #   age         #0.035492#    0.008692   4.083     #4.6e-05 ***#
  #   ---
  #   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
  #
  # Residual standard error: 5.388 on 2226 degrees of freedom
  # (385 observations deleted due to missingness)
  # Multiple R-squared:  #0.007916#,	Adjusted R-squared:  0.007025
  # F-statistic: 8.881 on 2 and 2226 DF,  p-value: 0.000144

# Linear regression using glm()
# Linear regression is part of a larger family of Generalized Linear Models
# This is a function you will use to run other models in this family, so you
# have to specify which model you want to run. In this case, the basic linear
# regression

  fit_glm <- glm(wealthworthinbillions ~ female + age, family = gaussian,
                  data = mydata)
    # Run the model with family =  gaussian
  summary(fit_glm)
  # Look at the results

  # Call:
  #   glm(formula = wealthworthinbillions ~ female + age, family = gaussian,
  #       data = mydata)
  #
  # Deviance Residuals:
  #   Min      1Q  Median      3Q     Max
  # -3.764  -2.217  -1.507  -0.091  72.480
  #
  # Coefficients:
  #   Estimate Std. Error t value Pr(>|t|)
  # (Intercept)   1.461568     0.557531   2.622  #0.00881 **#
  #   female      #0.430905#   0.389897   1.105  #0.26920  #
  #   age         #0.035492#   0.008692   4.083  #4.6e-05 ***#
  #   ---
  #   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
  #
  # (Dispersion parameter for gaussian family taken to be 29.03299)
  #
  # Null deviance: 65143  on 2228  degrees of freedom
  # Residual deviance: 64627  on 2226  degrees of freedom
  # (385 observations deleted due to missingness)
  # #AIC: 13839#


# Honestly, both these methods are pretty equal for linear regression. We will
# be using glm() when we move into logistic regression next quarter.
  # - lm() offers you the R-squared
  # - glm() offers you the AIC, which we'll be discussing later this quarter.


# Dealing with categorical variables (i.e., factors) in R ----------------------

# In the above example, R treated 'female' like a numeric variable. When you
# run the linear regression, it treats any numerical variable as "a ONE unit
# difference in," which doesn't make sense for categorical variables. We
# need to make sure that 'female' is coded in R as a categorical variable,
# i.e., a "factor" in R terms.

# Turn female into a factor variable
  mydata <- mydata %>%
    mutate(female = factor(female))

# If our variable is ordinal, it can be helpful to know how to set levels, aka
# the order of the variable. Levels will go in the order that you list them.
  mydata <- mydata %>%
    mutate(female = factor(female, levels = c("0", "1")))

# R will now treat this as a categorical, non-numeric variable. If we want to
# keep the underlying values at 0 and 1, we can apply labels to the levels
  mydata <- mydata %>%
    mutate(female = factor(female,
                            levels = c("0", "1"),
                            labels = c("male", "female")))

# Now let's rerun our linear regression

  fit_lm2 <- lm(wealthworthinbillions ~ female + age, data = mydata)
    # Run model and save results as object
  summary(fit_lm2)
    # Look at model results
    # Notice how our female variable now shows the name of the variable, and
    # ext to it the name of the value labeled as 1.

# It doesn't make a difference for a binary categorical variable, but it will
# matter for categorical or ordinal variables with more than 2 levels.


# Filtering data in a linear regression -----------------------------------
# Sometimes, you want to run a regression on a subsample of people in
# your dataset. Below I filter my data within the command.
# (I selected observations with billionaires whose wealth was inherited).

  lm(wealthworthinbillions ~ female + age,
     data = mydata %>% filter(wealthtype2 == 3)) %>%
    summary()
    # This is another way to produce a summary via a pipe ( %>% ). The downside
    # to running the code this way is you haven't saved your results anywhere.


# Residuals ---------------------------------------------------------------
# Residuals can be used to check the adequacy of the fitted model. Here you
# will learn the code to pull the residuals from your fitted model and create
# several plots to examine the residuals produced by your model.

# Saving residuals
# First I'm going to limit our main dataframe to the observations used in the
# linear regression. Note there were 385 rows dropped because they were missing
# on female or age
  mydata_lm <- mydata %>%
   drop_na(female, age)
    # Here I'm telling R to drop the observations with missing values
    # on either variable

  mydata_lm$residuals <- residuals(fit_lm)
    # This code saves the residuals as a new variable on your original dataset

  summary(mydata_lm$residuals) # descriptive statistics
  head(mydata_lm$residuals) # first 6 observations
    # We can look at them like we would any variable

# Plotting residuals
# **Residuals vs. Fitted Values**
# These plots look for **non-linear patterns**. The residuals should form a
# horizontal band around the 0 line. For a correct linear regression, the data
# needs to be linear, so this tests if that condition is met.
# If one residual stands out, that may indicate an outlier.
  plot(fit_lm, which = 1, col = "blue")

# There are a lot of residuals above the 0 line, which indicates this may not
# be a good fit.

# **Normal Q-Q (quantile-quantile) Plot**
# Assess the **normality of residuals**. the points should be lie on or near a
# straight line representing Normality and systematic deviations or outlying
# observations indicate a departure from this distribution.
  plot(fit_lm, which=2, col=c("red"))

# The residuals move considerable off the line of normality, indicating that
# the residuals are not normally distributed.

# **Standardized Residuals vs. Fitted Values**
# This can detect **heteroskedasticity**. There should be no discernible pattern
# and points should occupy the same space above and below the regression line. An
# increase in the spread of residuals towards the end of a range would indicate
# heteroskedasticity, or a violation of the assumption of common variance.
  plot(fit_lm, which=3, col=c("blue"))

# We want the line to be roughly flat. It has a slight slant to it, which
# is a bit concerning but not definitive.

