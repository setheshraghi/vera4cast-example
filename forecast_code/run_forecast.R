setwd(here::here())
source('forecast_code/load_packages.R')
source('forecast_code/R/generate_example_forecast.R')

forecast_date <- Sys.Date()
model_id <- 'churner_example'
source_python('report_on_enhancing_cfsv2_temperature_forecasts.py')
forecast <- as.data.frame(py$forecast)

message('Writing forecast')
save_here <- 'forecasts/'
forecast_file <- paste0(save_here, forecast_date, '-', model_id, '.csv')

if (dir.exists(save_here)) {
  write_csv(forecast, forecast_file)
} else {
  dir.create(save_here)
  write_csv(forecast, forecast_file)
}

# Submit forecast!
vera4castHelpers::forecast_output_validator(forecast_file = forecast_file)
vera4castHelpers::submit(forecast_file = forecast_file)
