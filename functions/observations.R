
read_observations = function(
    scientificname = "Lophius americanus",
    minimum_year = 1970, 
    require_count = TRUE,
    basis_allowed = c("HumanObservation","Occurrence")
){
  if(FALSE){
    scientificname = "Lophius americanus"
    minimum_year = 1970 
    require_count = TRUE
    basis_allowed = c("HumanObservation","Occurrence")
    
  }
  obs = read_obis(scientificname)
  
  # if (sf::st_is(obs, "sf")) {
  #   coords = sf::st_coordinates(obs)
  #   obs$decimalLongitude = coords[, 1]
  #   obs$decimalLatitude  = coords[, 2]
  # }
  
  dim_start = dim(obs)
  
  obs = obs |>
    dplyr::filter(
      !is.na(eventDate)
      #!is.na(decimalLongitude),
      #!is.na(decimalLatitude)
    )
  
  if (!is.null(minimum_year)){
    obs = obs |>
      dplyr::filter(year >= minimum_year)
  }
  
  if (!is.null(basis_allowed)){
    obs = obs |>
      dplyr::filter(basisOfRecord %in% basis_allowed)
  }
  
  if (require_count){
    obs = obs |>
      dplyr::filter(!is.na(individualCount))
  }
  
  obs = obs |>
    dplyr::mutate(month = factor(month, levels = month.abb))
  
 # obs_sf = sf::st_as_sf(
 #   obs,
 #   coords = c("decimalLongitude","decimalLatitude"),
 #   crs = 4326,
 #   remove = FALSE
 # )
  
  db = brickman_database() |>
    dplyr::filter(scenario == "STATIC", var == "mask")
  
  mask = read_brickman(db)
  
  hitOrMiss = extract_brickman(mask, obs)
  
  obs = obs |>
    dplyr::filter(!is.na(hitOrMiss$value))
  
  dim_end = dim(obs)
  
  message(
    sprintf(
      "Dropped %d of %d records (%.1f%%)",
      dim_start[1] - dim_end[1],
      dim_start[1],
      100 * (dim_start[1] - dim_end[1]) / dim_start[1]
    )
  )
  
  return(obs)
}

