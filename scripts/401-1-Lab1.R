#--------------------------------------------------------------------------#
# Lab 1
# 401-1-Lab1.R
# 12/16/2021
# Rose Werth, Northwestern University
# Ewurama Okai, Northwestern University
#
# TOPICS: Data cleaning review
#--------------------------------------------------------------------------#


# Libraries ---------------------------------------------------------------

# When you are cleaning datasets, these are the basic libraries I find most
# useful.
library(tidyverse)
library(dplyr)
library(janitor)
library(ggplot2)
library(skimr)
library(pillar)

# Note: if you do not have one of these packages installed, you will need to
# first install it using the command: install.packages("skimr")


# Set up environment ------------------------------------------------------

# Set your working directory (if you aren't working in a project). Replace the
# path that I'm using with the path to the folder you want to import from/
# export to.
setwd("~/Documents/Work & Research/Regression Labs")

# If you are working inside a project, create a folder system to keep your data
# for this project organized.
dir.create("data_raw")
dir.create("data_work")
dir.create("fig_output")
dir.create("scripts")

# Load your dataset
load("data/SOC401_W21_Billionaires.rda")

# Renaming dataset so it's easier to code with, and so I can keep a raw version
# of the dataset saved in my environment.
mydata <- SOC401_W21_Billionaires # this saves the dataset as a new dataframe in our environment.


# Exploring your data -----------------------------------------------------
# When you begin any new project, it is important to understand the nature and
# condition of your variables. Here are a few of the important codes you need
# to begin that process.

# Remember if this script uses a function you are not familiar with, search
# for the function online or type '?ifelse()', replacing with the function name
# you'd like to read the documentation for.

# Take a global look at your dataset
# Option 1 - from the skimr library
skim_without_charts(mydata)
# Option 2 - from the pillar libary
glimpse(mydata)

# Look at the names of the variables in your dataset
names(mydata)

# View the first 10 rows of your dataset
head(mydata)

# View the first 10 observations of a specific variable
head(mydata$name)

# Look at missing observations in your dataset
sapply(mydata, function(x) sum(is.na(x)))

# Descriptive statistics for your entire dataset (you can also get this using
# the skim command above)
summary(mydata)

# Descriptive statistics for a specific numeric variable
summary(mydata$wealthworthinbillions)

# Individual statistics.
# We can also use functions to individual see the mean, range, or standard
# deviation of datasets. These functions can be helpful checks as you clean
# a dataset
mean(mydata$demographicsage)
range(mydata$demographicsage) #hmm...notice anything odd about this range?
sd(mydata$demographicsage)

# Frequency table for a specific variable
mydata %>%
  group_by(year) %>%
  count()

# Frequency table with percentages
mydata %>%
  group_by(year) %>%
  count() %>%
  mutate(percent = round(n / nrow(mydata) * 100, 2))


# Cleaning variables ------------------------------------------------------
# In the previous section, we learn the code to check the state of a variable
# when we first open the dataset. Most of the time, you're likely to find that
# the variable isn't ideal to work with. It is important to use this commands
# to make a variable ready for your use.

# Let's take a closer look at the variable for gender.
mydata %>%
  group_by(demographicsgender2) %>%
  count()

# I notice a few things I want to change about variable:
#   a) The variable name is tedious to type for my own codes
#   b) I want to make this a dummy variable, where 1 is female and 0 is
#     not female (in this binary, male).
#   c) We have three married couples in our dataset coded as 3

# Let's create a new variable with a better variable name and recode the
# variable how we'd like it.

# Here we will recode the variable using the mutate() function and the ifelse()
# function, which are helpful for recoding based on previous variable.
# If we want to label the 3 married couples as 0, aka not female...
mydata <- mydata %>%
  mutate(female = ifelse(demographicsgender2 == 1, 1, 0))

mydata %>%
  group_by(female) %>%
  count()

# If we want to label the three married couples as NA, so 1 = female, 0 = male
mydata <- mydata %>%
  mutate(female = ifelse(demographicsgender2 == 1, 1,
                         ifelse(demographicsgender2 == 2, 0, NA)))

mydata %>%
  group_by(female) %>%
  count()

# Note: by running these two chunks of code back to back, I wrote over my first
# attempt at creating a new dummy variable 'female.' If I want to use the second
# one that's fine, but there's no going back once you overwrite something, so be
# careful with your code.

# Now let's look at the variable for age.
mydata %>%
  group_by(demographicsage) %>%
  count()

# The major concern is that there are some numbers that seem unreasonable. Age
# is not negative, and 0 is an unlikely age for a person in a
# billionaire dataset.

# Let's recode those variables to NA for now. Again, we'll use mutate() and
# ifelse(), and we will name the variable something easier to work with.
mydata <- mydata %>%
  mutate(age = ifelse(demographicsage <= 0, NA, demographicsage))

mydata %>%
  group_by(age) %>%
  count()


# Visualizing variables ---------------------------------------------------

# Continuous Variables
# While frequency tables and descriptive statistics are helpful, visualizing
# continuous variables or discrete variables with a wide range of values can be
# helpful to get a look at the shape of our data. Histograms or  the go to.

# Histogram using the base plots in R
hist(mydata$age)

# Histogram using ggplot
# While ggplot2 requires knowledge of the grammar of ggplot, it is far superior
# in what it can do and the quality of graphics it produces
ggplot(data = mydata, aes(x = age)) +
  geom_histogram(color = "white") +
  theme_minimal()

# Let's change the number of bins
ggplot(data = mydata, aes(x = age)) +
  geom_histogram(color = "white", bins = 10) +
  theme_minimal()

hist(mydata$age, breaks = 10)

# Let's save a ggplot
ggsave("figs_output/histogram-example.png")
# This will save the last ggplot that you created. I encourage you to look up
# examples of ggsave to learn different ways you can save plots as objects,
# specify height and width, and more.


# Subsetting and Saving Data ---------------------------------------------
# Sometimes you'll be working with a huge dataset, and it is easier and cleaner
# save portion of observations and/or variables in a new dataset. This is called
# a sub-sample.

# Let's say we only want to keep the following three variables: year and the
# two variables we just created: age and female. We can easily subset the data
# using the select() function in tidyverse.

mysubset <- mydata %>% # note I'm saving this as a new dataframe with a new name
  select(year, age, female)

skim_without_charts(mysubset) # you should always check your data when you make
                              # a major change like adding or removing variables.

# But what if we wanted to subset the data to only billionaires 30 or older?
# For this task, we can use the filter() function.

mysubset2 <- mydata %>%
  filter(age >= 30)

range(mysubset2$age) # Another check to see our code worked how we wanted it!

# Saving your subset
# Now that you have your subset, you'll want to save it. Saving in R's data
# format is simple. There are extra steps to save it other formats. .CSV files
# are one of the most common formats you'll receive and save data in outside of
# R.

# Saving as r data format (.rda or .rData - both are the same).
save(mysubset, file = "data_work/mysubset.rda")

# Saving as a .csv file
write_csv(mysubset, file = "data_work/mysubset.csv")

# Remember, every time you run these command it writes over your previous save.
# So be careful about version control and ALWAYS maintain the raw data file in
# a separte location.
