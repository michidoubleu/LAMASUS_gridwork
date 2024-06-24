# connect mappings

EEAref_EEAbiogeo <- read.csv("./output/EEAref_EEAbiogeo_mapping.csv")
EEAref_LAMAnuts <- read.csv("./output/EEAref_LAMAnuts_mapping.csv")


full1km.mapping <- EEAref_LAMAnuts %>% left_join(EEAref_EEAbiogeo)
