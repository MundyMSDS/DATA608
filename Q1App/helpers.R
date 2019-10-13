
# Dean Attali
# November 21 2014

# Helper functions for the cancer-data shiny app

library(magrittr)
library(tidyverse)

DATA_DIR <- file.path("data")

# Read the data and get it ready for the app
getData <- function() {
  
  # read the data file
  cDat <- read.table(file.path(DATA_DIR, "cdcData2L.csv"), sep = ",",
                     header = TRUE, row.names = NULL)
  
  # re-order the cancerType factor based on the order that was saved
  cDatTypeOrder <- read.table(file.path(DATA_DIR,
                                        "cdc_list.txt"),
                              header = FALSE, row.names = NULL, sep = ",")
  cDatTypeOrder %<>%
    first
  cDat %<>%
    mutate(cancerType = factor(cancerType, cDatTypeOrder))
    
  
  cDat
}

# Our data has 22 cancer types, so when plotting I wanted to have a good
# set of 22 unique colours
getPlotCols <- function() {
  c22 <- c("dodgerblue2","#E31A1C", # red
           "green4",
           "#6A3D9A", # purple
           "#FF7F00", # orange
           "black","gold1",
           "skyblue2","#FB9A99", # lt pink
           "palegreen2",
           "#CAB2D6", # lt purple
           "#FDBF6F", # lt orange
           "gray70", "khaki2", "maroon", "orchid1", "deeppink1", "blue1",
           "darkturquoise", "green1", "yellow4", "brown")
  c22
}

# Format a range of years in a nice, easy-to-read way
formatYearsText <- function(years) {
  if (min(years) == max(years)) {
    return(min(years))
  } else {
    return(paste(years, collapse = " - "))	
  }
}


#Calculate National Averages and append to dataset
getNatAvg <- function(df) {
  
  df2 <- df %>% 
    spread(stat, value) %>% 
    group_by(year,cancerType) %>% 
    mutate(tpop = sum(population)) %>% 
    mutate(wt = population / tpop) %>% 
    mutate(xi = wt* crude_rate) %>% 
    summarise(crude_rate = sum(xi),mean(tpop),sum(deaths)) %>% 
    mutate(state = "US") %>% 
    mutate(state= as.factor(state)) %>% 
    rename(population = `mean(tpop)`) %>% 
    rename(deaths = `sum(deaths)`) %>% 
    select(year, cancerType, state, crude_rate, deaths, population)
  
  df <- df %>% 
    spread(stat, value) %>% 
    as_tibble()
  
  df3 <- bind_rows(df, df2)
  
  df3 <- df3 %>% 
    mutate(state = as.factor(state))
  
  df <- df3 %>% 
    gather("crude_rate", "deaths", "population", key="stat", value="value") 
  
  df
  
  
}