rm(list=ls())

library(tidyverse)
library(sf)
library(terra)
library(exactextractr)


my.summary <- function(x){
  result <- x %>% group_by(value) %>% summarise(
    area = sum(coverage_fraction/100)
  )
  return(result)
}

folder.grid <- list.files("./input/EEA_1km", full.names = TRUE)
file.grid <- list.files("./input/LU/LUM/Management", pattern = ".tif", full.names = T)
full.grid <- expand.grid(folder.grid, file.grid)


args <- commandArgs(trailingOnly=TRUE)
JOB <- ifelse(.Platform$GUI == "RStudio",12,as.integer(args[[1]]))
dir.create("output")

curr.country <- as.character(full.grid[JOB,1])
curr.file <- as.character(full.grid[JOB,2])

folder.files <- list.files(curr.country, full.names = TRUE)
folder.files <- folder.files[grep(".shp",folder.files)]

temp.agg <- st_read(folder.files, quiet = TRUE)
m100.grid <- rast(curr.file)
m100.grid <- crop(m100.grid,ext(temp.agg))
crs(m100.grid) <- crs(temp.agg)

extraction <- exactextractr::exact_extract(m100.grid, temp.agg, force_df=T)
names(extraction) <- temp.agg$CELLCODE


extraction <- lapply(extraction, my.summary)
extraction <- bind_rows(extraction, .id = "CELLCODE") %>% mutate(LUM=paste0("LUM",value)) %>% dplyr::select(-value)


save(extraction, file="output/output.RData")