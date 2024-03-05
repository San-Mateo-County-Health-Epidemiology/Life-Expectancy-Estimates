######################################################
#
# Example for Calculating Life Expectancy
#
######################################################

rm(list = ls())

library(tidyverse) 

# setup ----------------------------------------------
## load function ----
source("R\\functions\\make-life-table-function.R")

## load data -----
data <- rio::import("data/example-data.csv")

## prep data ----
data1 <- data %>%
  mutate(start_age = as.numeric(str_extract(age_cat, "^\\d{1,2}"))) %>% # start age makes sure the age groups sort correctly
  group_by(year) %>%
  arrange(start_age)

# get le estimates -----------------------------------
## create the whole life table -----
le <- data1 %>%
  make_life_table()

## pull out what you want ----
le %>%
  filter(start_age == 0) %>%
  select(year, obs_le_int, ci_low_95, ci_high_95)
