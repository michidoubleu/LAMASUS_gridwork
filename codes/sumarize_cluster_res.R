rm(list = ls())


library(stringr)
library(withr)
library(tidyr)
library(elevatr)
library(sf)
library(stringi)

##################################################################################
run.nr <- 40
cluster.nr <- 2530


full.map <- NULL
i <- 23

for (i in 1:run.nr){
  load(paste0("./output/output_",cluster.nr,".",with_options(
    c(scipen = 999),
    str_pad(i, 6, pad = "0")
  ),".RData"))


  full.map <- full.map %>% bind_rows(extraction)
}

full.map <-  full.map %>% distinct() %>% pivot_wider(id_cols = CELLCODE, names_from = "LUM", values_from = "area", values_fill = 0) %>% mutate(area=rowSums(select_if(., is.numeric)))


write.csv(full.map, file="./output/LUM_areas.csv", row.names = F)
