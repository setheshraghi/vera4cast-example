# generate_example_forecast
generate_example_forecast <- function(forecast_date, # a recommended argument so you can pass the date to the function
                                      model_id,
                                      targets_url, # where are the targets you are forecasting?
                                      var, # what variable?
                                      site, # what site,
                                      lat, long,
                                      forecast_depths = 'focal',
                                      project_id = 'vera4cast') {

  # Put your forecast generating code in here, and add/remove arguments as needed.
  # Forecast date should *not* be hard coded
  # This is an example function that also grabs weather forecast information to be used as co-variates

  if (site == 'fcre' & forecast_depths == 'focal') {
    forecast_depths <- 1.6
  }

  if (site == 'bvre' & forecast_depths == 'focal') {
    forecast_depths <- 1.5
  }
  #-------------------------------------

  # Get targets
  message('Getting targets')
  targets <- readr::read_csv(targets_url, show_col_types = F) |>
    filter(variable == var,
           site_id == site,
           depth_m == forecast_depths,
           datetime < forecast_date)
  #-------------------------------------

  # Get the weather data
  message('Getting weather')
  # uses the RopenMeteo function to grab weather from the sites
  # and you can specify the length of the future period and number of days in the past
    # you can modify the data that are collected

  # Collect th relevant weather data
  weather_dat <- RopenMeteo::get_ensemble_forecast(
    latitude = lat,
    longitude = long,
    forecast_days = 30, # days into the future
    past_days = 60, # past days that can be used for model fitting
    model = "gfs_seamless",
    variables = "temperature_2m") |>

    # convert to a standardised forecast
    RopenMeteo::convert_to_efi_standard() |>
    mutate(site_id = site,
           datetime = as_date(datetime)) |>
    group_by(datetime, site_id, variable, parameter) |>

    #calcuate the daily mean
    summarise(prediction = mean(prediction), .groups = 'drop')
  #-------------------------------------


  #-------------------------------------

  # split it into historic and future
   historic_weather <- weather_dat |>
    filter(datetime < forecast_date) |>
    # calculate a daily mean (remove ensemble)
    group_by(datetime, variable, site_id) |>
    summarise(prediction = mean(prediction), .groups = 'drop') |>
    pivot_wider(names_from = variable, values_from = prediction) |>
    mutate(air_temperature = air_temperature - 273.15)

  forecast_weather <- weather_dat |>
    filter(datetime >= forecast_date) |>
    pivot_wider(names_from = variable, values_from = prediction) |>
    mutate(air_temperature = air_temperature - 273.15)
  #-------------------------------------

  # Fit model
  message('Fitting model')
  fit_df <- targets |>
    pivot_wider(names_from = variable, values_from = observation) |>
    left_join(historic_weather, by = join_by(site_id, datetime))

  model_fit <- lm(fit_df$Temp_C_mean ~ fit_df$air_temperature)
  #-------------------------------------

  # Generate forecasts
  message('Generating forecast')
  forecast <- (forecast_weather$air_temperature * model_fit$coefficients[2]) + model_fit$coefficients[1]

  forecast_df <- data.frame(datetime = forecast_weather$datetime,
                            reference_datetime = forecast_date,
                            model_id = model_id,
                            site_id = forecast_weather$site_id,
                            parameter = forecast_weather$parameter,
                            family = 'ensemble',
                            prediction = forecast,
                            variable = var,
                            depth_m = forecast_depths,
                            duration = targets$duration[1],
                            project_id = project_id)
  #-------------------------------------

  return(forecast_df)

}
