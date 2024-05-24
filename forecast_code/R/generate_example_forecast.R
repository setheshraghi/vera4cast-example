# generate_example_forecast
generate_example_forecast <- function(forecast_date, # a recommended argument so you can pass the date to the function
                                      model_id,
                                      targets_url, # where are the targets you are forecasting?
                                      var, # what variable?
                                      site, # what site,
                                      horizon = 30, # (days)
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
  # you can modify the data that are collected

  # Collect th relevant weather data
  historical_weather_s3 <- vera4castHelpers::noaa_stage3()

  variables <- c("air_temperature")

  historical_weather <- historical_weather_s3  |>
    dplyr::filter(site_id %in% site,
                  variable %in% variables) |>
    dplyr::collect()  |>
    mutate(datetime = as_date(datetime)) |>
    group_by(datetime, site_id, variable) |>
    summarize(prediction = mean(prediction, na.rm = TRUE), .groups = "drop") |>
    # convert air temperature to Celsius if it is included in the weather data
    mutate(prediction = ifelse(variable == "air_temperature", prediction - 273.15, prediction)) |>
    pivot_wider(names_from = variable, values_from = prediction)

  noaa_date <- forecast_date - days(1)

  future_weather_s3 <- vera4castHelpers::noaa_stage2(start_date = as.character(noaa_date))

  future_weather <- future_weather_s3 |>
    dplyr::filter(datetime >= forecast_date,
                  site_id %in% site,
                  variable %in% variables) |>
    collect() |>
    mutate(datetime = as_date(datetime)) |>
    group_by(datetime, site_id, variable, parameter) |> # parameter is included in the grouping variables
    summarize(prediction = mean(prediction, na.rm = TRUE), .groups = "drop")  |>
    # convert air temperature to Celsius if it is included in the weather data
    mutate(prediction = ifelse(variable == "air_temperature", prediction - 273.15, prediction)) |>
    pivot_wider(names_from = variable, values_from = prediction) |>
    select(any_of(c('datetime', 'site_id', variables, 'parameter')))

  #-------------------------------------


  # Fit model
  message('Fitting model')
  fit_df <- targets |>
    pivot_wider(names_from = variable, values_from = observation) |>
    left_join(historical_weather, by = join_by(site_id, datetime))

  model_fit <- lm(fit_df$Temp_C_mean ~ fit_df$air_temperature)

  coeff <- model_fit$coefficients
  #-------------------------------------

  # Generate forecasts
  message('Generating forecast')


  # set up forecast df
  forecast_df <- NULL
  forecast_horizon <- horizon # make a 30 day-ahead forecast
  forecast_dates <- seq(from = ymd(forecast_date), to = ymd(forecast_date) + forecast_horizon, by = "day")


  for (t in 1:length(forecast_dates)) {
    temp_driv <- future_weather |>
      filter(datetime == forecast_dates[t])

    forecast <-  coeff[1] + (future_weather$air_temperature * coeff[2])

    forecast_temp <- data.frame(datetime = future_weather$datetime,
                                reference_datetime = forecast_date,
                                model_id = model_id,
                                site_id = future_weather$site_id,
                                parameter = future_weather$parameter,
                                family = 'ensemble',
                                prediction = forecast,
                                variable = var,
                                depth_m = forecast_depths,
                                duration = targets$duration[1],
                                project_id = project_id)

    forecast_df <- bind_rows(forecast_df, forecast_temp)
  }

  #-------------------------------------

  return(forecast_df)

}
