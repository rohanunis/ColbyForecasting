#load database to DB object
DB = brickman_database() 

#filter database for wanted parameters
  db = DB |>
    dplyr::filter(scenario == "RCP45", 
                  year == 2055,
                  interval == "mon",
                  var == "SST"
                  )
  #read filtered data into object x
  x = read_brickman(db)
  
  #load buoy data 
  buoys = gom_buoys()
  
  #select only M01
  buoy_M01 = buoys|>
  dplyr::filter(id == "M01")
  
  # extract SST values for eact month and ensure month are in chronological order
  wide_values <- extract_brickman(x, buoy_M01, form = "wide")|>  
   dplyr:: mutate(month = factor(month, levels = month.abb))
  
  #plot
  p = ggplot(wide_values, aes(x=month, y = SST)) + 
    
    geom_point(size = 2) +
    
    labs(
      title = "sea surface temperature in 2055 at buoy M01 (model:RCP 4.5)",
      x = "Month",
      y = "SST"
    ) + 
    theme_classic()
  
  print(p)

  
  
  