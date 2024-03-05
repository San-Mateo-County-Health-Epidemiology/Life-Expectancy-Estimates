# Life-Expectancy-Estimates
## Background
This project contains code to estimate life expectancy for a given population. The code follows the methodology used in the **Public Health England Life Expectancy Calculator**. See the Wiki for specific details about methodology.

## How to use
You can use the `example-for-calculating-life-expectancy` script to see how the code works. Essentially, the `make_life_table()` function recreates the PHE LE calculator. In order to use it, you need your data to have three variables:  

- `age_cat`: this should be the 0-4, 5-9, 10-14, 15-19 ... 80-84, 85-89, 90+ age groups from the excel file
- `population`: this should be the number of people in each age group
- `deaths`: this should be the number of deaths in each age group

For more details, see the Wiki. 
