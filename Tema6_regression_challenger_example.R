##### Chapter 6: Forecasting Numeric Data – Regression Methods -----------------

## Example from the book "Machine Learning with R", by Brett Lantz


# import the CSV file
launch <- read.csv(file.path("Chapter06", "challenger.csv"))

str(launch)

# Simple linear regression
################################################################################

# Estimate a and b:
#
# y = a + bx  
#
# The solution for a depends on the value of b. It can be obtained using the following formula:
#   a = y_ - bx_ (mean of y, mean of x)

# we must use the covariance between the independent variable (temperature) and 
# dependent variable (distressed O-rings)

# first b:
b <- cov(launch$temperature, launch$distress_ct) /  var(launch$temperature)
b
# [1] -0.04753968

# then a (by using the computed b value and applying the mean() function):
a <- mean(launch$distress_ct) - b * mean(launch$temperature)
a 
# [1] 3.698413

# Estimating the regression equation by hand is obviously less than ideal, so R provides
# a function for fitting regression models automatically:  

# lm (for linear model):
regr_model = lm(formula = launch$distress_ct ~ launch$temperature, data = launch)
regr_model

# Call:
#   lm(formula = launch$distress_ct ~ launch$temperature, data = launch)
# 
# Coefficients:
#   (Intercept)  launch$temperature  
# 3.69841            -0.04754          a and b as calculated before    


# Correlations
################################################################################
# The correlation between two variables is a number that indicates how closely 
#their relationship follows a straight line.

r <- cov(launch$temperature, launch$distress_ct) /  (sd(launch$temperature) * sd(launch$distress_ct))
r
# [1] -0.5111264

# or better directly
cor(launch$temperature, launch$distress_ct)
# [1] -0.5111264

# The correlation between the temperature and the number of distressed O-rings is -0.51. 
# The negative correlation implies that increases in temperature are related to decreases in the number
# of distressed O-rings.


# Multiple linear regression
################################################################################

reg <- function(y, x) {
  x <- as.matrix(x)
  x <- cbind(Intercept = 1, x)
  b <- solve(t(x) %*% x) %*% t(x) %*% y
  colnames(b) <- "estimate"
  print(b)
}

reg(y = launch$distress_ct, x = launch[2])
#                estimate
# Intercept    3.69841270
# temperature -0.04753968   <- exactly as calculated before for simple regression :)

# So we can use it for multiple regression
# We’ll apply it just as before, but this time we will specify columns two through four for
# the x parameter to add two additional predictors:

reg(y = launch$distress_ct, x = launch[2:4])  # temperature, field_check_pressure, flight_num
#                          estimate
# Intercept             3.527093383
# temperature          -0.051385940
# field_check_pressure  0.001757009
# flight_num            0.014292843

# the inclusion of the two new predictors did not change our
# finding from the simple linear regression model. Just as before, the coefficient for the temperature
# variable is negative, which suggests that as temperature increases, the number of expected O-ring
# events decreases. The magnitude of the effect is also approximately the same: roughly 0.05 fewer
# distress events are expected for each degree increase in launch temperature.




