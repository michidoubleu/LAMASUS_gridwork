rm(list=ls())

library(dplyr)
library(terra)
library(exactextractr)
library(tidyr)
library(sf)
library(countrycode)

LAMA.shp <- read_sf("./input/NUTS_LAMASUS/shp_nuts.shp")
countries <- unique(LAMA.shp$CNTR_CODE)

EEA.names.long <- list.files("./input/EEA_1km")
EEA.names <- EEA.names.long %>% countrycode(., origin = "country.name", destination="iso2c")
EEA.names[is.na(EEA.names)] <- c("XK", "TR")

EEA.names <- data.frame(EEA.names=EEA.names, EEA.names.long=EEA.names.long)

mapping <- data.frame(EEA.names=countries, EEA.names.short=countries) %>% left_join(EEA.names)

mapping[mapping$EEA.names=="EL",c(2,3)] <- c("GR","Greece")
mapping[mapping$EEA.names=="UK",c(2,3)] <- c("GB","Great-Britain")
mapping[mapping$EEA.names=="AD",c(2,3)] <- c("SP","Spain")
mapping[mapping$EEA.names=="IM",c(2,3)] <- c("GB","Great-Britain")
mapping[mapping$EEA.names=="MC",c(2,3)] <- c("FR","France")
mapping[mapping$EEA.names=="OO",c(2,3)] <- c("GR","Greece")
mapping[mapping$EEA.names=="SM",c(2,3)] <- c("IT","Italy")
mapping[mapping$EEA.names=="VA",c(2,3)] <- c("IT","Italy")
mapping <- na.omit(mapping)

full.map <- NULL

ii <- mapping$EEA.names[41]
for(ii in mapping$EEA.names){

  pos1 <- which(ii==mapping$EEA.names)
  tot1 <- length(mapping$EEA.names)
  cat("   Processing ",ii, ", country ",pos1, "/",tot1, "\n", sep = "")

  tmp.shp <- LAMA.shp %>% filter(CNTR_CODE==ii)

  EEA.pointer <- which(ii==mapping$EEA.names)
  EEA.file <- paste0("./input/EEA_1km/",mapping[EEA.pointer,"EEA.names.long"],"/",tolower(mapping[EEA.pointer,"EEA.names.short"]),"_1km.shp")

  if(length(grep("//", EEA.file))!=0){next}

  EEA.grid <- st_read(EEA.file, quiet = TRUE)
  EEA.grid <- st_transform(EEA.grid, terra::crs(tmp.shp))
  center <- st_centroid(EEA.grid)

  tmp.overlay.tbl <- st_intersection(tmp.shp, center)
  tmp.overlay.tbl <- tmp.overlay.tbl %>% as.data.frame() %>% filter(nchar(NUTS_ID)==5) %>% dplyr::select(NUTS_ID, CELLCODE) %>% unique()

  full.map <- full.map %>% bind_rows(tmp.overlay.tbl)

}
