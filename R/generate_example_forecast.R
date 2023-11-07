# generate_example_forecast
generate_example_forecast <- function(forecast_date,
                                      model_id,
                                      targets_url,
                                      var,
                                      sites = c('fcre', 'bvre'),
                                      forecast_depths = 1.6,
                                      project_id = 'vera4cast',
                                      out_dir = 'Forecasts') {

  # Put your forecast generating code in here, and add additional arguments as needed.
  # Forecast date should not be hard coded
  # This is an example function that also grabs weather forecast information to be used as covariates

  # Get targets
  message('Getting targets')
  targets <- readr::read_csv(targets_url, show_col_types = F) |>
    filter(variable %in% var,
           site_id %in% sites,
           depth_m %in% forecast_depths,
           datetime < forecast_date)

  # Get the weather data
  message('Getting weather')
  weather_dat <- sites |>
    map_dfr(get_weather, site_list = site_list)

  historic_weather <- weather_dat |>
    filter(datetime < forecast_date) |>
    group_by(datetime, variable, site_id) |>
    summarise(prediction = mean(prediction)) |>
    pivot_wider(names_from = variable, values_from = prediction) |>
    mutate(air_temperature = air_temperature - 273.15)

  forecast_weather <- weather_dat |>
    filter(datetime >= forecast_date) |>
    group_by(datetime, variable, site_id, parameter) |>
    pivot_wider(names_from = variable, values_from = prediction) |>
    mutate(air_temperature = air_temperature - 273.15)


  # Fit model
  message('Fitting model')
  fit_df <- targets |>
    pivot_wider(names_from = variable, values_from = observation) |>
    left_join(historic_weather)

  model_fit <- lm(fit_df$Temp_C_mean ~ fit_df$air_temperature)

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

  if (targets$duration[1] == 'P1D') {
    forecast_file_name <- paste0('daily-', forecast_date, '-', model_id, '.csv')
  } else {
    if (targets$duration[1] == 'PT1H') {
      forecast_file_name <- paste0('daily-', forecast_date, '-', model_id, '.csv')
    } else {
      message('Unknown duration')
      stop()
    }
  }



  if (dir.exists(out_dir)) {
    write_csv(forecast_df,file.path(out_dir, forecast_file_name))
  } else {
    dir.create(out_dir)
    write_csv(forecast_df,file.path(out_dir, forecast_file_name))
  }


  return(file.path(out_dir, forecast_file_name))

}
