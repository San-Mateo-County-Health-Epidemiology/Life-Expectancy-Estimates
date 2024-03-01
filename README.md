# Life-Expectancy-Estimates
This project contains code to estimate life expectancy for a given population. It provides 1, 3 and 5 year estimates.

The code follows the methodology used in the **Public Health England Life Expectancy Calculator**. 

## Age groups

This calculator uses these age groups: 0, 1-4, 5-9, 10-14, 15-19 ... 80-84, 85-89, 90+

# Code

## `create_dof_denominators`

This script outputs a file with these variables

  `year`: the year of the estimate
  `value_type`: either `sum_1yr` (single year), `roll_sum_3yr` (right aligned 3 year sum) or `roll_sum_5yr` (right aligned 5 year sum)
