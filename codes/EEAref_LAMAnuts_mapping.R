rm(list=ls())

library(tidyverse)
library(sf)
library(terra)
library(exactextractr)
library(progress)

LAMA.shp <- read_sf("./input/NUTS_LAMASUS/shp_nuts.shp") %>% filter(LEVL_CODE==3) %>% dplyr::select(NUTS_ID)
folder.grid <- list.files("./input/EEA_1km", full.names = TRUE)
full.map <- NULL

LAMA.shp.map <- data.frame(col.id=as.numeric(row.names(LAMA.shp)), NUTS_ID=LAMA.shp$NUTS_ID)

cc <- folder.grid[30]
for(cc in folder.grid){
  folder.files <- list.files(cc, full.names = TRUE)
  folder.files <- folder.files[grep(".shp",folder.files)]

  pos1 <- which(cc==folder.grid)
  tot1 <- length(folder.grid)
  split_string <- strsplit(cc, "/")[[1]]
  region_name <- tail(split_string, 1)
  cat("   Processing ",region_name, ", country ",pos1, "/",tot1, "\n", sep = "")


  temp.agg <- st_read(folder.files, quiet = TRUE)
  temp.agg <- st_transform(temp.agg, terra::crs(LAMA.shp))
  temp.agg.centr <- st_centroid(temp.agg)

  tmp.overlay.tbl <- as.data.frame(st_intersects(temp.agg,LAMA.shp)) %>% left_join(data.frame(row.id=as.numeric(row.names(temp.agg)), CELLCODE=temp.agg$CELLCODE), by="row.id") %>% left_join(LAMA.shp.map, by="col.id") %>% dplyr::select(CELLCODE, NUTS_ID) %>% distinct() %>% mutate(cover=as.factor(c("g")))

  temp.overlay.centr <- as.data.frame(st_intersects(temp.agg.centr,LAMA.shp)) %>% left_join(data.frame(row.id=as.numeric(row.names(temp.agg.centr)), CELLCODE=temp.agg.centr$CELLCODE), by="row.id") %>% left_join(LAMA.shp.map, by="col.id") %>% dplyr::select(CELLCODE, NUTS_ID) %>% distinct() %>% mutate(cover=as.factor(c("c")))

  codes <- temp.overlay.centr$CELLCODE

  tmp.overlay.tbl <- tmp.overlay.tbl %>% filter(!CELLCODE%in%codes) %>% bind_rows(temp.overlay.centr)


  non.unique <- tmp.overlay.tbl[duplicated(tmp.overlay.tbl[,1]) | duplicated(tmp.overlay.tbl[,1], fromLast = TRUE), ]
  non.unique.pix <- non.unique$CELLCODE

  temp.agg.small <- temp.agg %>% filter(CELLCODE%in%non.unique.pix)
  temp.overlay.small <- as.data.frame(st_intersection(temp.agg.small,LAMA.shp) %>% mutate(area=st_area(.))) %>% dplyr::select(CELLCODE, NUTS_ID, area)


  df_unique <- temp.overlay.small %>%
    group_by(CELLCODE) %>%
    arrange(desc(area)) %>%
    slice(1) %>%
    ungroup() %>% dplyr::select(-area) %>% mutate(cover=as.factor(c("s")))

  yes.unique <- tmp.overlay.tbl[!(duplicated(tmp.overlay.tbl[,1]) | duplicated(tmp.overlay.tbl[,1], fromLast = TRUE)), ]

  tmp.overlay.tbl <- yes.unique %>% bind_rows(df_unique)
  full.map <- full.map %>% bind_rows(tmp.overlay.tbl)

}



full.map <- full.map%>% mutate(NUTS_ID=as.factor(NUTS_ID)) %>% distinct()



full.map <- full.map %>% dplyr::select(-cover)


write.csv(full.map, file="./output/EEAref_LAMAnuts_mapping_v2.csv", row.names = F)
