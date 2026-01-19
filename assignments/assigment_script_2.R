source("../setup.R")
library(dplyr)



obsbkg<- read_model_input(scientificname = "Lophius americanus")


set.seed(42)


sampled_points <- obsbkg |>
  dplyr::group_by(month, class) |>
  dplyr::slice_sample(n=1) |>
  dplyr::ungroup()


print(nrow(sampled_points))



db_vars <- brickman_database() |>
  
  dplyr::filter(
    scenario == "PRESENT",
    interval == "mon",
    var %in% c("SSS","SST","Tbtm")
    
    
  )

covars <- read_brickman(db_vars)



final_table <- extract_brickman(
  covars,
  sampled_points,
  form = "wide"
)

print(final_table)