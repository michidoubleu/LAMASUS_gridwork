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
JOB <- ifelse(.Platform$GUI == "RStudio",13,as.integer(args[[1]]))
dir.create("output")

cc <- folder.grid[JOB]


folder.files <- list.files(cc, full.names = TRUE)
folder.files <- folder.files[grep(".shp",folder.files)]

# pos1 <- which(cc==folder.grid)
# tot1 <- length(folder.grid)
# split_string <- strsplit(cc, "/")[[1]]
# region_name <- tail(split_string, 1)
# cat("   Processing ",region_name, ", country ",pos1, "/",tot1, "\n", sep = "")

temp.agg <- st_read(folder.files, quiet = TRUE)
m100.grid <- rast("./input/LU/LUC/CLC_Annual_TS_2000.tif")
m100.grid.1 <- crop(m100.grid,ext(temp.agg))
m100.grid <- rast("./input/LU/LUC/CLC_Annual_TS_2010.tif")
m100.grid.2 <- crop(m100.grid,ext(temp.agg))
m100.grid <- rast("./input/LU/LUC/CLC_Annual_TS_2018.tif")
m100.grid.3 <- crop(m100.grid,ext(temp.agg))


values(m100.grid.3) <- values(m100.grid.1)+10+100*(values(m100.grid.2)+10)+(values(m100.grid.3)+10)*10000

extraction <- exactextractr::exact_extract(m100.grid.3, temp.agg, force_df=T)
names(extraction) <- temp.agg$CELLCODE


extraction <- lapply(extraction, my.summary)
extraction <- bind_rows(extraction, .id = "CELLCODE") %>% mutate(LUM=paste0("LUM",value)) %>% dplyr::select(-value)


save(extraction, file="output/output.RData")