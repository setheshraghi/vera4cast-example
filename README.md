# Example code repository and tutorial for the VERA Forecasting Challenge

This repository can be used as a template to develop automated workflows to submit forecasts to the [VERA (Virginia Ecoforecast Reservoir Analysis) Forecasting Challenge](https://www.ltreb-reservoirs.org/vera4cast/).

The repository is structured with the following sub-directories and files 

- tutorial: This contains an R Markdown document that steps through the process of generating a simple water temperature forecast for the VERA forecasting challenge. It takes you through the steps to access the targets data, meteorological weather drivers, model fitting, forecast generation and forecast submission! This is a good introduction to the Challenge and the overall forecasting workflow.
- forecast_code: This contains the scripts needed to generate a forecast. Most of the code is replicated from the tutorial as a template but should be edited with your own forecast code. The `load_packages.R` calls the package installation steps for the forecast and the `run_forecast.R` script is the main forecast code.
- .github/workflows: contains the yaml file needed to automate the forecast workflow. If you don't change the file structure in the repository, you won't need to modify anything here! Just follow the instructions below on automating your forecast.

## 1. Tutorial

This tutorial presents a simple linear model that generates a water temperature forecast for the VERA Forecasting Challenge. It introduces some tools and techniques that can be used to generate a forecast and steps through how to submit to the Challenge.

## 2. Forecast code

If you are familiar with forecasting approaches and have a model ready to implement the repository can be forked and the code within the `forecast_code` directory edited with the forecast generating code (`run_forecast.R`), any custom functions (`R`), and the relevant packages installed (`load_packages`). The `run_forecast.R` calls two custom forecast functions `generate_example_forecast` and `get_weather` from the `R` directory (THIS IS WHERE THE BULK OF THE MODIFICATIONS NEED TO OCCUR WHEN UPDATING TO YOUR FORECAST CODE). If you are not familiar with writing functions you can add all of your code to the `run_forecast.R` script. 

## 3. Automating your forecast

Automation is crucial for developing an iterative forecasting workflow. The `submit_forecast.yaml` contains the instructions that Github Actions will use to run the scripts in the `forecast_code` directory every day and submit new forecasts. The action uses a containerized environment for a consistent and predictable environment. The action uses the Rocker image `rqthomas/vera-rocker:latest`, and includes packages specific for VERA (Vera4castHelpers, RopenMeteo) in addition to many other commonly used R packages (e.g. tidyverse and data.table) from the [`geospatial`](https://rocker-project.org/images/versioned/rstudio.html#overview) Rocker. Any additional packages you need will need to be installed each time (include an install code in the `load_packages` script). Find instructions of workflow automation in the `forecast_code` directory.

# Instructions for completing the tutorial

## 1. Setting up your R environment

R version 4.2 is required to run the code in this workshop. You should also check that your Rtools is up to date and compatible with R 4.2, see (<https://cran.r-project.org/bin/windows/Rtools/rtools42/rtools.html>).

The following packages need to be installed using the following code.

```{r}
install.packages('remotes')
install.packages('tidyverse') # collection of R packages for data manipulation, analysis, and visualisation
install.packages('lubridate') # working with dates and times
remotes::install_github("LTREB-reservoirs/vera4castHelpers") # package from challenge organisers to assist with forecast submission
remotes::install_github("FLARE-forecast/RopenMeteo") # R wrapper for the Open Meteo API
```

## 2. Get the code

There are 3 options for getting the code locally so that you can run it, depending on your experience with Github/Git you can do one of the following:

1.  **Fork (recommended)** the repository to your Github and then clone the repository from your Github repository to a local RStudio project. This will allow you to modify the scripts and push it back to your Github (required if you are automating your forecast)!

-   Find the fork button in the top right of the webpage --\> Create Fork. This will generate a copy of this repository in your Github.
-   Then use the \<\> Code button to copy the HTTPS link (from you Github!).
-   In RStudio, go to New Project --\> Version Control --\> Git.
-   Paste the HTTPS link in the Repository URL space, and choose a suitable location for your local repository --\> Create Project.
-   Open `tutorial/tutorial.Rmd`. 

2.  **Clone** the workshop repository to a local RStudio project. Your local workspace will be set up and you can commit changes locally but they won't be pushed back to the Github repository.

-   Use the \<\> Code button to copy the HTTPS link.
-   In RStudio go to New Project --\> Version Control --\> Git.
-   Paste the HTTPS link in the Repository URL space, and choose a suitable location for your local repository --\> Create Project.
-   Open `tutorial/tutorial.Rmd`. 

3.  **Download** the zip file of the repository code. You can save changes (without version control) locally.

-   Find the \<\> Code button --\> Download ZIP.
-   Unzip this to a location on your PC and open the `vera4cast-example.Rproj` file in RStudio.
-   Open `tutorial/tutorial.Rmd`. 

More information on forking and cloning in R can be found at [happygitwithr](https://happygitwithr.com/fork-and-clone.html), a great resource to get you started using version control with RStudio.
