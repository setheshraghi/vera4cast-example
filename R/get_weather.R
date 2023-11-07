get_weather <- function(current_site, site_list) {

  lat <- site_list |>
    filter(site_id == current_site) |>
    select(latitude) |>  pull()

  long <-  site_list |>
    filter(site_id == current_site) |>
    select(longtitude) |>  pull()


  site_weather <- RopenMeteo::get_ensemble_forecast(
    latitude = lat,
    longitude = long,
    forecast_days = 30, # days into the future
    past_days = 60, # past days that can be used for model fitting
    model = "gfs_seamless",
    variables = c("temperature_2m")) |>
    RopenMeteo::convert_to_efi_standard() |>
    mutate(site_id = current_site)

  return(site_weather)
}
