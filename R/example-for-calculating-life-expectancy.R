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

# get le estimates -----------------------------------
## create the whole life table -----
le <- data %>%
  mutate(start_age = as.numeric(str_extract(age_cat, "^\\d{1,2}"))) %>% # start age makes sure the age groups sort correctly
  group_by(year) %>% # you can add other grouping variables (race, sex, etc here)
  arrange(start_age) %>%
  make_life_table() %>%
  ungroup()

## pull out the life expectancy estimate ----
le %>%
  filter(start_age == 0) %>%
  select(year, obs_le_int, ci_low_95, ci_high_95)
