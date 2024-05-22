rm(list=ls())

library(tidyverse)
library(sf)
library(terra)
library(exactextractr)
library(progress)

EEA.biogeo.shp <- read_sf("./input/EEA_biogeo/BiogeoRegions2016.shp")
folder.grid <- list.files("./input/EEA_1km", full.names = TRUE)
full.map <- NULL


cc <- folder.grid[1]
for(cc in folder.grid){
  folder.files <- list.files(cc, full.names = TRUE)
  folder.files <- folder.files[grep(".shp",folder.files)]

  pos1 <- which(cc==folder.grid)
  tot1 <- length(folder.grid)
  split_string <- strsplit(cc, "/")[[1]]
  region_name <- tail(split_string, 1)
  cat("   Processing ",region_name, ", country ",pos1, "/",tot1, "\n", sep = "")


  temp.agg <- st_read(folder.files, quiet = TRUE)
  temp.agg <- st_transform(temp.agg, terra::crs(EEA.biogeo.shp))
  temp.agg <- st_centroid(temp.agg)


  tmp.overlay.tbl <- st_intersection(EEA.biogeo.shp, temp.agg)
  tmp.overlay.tbl <- tmp.overlay.tbl %>% as.data.frame() %>% dplyr::select(CELLCODE, code) %>% unique()

  full.map <- full.map %>% bind_rows(tmp.overlay.tbl)

}


