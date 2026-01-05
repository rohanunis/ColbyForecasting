include_covariate = function(x, add_me = "depth"){
  
  #' Include one or more covariates to a list
  #' 
  #' @param x str a vector of covariates
  #' @param add_me str a vector of one or more covariates to append to the input x
  #' @return a possibly updated version of the input x
  for (me in add_me){
    if (!(me %in% x)) x = append(x, me)
  }
  x
}




select_covariates = function(mon = "Jan",
                             scientificname = "Mola mola",
                             path = data_path(),
                             must_have_depth = TRUE){
  
  
  #' Given a species, month and sampling approach select variables for each month
  #'
  #' @param mon chr month abbreviation ("Jan" default)
  #' @param scientificname chr the species studied (default "Mola mola")
  #' @param path chr file path to the personal data directory
  #' @param must_have_depth logical, if TRUE then make sure depth is a covariate
  #' @return a list suitable for storing as a YAML configuration
  
  # read in the model input data
  model_input = read_model_input(scientificname = scientificname,
                                 mon = mon,
                                 path = file.path(path, "model_input"))
  if(is.null(model_input)) return(NULL)
  # read in the Brickman data (with depth)
  db = brickman_database()
  present = read_brickman(filter(db, scenario == "PRESENT", interval == "mon"))
  this_month = slice(present, "month", mon)
  
  keep = filter_collinear(this_month, method = "vif_step")
  
  # user insists on keeping depth
  if ( must_have_depth && !("depth" %in% keep) ) keep = c(keep, "depth")
  
  version = sprintf("%s_%s", substring(approach, 1,1), mon)
  
  config = list(
    version = version, # something you make goes here
    scientificname = scientificname,
    approach = approach,
    mon = mon,
    keep_vars = keep) # something you make goes here
  
  model_path = file.path(path, "models") |> 
    make_path()
  config_file = file.path(model_path, sprintf("%s.yaml", version))
  
  write_yaml(config, config_file)
  return(config)
}