-   [1 This VERA tutorial:](#this-vera-tutorial)
-   [2 Introduction to VERA Forecast
    Challenge](#introduction-to-vera-forecast-challenge)
    -   [2.1 The Challenge](#the-challenge)
    -   [2.2 Submission requirements](#submission-requirements)
        -   [2.2.1 File format](#file-format)
-   [3 The forecasting workflow](#the-forecasting-workflow)
    -   [3.1 Read in the data](#read-in-the-data)
    -   [3.2 Visualize the data](#visualize-the-data)
-   [4 Introducing co-variates](#introducing-co-variates)
    -   [4.1 Download co-variates](#download-co-variates)
        -   [4.1.1 Download historical weather
            forecasts](#download-historical-weather-forecasts)
        -   [4.1.2 Download future weather
            forecasts](#download-future-weather-forecasts)
-   [5 Linear model with co-variates](#linear-model-with-co-variates)
    -   [5.1 Convert to forecast standard for
        submission](#convert-to-forecast-standard-for-submission)
-   [6 Submit forecast](#submit-forecast)
-   [7 TASKS](#tasks)
-   [8 Register your participation](#register-your-participation)
-   [9 What’s next?](#whats-next)

# 1 This VERA tutorial:

This document presents a short tutorial to get you started generating
ecological forecasts, specifically for submission to the Virginia
Ecoforecast Reservoir Analysis (VERA) Forecast Challenge. The materials
are modified from those initially developed for the EFI-NEON Forecast
Challenge (found [here](https://zenodo.org/records/8316966)). To learn
more about the VERA Forecast Challenge (see our
[website](https://www.ltreb-reservoirs.org/vera4cast/)).

The development of these materials has been supported by NSF grants
DEB-2327030, DEB-1926388, and DBI-1933016.

To complete the tutorial via this markdown document, the following R
packages will need to be installed first:

-   `remotes`
-   `tidyverse`
-   `lubridate`
-   `RopenMeteo` (from Github)
-   `vera4castHelpers` (from Github)

The following code chunk should be run to install packages.

``` r
install.packages('remotes')
install.packages('tidyverse') # collection of R packages for data manipulation, analysis, and visualisation
install.packages('lubridate') # working with dates and times
install.packages('here')

remotes::install_github('FLARE-forecast/RopenMeteo') # R interface with API OpenMeteo - weather forecasts
remotes::install_github('LTREB-reservoirs/vera4castHelpers') # package to assist with forecast submission
```

``` r
library(tidyverse)
```

    ## ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ## ✔ dplyr     1.1.3     ✔ readr     2.1.4
    ## ✔ forcats   1.0.0     ✔ stringr   1.5.1
    ## ✔ ggplot2   3.5.0     ✔ tibble    3.2.1
    ## ✔ lubridate 1.9.3     ✔ tidyr     1.3.1
    ## ✔ purrr     1.0.2     
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()
    ## ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
library(lubridate)
library(ggplot2); theme_set(theme_bw())
library(vera4castHelpers)
```

If you do not wish to run the code yourself, you can alternatively
follow along via the markdown document (tutorial.md).

# 2 Introduction to VERA Forecast Challenge

The VERA Forecast Challenge is hosted by the Center for Ecosystem
Forecasting at Virginia Tech [CEF](https://ecoforecast.centers.vt.edu).
We are using forecasts to compare the predictability of different
ecosystem variables, across many different ecosystem conditions, to
identify the fundamental predictability of freshwater ecosystems.

The VERA Forecast Challenge is one component of the Virginia Reservoirs
LTREB project, which is both monitoring and forecasting two reservoirs
with contrasting dissolved oxygen conditions in southwestern Virginia,
USA to broadly advance our understanding of freshwater ecosystem
predictability.

## 2.1 The Challenge

**What**: Freshwater water quality.

**Where**: Two Virginia reservoirs (managed by the Western Virginia
Water Authority) and the stream that connects them. To learn more about
these freshwater ecosystems, see
[here](https://www.ltreb-reservoirs.org/reservoirs/).

**When**: Daily forecasts for at least 30 days-ahead in the future. New
forecast submissions that are continuously updated with observations as
soon as they become available are accepted daily. The only requirement
is that submissions are predictions of the future at the time the
forecast is submitted.

For the VERA Challenge, you can chose to submit to any combination of
sites and variables using any method. Find more information about the
targets available
[here](https://www.ltreb-reservoirs.org/vera4cast/targets.html).

## 2.2 Submission requirements

For the VERA Challenge, submitted forecasts must include *quantified
uncertainty*. The submitted file can represent uncertainty using an
ensemble forecast (multiple realizations of future conditions) or a
distribution forecast (defined by different parameters depending on the
distribution), specified in the family and parameter columns of the
forecast file.

### 2.2.1 File format

The file is a csv format with the following columns:

-   `project_id`: use `vera4cast`.

-   `model_id`: the short name of the model defined as the `model_id` in
    the file name (see below) and in your registration. The `model_id`
    should have no spaces.

-   `datetime`: forecast timestamp. Format `%Y-%m-%d %H:%M:%S`.

-   `reference_datetime`: the start of the forecast (0 times steps into
    the future). There should only be one value of reference_datetime in
    the file. Format is `%Y-%m-%d %H:%M:%S`.

-   `duration`: the time-step of the forecast. Use the value of P1D for
    a daily forecast and PT1H for an hourly forecast.

-   `site_id`: code for site.

-   `depth_m`: the depth (meters) for the forecasted variable.

-   `family`: name of the probability distribution that is described by
    the parameter values in the parameter column. For an ensemble
    forecast, the `family` column uses the word `ensemble` to designate
    that it is a ensemble forecast and the parameter column is the
    ensemble member number (1, 2, 3 …). For a distribution forecast, the
    `family` describes the type of distribution. For a parametric
    forecast with a normal distribution, the `family` column uses the
    word `normal` to designate a normal distribution and the parameter
    column must have values of `mu` and `sigma` for each forecasted
    variable, site_id, depth and time combination.

Parametric forecasts for binary variables should use bernoulli as the
distribution.

The following names and parameterization of the distribution are
supported (family: parameters):

-   lognormal: mu, sigma
-   normal: mu,sigma
-   bernoulli: prob
-   beta: shape1, shape2
-   uniform: min, max
-   gamma: shape, rate
-   logistic: location, scale
-   exponential: rate
-   poisson: lambda

If you are submitting a forecast that is not in the supported list
above, we recommend using the ensemble format and sampling from your
distribution to generate a set of ensemble members that represents your
distribution. The full list of required columns and format can be found
in the [Challenge
documentation](https://www.ltreb-reservoirs.org/vera4cast/instructions.html#forecast-file-format).

-   `parameter` the parameters for the distribution or the number of the
    ensemble members.

-   `variable`: standardized variable name.

-   `prediction`: forecasted value.

# 3 The forecasting workflow

## 3.1 Read in the data

We start forecasting by first looking at the historicalal data - called
the *targets*. These data are available in near real-time, with the
latency of approximately 24-48 hrs. Here is how you read in the data
from the targets file available:

``` r
#read in the targets data
targets <- read_csv('https://renc.osn.xsede.org/bio230121-bucket01/vera4cast/targets/project_id=vera4cast/duration=P1D/daily-insitu-targets.csv.gz')
```

Information on the VERA sites can be found in the
`vera4cast_field_site_metadata.csv` file on GitHub. This table has
information about the field sites, including location, reservoir depth,
and surface area.

``` r
# read in the sites data
site_list <- read_csv("https://raw.githubusercontent.com/LTREB-reservoirs/vera4cast/main/vera4cast_field_site_metadata.csv",
                      show_col_types = FALSE)
```

Let’s take a look at the targets data!

    ## Rows: 126,674
    ## Columns: 7
    ## $ project_id  <chr> "vera4cast", "vera4cast", "vera4cast", "vera4cast", "vera4…
    ## $ site_id     <chr> "fcre", "fcre", "fcre", "fcre", "fcre", "fcre", "fcre", "f…
    ## $ datetime    <dttm> 2018-07-06, 2018-07-06, 2018-07-06, 2018-07-06, 2018-07-0…
    ## $ duration    <chr> "P1D", "P1D", "P1D", "P1D", "P1D", "P1D", "P1D", "P1D", "P…
    ## $ depth_m     <dbl> 1.6, 1.6, 1.6, 1.6, 1.6, 1.6, 1.6, 1.6, 1.6, 1.6, 1.6, 1.6…
    ## $ variable    <chr> "Temp_C_mean", "SpCond_uScm_mean", "Chla_ugL_mean", "fDOM_…
    ## $ observation <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…

The columns of the targets file show the time step (duration, P1D), the
4 character site code (`site_id`), the variable being measured, and the
mean daily observation. We will start by just looking at Falling Creek
Reservoir (`fcre`).

``` r
site_list <- site_list %>%
  filter(site_id == 'fcre')

targets <- targets %>%
  filter(site_id == 'fcre')

targets |> distinct(variable) |> pull()
```

    ##  [1] "Temp_C_mean"                         
    ##  [2] "SpCond_uScm_mean"                    
    ##  [3] "Chla_ugL_mean"                       
    ##  [4] "fDOM_QSU_mean"                       
    ##  [5] "Turbidity_FNU_mean"                  
    ##  [6] "Bloom_binary_mean"                   
    ##  [7] "DO_mgL_mean"                         
    ##  [8] "DOsat_percent_mean"                  
    ##  [9] "GreenAlgae_ugL_sample"               
    ## [10] "Bluegreens_ugL_sample"               
    ## [11] "BrownAlgae_ugL_sample"               
    ## [12] "MixedAlgae_ugL_sample"               
    ## [13] "TotalConc_ugL_sample"                
    ## [14] "GreenAlgaeCM_ugL_sample"             
    ## [15] "BluegreensCM_ugL_sample"             
    ## [16] "BrownAlgaeCM_ugL_sample"             
    ## [17] "MixedAlgaeCM_ugL_sample"             
    ## [18] "TotalConcCM_ugL_sample"              
    ## [19] "ChlorophyllMaximum_depth_sample"     
    ## [20] "DeepChlorophyllMaximum_binary_sample"
    ## [21] "Secchi_m_sample"                     
    ## [22] "MOM_binary_sample"                   
    ## [23] "ThermoclineDepth_m_mean"             
    ## [24] "CO2flux_umolm2s_mean"                
    ## [25] "CH4flux_umolm2s_mean"                
    ## [26] "TN_ugL_sample"                       
    ## [27] "TP_ugL_sample"                       
    ## [28] "NH4_ugL_sample"                      
    ## [29] "NO3NO2_ugL_sample"                   
    ## [30] "SRP_ugL_sample"                      
    ## [31] "DOC_mgL_sample"                      
    ## [32] "CH4_umolL_sample"                    
    ## [33] "CO2_umolL_sample"

There are a number of different physical, chemical, and biological
variables with observations at fcre. We will start by just looking at
P1D Temp_C_mean (mean daily water temperatures).

``` r
targets <- targets %>%
  filter(variable == 'Temp_C_mean',
         duration == 'P1D')
```

## 3.2 Visualize the data

<figure>
<img src="tutorial_files/figure-markdown_github/targets-1.png"
alt="Figure: Temperature targets data at FCR" />
<figcaption aria-hidden="true">Figure: Temperature targets data at
FCR</figcaption>
</figure>

We can think about what type of models might be useful to predict water
temperature. Below are descriptions of three simple models to get you
started forecasting:

-   We could use information about current conditions to predict the
    next day. What is happening today is usually a good predictor of
    what will happen tomorrow (persistence model).
-   We could also think about what the historicalal data tells us about
    reservoir dynamics this time of year. For example, conditions in
    January this year are likely to be similar to January last year
    (climatology/day-of-year model)
-   We could also look at the lake variables’ relationship(s) with other
    variables. For example, we could use existing forecasts about the
    weather to generate forecasts about the reservoir variables.

To start, we will produce forecasts for just one of these depths - the
focal depth at fcre, 1.6 m.

``` r
targets <- targets %>%
  filter(depth_m == 1.6)
```

# 4 Introducing co-variates

One important step to overcome when thinking about generating forecasts
is to include co-variates in the model. A water temperature forecast,
for example, may be benefit from information about past and future
weather. The `vera4castHelpers` package includes functions for
downloading past and future NOAA weather forecasts for the VERA sites.
The 3 types of data are as follows:

-   stage_1: raw forecasts - 31 member ensemble forecasts at 3 hr
    intervals for the first 10 days, and 6 hr intervals for up to 35
    days at the NEON sites.
-   stage_2: a processed version of Stage 1 in which fluxes are
    standardized to per second rates, fluxes and states are interpolated
    to 1 hour intervals and variables are renamed to match conventions.
    We recommend this for obtaining future weather. Future weather
    forecasts include a 30-member ensemble of equally likely future
    weather conditions.
-   stage_3: can be viewed as the “historicalal” weather and is
    combination of day 1 weather forecasts (i.e., when the forecasts are
    most accurate).

This code create a connection to the dataset hosted remotely at an S3
storage location. To download the data you have to tell the function to
`collect()` it. These data set can be subsetted and filtered using
`dplyr` functions prior to download to limit the memory usage.

You can read more about the NOAA forecasts available for the NEON sites
[here:](https://projects.ecoforecast.org/neon4cast-docs/Shared-Forecast-Drivers.html)

## 4.1 Download co-variates

### 4.1.1 Download historical weather forecasts

We will generate a water temperature forecast using `air_temperature` as
a co-variate. The following code chunk connects to the remote location,
filters the dataset to the sites and variables of interest and then
collects into our local environment.

``` r
# past stacked weather
historical_weather_s3 <- vera4castHelpers::noaa_stage3()

variables <- c("air_temperature")

historical_weather <- historical_weather_s3  |> 
  dplyr::filter(site_id %in% site_list$site_id,
                variable %in% variables) |> 
  dplyr::collect()

historical_weather
```

    ## # A tibble: 990,295 × 7
    ##    parameter datetime            variable   prediction family reference_datetime
    ##        <dbl> <dttm>              <chr>           <dbl> <chr>  <lgl>             
    ##  1         0 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ##  2         1 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ##  3         2 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ##  4         3 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ##  5         4 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ##  6         5 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ##  7         6 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ##  8         7 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ##  9         8 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ## 10         9 2020-10-01 00:00:00 air_tempe…       286. ensem… NA                
    ## # ℹ 990,285 more rows
    ## # ℹ 1 more variable: site_id <chr>

This is an hourly stacked ensemble of the one day ahead forecasts. We
can take a mean of these ensembles to get an estimate of mean daily
historical conditions. For the historical data we do not need the
individual ensemble members, and will train with the ensemble mean.

``` r
# aggregate the past to mean values
historical_weather <- historical_weather |> 
  mutate(datetime = as_date(datetime)) |> 
  group_by(datetime, site_id, variable) |> 
  summarize(prediction = mean(prediction, na.rm = TRUE), .groups = "drop") 

historical_weather
```

    ## # A tibble: 1,332 × 4
    ##    datetime   site_id variable        prediction
    ##    <date>     <chr>   <chr>                <dbl>
    ##  1 2020-10-01 fcre    air_temperature       287.
    ##  2 2020-10-02 fcre    air_temperature       285.
    ##  3 2020-10-03 fcre    air_temperature       283.
    ##  4 2020-10-04 fcre    air_temperature       284.
    ##  5 2020-10-05 fcre    air_temperature       285.
    ##  6 2020-10-06 fcre    air_temperature       285.
    ##  7 2020-10-07 fcre    air_temperature       289.
    ##  8 2020-10-08 fcre    air_temperature       290.
    ##  9 2020-10-09 fcre    air_temperature       286.
    ## 10 2020-10-10 fcre    air_temperature       287.
    ## # ℹ 1,322 more rows

### 4.1.2 Download future weather forecasts

We can then look at the future weather forecasts in the same way but
using the `noaa_stage2()`. The forecast becomes available from NOAA at
5am UTC the following day, so we need to use the air temperature
forecast from yesterday (`noaa_date`) to make our real-time water
quality forecasts.

``` r
forecast_date <- Sys.Date() 
noaa_date <- forecast_date - days(1)

future_weather_s3 <- vera4castHelpers::noaa_stage2(start_date = as.character(noaa_date))
variables <- c("air_temperature")

future_weather <- future_weather_s3 |> 
  dplyr::filter(datetime >= forecast_date,
                site_id %in% site_list$site_id,
                variable %in% variables) |> 
  collect()
```

We can use the individual ensemble member in our model to include driver
uncertainty in the water temperature forecast. To generate a daily water
temperature forecast, we will use a daily water temperature to train and
run our model. This is calculated from the hourly data we have but
retains the ensemble members as a source of driver uncertainty.

``` r
# aggregate the past to mean values
future_weather <- future_weather |> 
  mutate(datetime = as_date(datetime)) |> 
  group_by(datetime, site_id, variable, parameter) |> # parameter is included in the grouping variables
  summarize(prediction = mean(prediction, na.rm = TRUE), .groups = "drop") 

future_weather
```

    ## # A tibble: 1,085 × 5
    ##    datetime   site_id variable        parameter prediction
    ##    <date>     <chr>   <chr>               <dbl>      <dbl>
    ##  1 2024-05-24 fcre    air_temperature         0       294.
    ##  2 2024-05-24 fcre    air_temperature         1       293.
    ##  3 2024-05-24 fcre    air_temperature         2       293.
    ##  4 2024-05-24 fcre    air_temperature         3       293.
    ##  5 2024-05-24 fcre    air_temperature         4       293.
    ##  6 2024-05-24 fcre    air_temperature         5       293.
    ##  7 2024-05-24 fcre    air_temperature         6       295.
    ##  8 2024-05-24 fcre    air_temperature         7       292.
    ##  9 2024-05-24 fcre    air_temperature         8       293.
    ## 10 2024-05-24 fcre    air_temperature         9       293.
    ## # ℹ 1,075 more rows

``` r
ggplot(future_weather, aes(x=datetime, y=prediction)) +
  geom_line(aes(group = parameter), alpha = 0.4)+
  geom_line(data = historical_weather) +
  facet_wrap(~variable, scales = 'free') +
  coord_cartesian(xlim = c(forecast_date - 150, forecast_date + 30))
```

![](tutorial_files/figure-markdown_github/weather-data-1.png)

We have separate `historical_weather` for training/calibration and
`future_weather` to generate a forecast. Finally, we will also convert
to Celsius from Kelvin.

``` r
historical_weather <- historical_weather |> 
  pivot_wider(names_from = variable, values_from = prediction) |>
  mutate(air_temperature = air_temperature - 273.15) # convert to degree C


future_weather <- future_weather |>
  pivot_wider(names_from = variable, values_from = prediction) |>
  mutate(air_temperature = air_temperature - 273.15) # convert to degree C
```

# 5 Linear model with co-variates

We will fit a simple linear model between historical air temperature and
the water temperature targets data. Using this model we can then use our
future forecasts of air temperature (all 31 ensembles from NOAA GEFS) to
estimate water temperature at each site. The ensemble weather forecast
will therefore propagate uncertainty into the water temperature forecast
and give an estimate of driving data uncertainty.

We will start by joining the historical weather data with the targets to
aid in fitting the linear model.

``` r
targets_lm <- targets |> 
  pivot_wider(names_from = 'variable', values_from = 'observation') |> 
  left_join(historical_weather, 
            by = c("datetime","site_id"))

tail(targets_lm)
```

    ## # A tibble: 6 × 7
    ##   project_id site_id datetime            duration depth_m Temp_C_mean
    ##   <chr>      <chr>   <dttm>              <chr>      <dbl>       <dbl>
    ## 1 vera4cast  fcre    2024-05-18 00:00:00 P1D          1.6        19.7
    ## 2 vera4cast  fcre    2024-05-19 00:00:00 P1D          1.6        19.7
    ## 3 vera4cast  fcre    2024-05-20 00:00:00 P1D          1.6        20.4
    ## 4 vera4cast  fcre    2024-05-21 00:00:00 P1D          1.6        20.7
    ## 5 vera4cast  fcre    2024-05-22 00:00:00 P1D          1.6        21.5
    ## 6 vera4cast  fcre    2024-05-23 00:00:00 P1D          1.6        21.7
    ## # ℹ 1 more variable: air_temperature <dbl>

To fit the linear model, we use the base R `lm()` but there are also
methods to fit linear (and non-linear) models in the `fable::` package.
You can explore the
[documentation](https://otexts.com/fpp3/regression.html) for more
information on the `fable::TSLM()` function.

``` r
# set up forecast df
forecast_df <- NULL
forecast_horizon <- 30 # make a 30 day-ahead forecast
forecast_dates <- seq(from = ymd(forecast_date), to = ymd(forecast_date) + forecast_horizon, by = "day")


# Fit linear model based on past data: water temperature = m * air temperature + b
fit <- lm(targets_lm$Temp_C_mean ~ targets_lm$air_temperature)
    
print(fit)
```

    ## 
    ## Call:
    ## lm(formula = targets_lm$Temp_C_mean ~ targets_lm$air_temperature)
    ## 
    ## Coefficients:
    ##                (Intercept)  targets_lm$air_temperature  
    ##                      5.250                       0.758

``` r
coeff <- fit$coefficients

# Use the fitted linear model to forecast water temperature for each ensemble member on each date
for (t in 1:length(forecast_dates)) {
    #pull driver ensemble for the relevant date; using all 31 NOAA ensemble members
  temp_driv <- future_weather |> 
    filter(datetime == forecast_dates[t])
  
  
  forecasted_temperature <- coeff[1] + coeff[2] * temp_driv$air_temperature

  # Put all the relevant information into a tibble that we can bind together
  temp_lm_forecast <- tibble(datetime = temp_driv$datetime,
                             site_id = temp_driv$site_id,
                             parameter = temp_driv$parameter,
                             prediction = forecasted_temperature,
                             variable = "Temp_C_mean")
  
  forecast_df <- dplyr::bind_rows(forecast_df, temp_lm_forecast)
  
}
```

We now have 31 possible forecasts of water temperature at each site and
each day. On this plot each line represents one of the possible
forecasts and the range of forecasted water temperature is a simple
quantification of the uncertainty in our forecast.

Looking at the forecasts we produced:

![](tutorial_files/figure-markdown_github/wq-forecast-1.png)

## 5.1 Convert to forecast standard for submission

A reminder of the columns needed for an ensemble forecast:

-   `datetime`: forecast timestamp for each time step
-   `reference_datetime`: The start of the forecast
-   `site_id`: code for site
-   `family`: describes how the uncertainty is represented
-   `parameter`: integer value for forecast replicate
-   `variable`: standardized variable name
-   `prediction`: forecasted value
-   `model_id`: model name (no spaces) - including `example` will ensure
    we don’t need to register!

The columns `project_id`, `depth_m`, and `duration` are also needed. For
a daily forecast the duration is `P1D`. We produced a water temperature
forecast at the focal depth only (1.6 m).

``` r
# Remember to change the model_id when you make changes to the model structure!
model_id <- 'example_ID'

forecast_df_standard <- forecast_df %>%
  mutate(model_id = model_id,
         reference_datetime = forecast_date,
         family = 'ensemble',
         parameter = as.character(parameter),
         duration = 'P1D', 
         depth_m = 1.6,
         project_id = 'vera4cast') %>%
  select(datetime, reference_datetime, site_id, duration, family, parameter, variable, prediction, depth_m, model_id, project_id)
```

# 6 Submit forecast

Files need to be in the correct format for submission. The forecast
organizers have created tools to help aid in the submission process.
These tools can be downloaded from Github using
`remotes::install_github('LTREB-reservoirs/vera4castHelpers')`. These
include functions for submitting, scoring, and reading forecasts:

-   `submit()` - submit the forecast file to the VERA Challenge, where
    it will be scored
-   `forecast_output_validator()` - check the file is in the correct
    format to be submitted

``` r
# Start by writing the forecast to file
save_here <- 'Forecasts/' # just for helpful organisation
forecast_file <- paste0(save_here, forecast_date, '-', model_id, '.csv')

if (dir.exists(save_here)) {
  write_csv(forecast_df_standard, forecast_file)
} else {
  dir.create(save_here)
  write_csv(forecast_df_standard, forecast_file)
}
```

``` r
vera4castHelpers::forecast_output_validator(forecast_file = forecast_file)
```

    ## Forecasts/2024-05-24-example_ID.csv

    ## ✔ file has model_id column
    ## ✔ forecasted variables found correct variable + prediction column
    ## ✔ file has correct family and parameter columns
    ## ✔ file has site_id column
    ## ✔ file has datetime column
    ## ✔ file has correct datetime column
    ## ✔ file has duration column
    ## ✔ file has depth column
    ## ✔ file has project_id column
    ## ✔ file has reference_datetime column
    ## Forecast format is valid

    ## [1] TRUE

The checks show us that our forecast is valid and we can go ahead and
submit it!

``` r
vera4castHelpers::submit(forecast_file = forecast_file)
```

Is the linear model a reasonable relationship between air temperature
and water temperature? Would a non-linear relationship be better? What
about using yesterday’s air and water temperatures to predict tomorrow?
Or including additional parameters? There’s a lot of variability in
water temperatures unexplained by air temperature alone.

![](tutorial_files/figure-markdown_github/linear-model-1.png)

# 7 TASKS

Possible modifications to the simple linear model:

-   Include additional weather co-variates in the linear model. List
    them in the `noaa_stage2` and `noaa_stage3` functions before
    `collect()`.
-   Specify a non-linear relationship.
-   Try forecasting another variable - could you use your water
    temperature to estimate dissolved oxygen concentration at the
    surface? To learn more about the other focal variables, see
    [here](https://www.ltreb-reservoirs.org/vera4cast/targets.html).
-   Include a lag in the predictors.
-   Add another source of uncertainty - what are the errors in the
    linear model? - Check out [Macrosystems EDDIE module
    6](https://github.com/MacrosystemsEDDIE/module6_R)!

Until you start submitting ‘real’ forecasts you can (should) keep
`example` in the model_id. These forecasts are processed and scored but
are not retained for longer than 1 month.

# 8 Register your participation

It’s really important that once you start submitting forecasts to the
Challenge that you register your participation. You will not be able to
submit a forecast that is not an example, without first registering the
model_id, with associated metadata. You should register
[here](https://forms.gle/kg2Vkpho9BoMXSy57).

Read more on the VERA Forecast Challenge website
<https://www.ltreb-reservoirs.org/vera4cast/instructions.html>.

# 9 What’s next?

More information and some helpful materials about adding additional
sources of uncertainty and developing your forecasts can be found on the
[VERA
website](https://www.ltreb-reservoirs.org/vera4cast/learn-more.html).

Once you’re happy with your model, you can follow the instructions in
the `forecast_code` directory to start submitting automated forecasts.
