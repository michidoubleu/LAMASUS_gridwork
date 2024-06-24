library(terra)
library(dplyr)
library(tidyr)

# Define the extent of Europe in EPSG:3035
# This extent is approximate and may need adjustments depending on your specific needs

EEAref_LAMAnuts <- read.csv("./output/EEAref_LAMAnuts_mapping_v2.csv")
eu.pixel <- EEAref_LAMAnuts$CELLCODE

rm("EEAref_LAMAnuts")

# xmin, xmax, ymin, ymax
europe_extent <- ext(2500000, 7500000, 1000000, 5500000)

# Define the resolution (1km x 1km)
res <- 1000

# Create the raster
europe_raster <- rast(europe_extent, resolution = res, crs = "EPSG:3035")

coordinates <- as.data.frame(crds(europe_raster)) %>% mutate(x=(x-500)/1000,y=(y-500)/1000, label=paste0("1kmE",x,"N", y))
coordinates$label[!coordinates$label%in%eu.pixel] <- NA

rm("eu.pixel")

values(europe_raster) <- coordinates$label

# Define the file path where you want to save the TIFF file
file_path <- "./output/LAMA_1km/LAMASUS_1km_v2.tif"

# Save the spatRast object to a TIFF file
writeRaster(europe_raster, filename = file_path)


EEAref_EEAbiogeo <- read.csv("./output/EEAref_EEAbiogeo_mapping_v2.csv")

bio.geo <- EEAref_EEAbiogeo$EEAbiogeo.reg[match( coordinates$label, EEAref_EEAbiogeo$CELLCODE)]

bio.geo.rast <- europe_raster
values(bio.geo.rast) <- as.factor(bio.geo)
file_path <- "./output/LAMA_1km/EEA_BioGeo_raster.tif"
writeRaster(bio.geo.rast, filename = file_path, overwrite=T)
