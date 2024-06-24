rm(list=ls())

library(tidyverse)
library(sf)
library(terra)
library(exactextractr)
library(progress)



folder.grid <- list.files("./input/EEA_1km", full.names = TRUE)
full.map <- NULL
m100.grid <- rast("./input/LUM_2018_with_FM.tif")

cc <- folder.grid[12]

for(cc in folder.grid){
  folder.files <- list.files(cc, full.names = TRUE)
  folder.files <- folder.files[grep(".shp",folder.files)]

  pos1 <- which(cc==folder.grid)
  tot1 <- length(folder.grid)
  split_string <- strsplit(cc, "/")[[1]]
  region_name <- tail(split_string, 1)
  cat("   Processing ",region_name, ", country ",pos1, "/",tot1, "\n", sep = "")

  temp.agg <- st_read(folder.files, quiet = TRUE)
  m100.grid <- rast("./input/LUM_2018_with_FM.tif")
  m100.grid <- crop(m100.grid,ext(temp.agg))
  gc()
  m100.grid <- as.data.frame(m100.grid, xy = TRUE, na.rm = T)
  m100.grid <- st_as_sf(m100.grid, coords = c("x", "y"), crs = crs(temp.agg))

  tmp.overlay.tbl <- as.data.frame(st_intersects(temp.agg,m100.grid)) %>% left_join(data.frame(row.id=as.numeric(row.names(temp.agg)), CELLCODE=temp.agg$CELLCODE), by="row.id")
  #%>% left_join(data.frame(col.id=seq(1,nrow(m100.grid),1), ID100=m100.grid$ID100), by="col.id") %>% dplyr::select(CELLCODE, ID100) %>% unique()


  full.map <- full.map %>% bind_rows(tmp.overlay.tbl)
}


full.map <- full.map[!duplicated(full.map$CELLCODE),]



###### to be cleaned based for duplicates











write.csv(full.map, file="./output/EEAref_ID100_mapping.csv", row.names = F)
