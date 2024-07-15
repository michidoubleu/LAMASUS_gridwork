rm(list = ls())


library(stringr)
library(withr)
library(tidyr)
library(elevatr)
library(sf)
library(stringi)

##################################################################################
run.nr <- 40
cluster.nr <- 2523


full.map <- NULL
i <- 2

for (i in 1:run.nr){
  load(paste0("./output/output_",cluster.nr,".",with_options(
    c(scipen = 999),
    str_pad(i, 6, pad = "0")
  ),".RData"))


  full.map <- full.map %>% bind_rows(extraction)
}

full.map <-  full.map %>% distinct() %>%
  mutate(LUM2000=as.numeric(substr(LUM,4,5))-10,
         LUM2010=as.numeric(substr(LUM,6,7))-10,
         LUM2018=as.numeric(substr(LUM,8,9))-10) %>% na.omit() %>% dplyr::select(-LUM)


write.csv(full.map, file="./output/LUM_change.csv", row.names = F)

