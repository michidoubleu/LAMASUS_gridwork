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
  EEA.biogeo.shp.temp <- st_crop(EEA.biogeo.shp, temp.agg)
  EEA.biogeo.shp.temp <- EEA.biogeo.shp.temp %>% dplyr::select(short_name)
  EEA.biogeo.shp.map <- data.frame(col.id=as.numeric(row.names(EEA.biogeo.shp.temp)), EEAbiogeo.reg=EEA.biogeo.shp.temp$short_name)



  tmp.overlay.tbl <- as.data.frame(st_intersects(temp.agg,EEA.biogeo.shp.temp)) %>% left_join(data.frame(row.id=as.numeric(row.names(temp.agg)), CELLCODE=temp.agg$CELLCODE), by="row.id") %>% left_join(EEA.biogeo.shp.map, by="col.id")  %>% dplyr::select(CELLCODE, EEAbiogeo.reg) %>% unique()


  non.unique <- tmp.overlay.tbl[duplicated(tmp.overlay.tbl[,1]) | duplicated(tmp.overlay.tbl[,1], fromLast = TRUE), ]
  non.unique.pix <- non.unique$CELLCODE

  temp.agg.small <- temp.agg %>% filter(CELLCODE%in%non.unique.pix)
  temp.overlay.small <- as.data.frame(st_intersection(temp.agg.small,EEA.biogeo.shp.temp) %>% mutate(area=st_area(.))) %>% dplyr::select(CELLCODE, short_name, area)


  df_unique <- temp.overlay.small %>%
    group_by(CELLCODE) %>%
    arrange(desc(area)) %>%
    slice(1) %>%
    ungroup() %>% dplyr::select(-area) %>% rename("EEAbiogeo.reg"="short_name")

  yes.unique <- tmp.overlay.tbl[!(duplicated(tmp.overlay.tbl[,1]) | duplicated(tmp.overlay.tbl[,1], fromLast = TRUE)), ]

  tmp.overlay.tbl <- yes.unique %>% bind_rows(df_unique)


  full.map <- full.map %>% bind_rows(tmp.overlay.tbl)

}

full.map <- full.map %>% mutate(EEAbiogeo.reg=as.numeric(as.factor(EEAbiogeo.reg))) %>% unique()
full.map <- full.map[!duplicated(full.map$CELLCODE),]

write.csv(full.map, file="./output/EEAref_EEAbiogeo_mapping_test.csv", row.names = F)
