rm(list=ls())

library(terra)
library(dplyr)
library(tidyr)
library(rgdal)
library(raster)

# Define the extent of Europe in EPSG:3035
# This extent is approximate and may need adjustments depending on your specific needs

EEAref_LAMAnuts <- read.csv("./output/EEAref_LAMAnuts_mapping_large.csv")
xmin <- min(as.numeric(substr(EEAref_LAMAnuts$onesqkmID,5,8)))
xmax <- max(as.numeric(substr(EEAref_LAMAnuts$onesqkmID,5,8)))
ymin <- min(as.numeric(substr(EEAref_LAMAnuts$onesqkmID,10,13)))
ymax <- max(as.numeric(substr(EEAref_LAMAnuts$onesqkmID,10,13)))

eu.pixel.buffer <- EEAref_LAMAnuts$onesqkmID
eu.pixel <- EEAref_LAMAnuts$onesqkmID[substr(EEAref_LAMAnuts$NUTS_ID,1,3)!="NA_"]
rm("EEAref_LAMAnuts")


# xmin, xmax, ymin, ymax
europe_extent <- ext(xmin*1000,xmax*1000,ymin*1000,ymax*1000)

# Define the resolution (1km x 1km)
res <- 1000

# Create the raster
europe_raster <- rast(europe_extent, resolution = res, crs = "EPSG:3035")

coordinates <- as.data.frame(crds(europe_raster)) %>% mutate(x=(x-500)/1000,y=(y-500)/1000, label=paste0("1kmE",x,"N", y))
coordinates$label[!coordinates$label%in%eu.pixel.buffer] <- NA
mapping <- data.frame(CELLCODE=coordinates$label)
rm("eu.pixel.buffer")
mapping$onesqkmID.buffer <- as.integer(as.factor(mapping$CELLCODE))
mapping$onesqkmID <- mapping$onesqkmID.buffer
mapping$onesqkmID[!coordinates$label%in%eu.pixel] <- NA
rm("eu.pixel")


values(europe_raster) <- mapping$onesqkmID.buffer
# Define the file path where you want to save the TIFF file
file_path <- "./output/LAMA_1km/LAMASUS_1km_buffer.tif"
# Save the spatRast object to a TIFF file
terra::writeRaster(europe_raster, filename = file_path ,  gdal=c("COMPRESS=LZW"), overwrite=TRUE)

values(europe_raster) <- mapping$onesqkmID
# Define the file path where you want to save the TIFF file
file_path <- "./output/LAMA_1km/LAMASUS_1km.tif"
# Save the spatRast object to a TIFF file
terra::writeRaster(europe_raster, filename = file_path ,  gdal=c("COMPRESS=LZW"), overwrite=TRUE)





EEAref_EEAbiogeo <- read.csv("./output/EEAref_EEAbiogeo_mapping_test.csv")
mapping$bio.geo <- EEAref_EEAbiogeo$EEAbiogeo.reg[match( mapping$CELLCODE,EEAref_EEAbiogeo$CELLCODE)]

bio.geo.rast <- europe_raster
values(bio.geo.rast) <- mapping$bio.geo
file_path <- "./output/LAMA_1km/EEA_BioGeo_raster.tif"
writeRaster(bio.geo.rast, filename = file_path, gdal=c("COMPRESS=LZW"), overwrite=T)

mapping <- mapping %>% filter(!is.na(CELLCODE))

write.csv(mapping, file="./output/onesqkmID_mapping.csv", row.names = F)

