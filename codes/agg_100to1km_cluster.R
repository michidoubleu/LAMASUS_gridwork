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

args <- commandArgs(trailingOnly=TRUE)
JOB <- ifelse(.Platform$GUI == "RStudio",1,as.integer(args[[1]]))
dir.create("output")

cc <- folder.grid[JOB]


  folder.files <- list.files(cc, full.names = TRUE)
  folder.files <- folder.files[grep(".shp",folder.files)]

  temp.agg <- st_read(folder.files, quiet = TRUE)
  m100.grid <- rast("./input/LU/LUC/CLC_Annual_TS_2000.tif")
  m100.grid <- crop(m100.grid,ext(temp.agg))

  extraction <- exactextractr::exact_extract(m100.grid, temp.agg, force_df=T)
  names(extraction) <- temp.agg$CELLCODE


  extraction <- lapply(extraction, my.summary)
  extraction <- bind_rows(extraction, .id = "CELLCODE") %>% mutate(LUM=paste0("LUM",value)) %>% dplyr::select(-value)


save(extraction, file="output/output.RData")