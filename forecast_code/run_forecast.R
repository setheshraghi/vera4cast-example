
setwd(here::here())
# load required packages
source('forecast_code/load_packages.R')

# load the forecast generation function - include at least a forecast_date argument
source('forecast_code/R/generate_example_forecast.R')

# ---- Generate the forecasts -----
# default is to run a real-time forecast for today for fcre only
forecast_date <- Sys.Date()
site_list <- read_csv("https://raw.githubusercontent.com/LTREB-reservoirs/vera4cast/main/vera4cast_field_site_metadata.csv",
                      show_col_types = FALSE)

fcre_lat <- site_list |>
  filter(site_id == 'fcre') |>
  pull(latitude)

fcre_long <- site_list |>
  filter(site_id == 'fcre') |>
  pull(longitude)

model_id <- 'TempC_mean_example_forecast'

# this should generate a df
forecast <- generate_example_forecast(forecast_date = forecast_date,
                                      model_id = model_id,
                                      targets_url = "https://renc.osn.xsede.org/bio230121-bucket01/vera4cast/targets/project_id=vera4cast/duration=P1D/daily-insitu-targets.csv.gz",
                                      var = 'Temp_C_mean',
                                      site = 'fcre',
                                      lat = fcre_lat,
                                      long = fcre_long,
                                      forecast_depths = 'focal')
#----------------------------------------#

# write forecast locally
message('Writing forecast')
save_here <- 'Forecasts/'
forecast_file <- paste0(save_here, forecast_date, '-', model_id, '.csv')

if (dir.exists(save_here)) {
  write_csv(forecast, forecast_file)
} else {
  dir.create(save_here)
  write_csv(forecast, forecast_file)
}

# Submit forecast!
vera4castHelpers::submit(forecast_file = forecast_file)

#-------------------------------------------#

# Here is an example that use the purrr package to run the above function over multiple of sites.
# The map functions (map, map2, pmap) can be useful for this type of iteration

# example for multiple sites
# site <- c('fcre', 'bvre')
# forecast <- site |>
#   map(generate_example_forecast,
#       forecast_date = forecast_date,
#       model_id = model_id,
#       targets_url = "https://renc.osn.xsede.org/bio230121-bucket01/vera4cast/targets/project_id=vera4cast/duration=P1D/daily-insitu-targets.csv.gz",
#       var = 'Temp_C_mean',
#       lat = fcre_lat,
#       long = fcre_long,
#       forecast_depths = 'focal') |>
#   list_rbind() # combines the output from the multiple map runs (a list of dfs)
