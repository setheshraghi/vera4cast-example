get_hourly_weather <- function(current_site, site_list, past = 90, future = 30) {

  lat <- site_list |>
    filter(site_id == current_site) |>
    select(latitude) |>  pull()

  long <-  site_list |>
    filter(site_id == current_site) |>
    select(longtitude) |>  pull()


  site_weather <- RopenMeteo::get_ensemble_forecast(
    latitude = lat,
    longitude = long,
    forecast_days = future, # days into the future
    past_days = past, # past days that can be used for model fitting
    model = "gfs_seamless",
    variables = c("temperature_2m")) |>
    RopenMeteo::convert_to_efi_standard() |>
    mutate(site_id = current_site)

  return(site_weather)
}


get_daily_weather <- function(current_site, site_list, past = 90, future = 30) {

  lat <- site_list |>
    filter(site_id == current_site) |>
    select(latitude) |>  pull()

  long <-  site_list |>
    filter(site_id == current_site) |>
    select(longtitude) |>  pull()


  site_weather <- RopenMeteo::get_ensemble_forecast(
    latitude = lat,
    longitude = long,
    forecast_days = future, # days into the future
    past_days = past, # past days that can be used for model fitting
    model = "gfs_seamless",
    variables = c("temperature_2m")) |>
    RopenMeteo::convert_to_efi_standard() |>
    mutate(site_id = current_site,
           datetime = as_date(datetime)) |>
    group_by(datetime, site_id, variable, parameter) |>
    summarise(prediction = mean(prediction))

  return(site_weather)
}
