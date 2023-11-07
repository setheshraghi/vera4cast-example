# load required packages
source('load_packages.R')

# load the forecast function - needs a forecast date argument
source('R/generate_example_forecast.R')
source('R/get_weather.R')

# Generate the forecasts
# default is to run a realtime forecast
forecast_date <- Sys.Date()
site_list <- read_csv("https://raw.githubusercontent.com/LTREB-reservoirs/vera4cast/main/vera4cast_field_site_metadata.csv",
                      show_col_types = FALSE)

# this should generate a csv file
example_forecast_file <- generate_example_forecast(forecast_date = forecast_date,
                                                   model_id = 'example_forecast',
                                                   targets_url = "https://renc.osn.xsede.org/bio230121-bucket01/vera4cast/targets/project_id=vera4cast/duration=P1D/daily-insitu-targets.csv.gz",
                                                   var = 'Temp_C_mean',
                                                   sites = 'fcre')
# Submit forecast!
vera4castHelpers::submit(forecast_file = example_forecast_file)
