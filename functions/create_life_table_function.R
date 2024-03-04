# function to make life table ----
## row_number() == n() identifies the last row of a group and allows for different behavior for that row
make_life_table <- function(data) {
  life_table <- data %>%
    arrange(start_age) %>% 
    mutate(int_width = case_when(age_cat == "0" ~ 1,
                                 age_cat == "1-4" ~ 4,
                                 age_cat == "0-4" ~ 5, 
                                 age_cat == "85+" ~ 17.3,
                                 age_cat == "90+" ~ 12.3,
                                 TRUE ~ 5),
           fract_surv = case_when(age_cat == "0" ~ 0.1,
                                  age_cat == "0-4" ~ 0.02,
                                  TRUE ~ 0.5),
           death_rate = deaths/population,
           prob_dying = int_width*death_rate/(1+int_width*(1-fract_surv)*death_rate),
           prob_surv = 1-prob_dying,
           num_alive_int = accumulate(.x = head(prob_surv, -1),
                                      .init = 100000,
                                      .f = `*`),
           num_dying_int = case_when(row_number() == n() ~ num_alive_int,
                                     TRUE ~ num_alive_int - lead(num_alive_int)),
           pers_yrs_lived_int = case_when(row_number() == n() ~ num_alive_int/death_rate, 
                                          TRUE ~ int_width*(lead(num_alive_int)+(fract_surv*num_dying_int))),
           pers_yrs_lived_past = accumulate(.x = pers_yrs_lived_int,
                                            .f = `+`,
                                            .dir = "backward"),
           obs_le_int = pers_yrs_lived_past/num_alive_int,
           sample_var = case_when(row_number() == n() ~ (death_rate*(1-death_rate)/population),
                                  deaths == 0 ~ 0,
                                  TRUE ~ (prob_dying^2*(1-prob_dying)/deaths)),
           weighted_var = case_when(row_number() == n() ~ (num_alive_int^2)/death_rate^4*sample_var,
                                    TRUE ~ (num_alive_int^2)*((1-fract_surv)*int_width+lead(obs_le_int))^2*sample_var),
           sample_var_pers_yrs = accumulate(.x = weighted_var,
                                            .f = `+`,
                                            .dir = "backward"),
           sample_var_obs_le = sample_var_pers_yrs/num_alive_int^2,
           ci_low_95 = round(obs_le_int-(1.96*sqrt(sample_var_obs_le)), 1),
           ci_high_95 = round(obs_le_int+(1.96*sqrt(sample_var_obs_le)), 1)) %>%
    ungroup()
  
  
  life_table
  
}
