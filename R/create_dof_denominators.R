######################################################
#
# create DOF denominators
#
######################################################

rm(list = ls())

library(tidyverse) 
library(readr) 
library(readxl)
library(writexl)
library(lubridate)
library(zoo)

# load files -----------------------------------------
## raw dof file ----
dof_old <- read.csv("J:/Epi Data/DoF Population Projections/P3_Complete released on 7.14.2021/P3_Complete.csv")
dof_new <- read.csv("J:/Epi Data/DoF Population Projections/P3_Complete released on 7.19.2023/P3_Complete released on 7.19.2023.csv")

dof_new_start <- dof_new %>%
  summarize(start_year = min(year)) %>%
  pull(start_year)

dof <- dof_old %>%
  filter(year < dof_new_start) %>%
  bind_rows(dof_new)

# process data ---------------------------------------
## create new variables ----
dof1 <- dof %>%
  rename(age = agerc,
         pop = perwt) %>%
  filter(fips == "6081") %>%
  mutate(race_cat = case_when(race7 == 1 ~ "White",
                              race7 == 2 ~ "Black",
                              race7 == 3 ~ "American Indian/Alaskan Native",
                              race7 == 4 ~ "Asian",
                              race7 == 5 ~ "Hawaiian/Pacific Islander",
                              race7 == 6 ~ "Multirace",
                              race7 == 7 ~ "Hispanic/Latino"),
         age_cat = case_when(age == 0 ~ "0",
                             age %in% 1:4 ~ "1-4",
                             age %in% 5:9 ~ "5-9",
                             age %in% 10:14 ~ "10-14",
                             age %in% 15:19 ~ "15-19",
                             age %in% 20:24 ~ "20-24",
                             age %in% 25:29 ~ "25-29",
                             age %in% 30:34 ~ "30-34",
                             age %in% 35:39 ~ "35-39",
                             age %in% 40:44 ~ "40-44",
                             age %in% 45:49 ~ "45-49",
                             age %in% 50:54 ~ "50-54",
                             age %in% 55:59 ~ "55-59",
                             age %in% 60:64 ~ "60-64",
                             age %in% 65:69 ~ "65-69",
                             age %in% 70:74 ~ "70-74",
                             age %in% 75:79 ~ "75-79",
                             age %in% 80:84 ~ "80-84",
                             age %in% 85:89 ~ "85-89",
                             age >= 90 ~ "90+"))

## create groups and totals we need ----
### 1 year total and 3 and 5 year rolling averages by race/ethnicity
dof_totals_race_year <- dof1 %>%
  group_by(year, race_cat, age_cat) %>%
  summarize(sum_1yr = sum(pop),
            .groups = "keep") %>%
  ungroup() %>%
  complete(year, age_cat) %>%
  group_by(race_cat, age_cat) %>%
  arrange(year) %>%
  mutate(sum_1yr = case_when(is.na(sum_1yr) ~ 0, TRUE ~ sum_1yr),
         roll_sum_3yr = rollsum(sum_1yr, 3, fill = NA, align = "right"),
         roll_sum_5yr = rollsum(sum_1yr, 5, fill = NA, align = "right")) %>%
  ungroup() %>%
  pivot_longer(names_to = "est_type",
               values_to = "population",
               cols = matches("sum")) %>%
  mutate(year_start = case_when(est_type == "sum_1yr" ~ year, 
                                est_type == "roll_sum_3yr" ~ year-2,
                                est_type == "roll_sum_5yr" ~ year-4),
         year_range = paste0(year_start, "-", year)) %>%
  select(-year_start) %>%
  filter(!is.na(population))

### 1 year total and 3 and 5 year rolling averages overall
dof_totals_all_year <- dof1 %>%
  group_by(year, age_cat) %>%
  summarize(sum_1yr = sum(pop),
            .groups = "keep") %>%
  ungroup() %>%
  complete(year, age_cat) %>%
  group_by(age_cat) %>%
  arrange(year) %>%
  mutate(sum_1yr = case_when(is.na(sum_1yr) ~ 0, TRUE ~ sum_1yr),
         roll_sum_3yr = rollsum(sum_1yr, 3, fill = NA, align = "right"),
         roll_sum_5yr = rollsum(sum_1yr, 5, fill = NA, align = "right")) %>%
  ungroup() %>%
  pivot_longer(names_to = "est_type",
               values_to = "population",
               cols = matches("sum")) %>%
  mutate(year_start = case_when(est_type == "sum_1yr" ~ year, 
                                est_type == "roll_sum_3yr" ~ year-2,
                                est_type == "roll_sum_5yr" ~ year-4),
         year_range = paste0(year_start, "-", year),
         race_cat = "All SMC") %>%
  select(-year_start) %>%
  filter(!is.na(population)) %>%
  bind_rows(dof_totals_year_race)


# save files ---------------------------------------
date <- str_replace_all(Sys.Date(), "-", "")

path_race_year <- paste0("dof-denoms//dof_denoms_race_saved_", date, ".Rda")
save(dof_totals_race_year, 
     file = path_race_year)

path_all_year <- paste0("dof-denoms//dof_denoms_all_saved_", date, ".Rda")
save(dof_totals_all_year, 
     file = path_all_year)