# load required packages
source('load_packages.R')

# load the forecast generation function - include at least a forecast_date argument
source('R/generate_example_forecast.R')
source('R/get_weather.R') # wrapper around the RopenMeteo package to get weather covariates

# ---- Generate the forecasts -----
# default is to run a real-time forecast for today
forecast_date <- Sys.Date()
site_list <- read_csv("https://raw.githubusercontent.com/LTREB-reservoirs/vera4cast/main/vera4cast_field_site_metadata.csv",
                      show_col_types = FALSE)
model_id <- 'TempC_mean_example_forecast'

# this should generate a df
forecast <- generate_example_forecast(forecast_date = forecast_date,
                                      model_id = model_id,
                                      targets_url = "https://renc.osn.xsede.org/bio230121-bucket01/vera4cast/targets/project_id=vera4cast/duration=P1D/daily-insitu-targets.csv.gz",
                                      var = 'Temp_C_mean',
                                      site = 'fcre')
#----------------------------------------#

# write forecast locally
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
# example for multiple sites
# site <- c('fcre', 'bvre')
# forecast <- site |>
#   map(generate_example_forecast,
#       forecast_date = forecast_date,
#       model_id = model_id,
#       targets_url = "https://renc.osn.xsede.org/bio230121-bucket01/vera4cast/targets/project_id=vera4cast/duration=P1D/daily-insitu-targets.csv.gz",
#       var = 'Temp_C_mean') |>
#   list_rbind()
