library(data.table)
library(dplyr)

uk_traffic0507 <- fread(file = "D:/1.6_million_UK_traffic_accidents/accidents_2005_to_2007.csv",
                        na.strings =c("NA","","N/A","null"), stringsAsFactors = F, header = T)
uk_traffic0911 <- fread(file = 'D:/1.6_million_UK_traffic_accidents/accidents_2009_to_2011.csv',
                        na.strings =c("NA","","N/A","null"), stringsAsFactors = F, header = T)
uk_traffic1214 <- fread(file = 'D:/1.6_million_UK_traffic_accidents/accidents_2012_to_2014.csv',
                        na.strings =c("NA","","N/A","null"), stringsAsFactors = F, header = T)
uk_traffic <- rbind(uk_traffic0507,uk_traffic0911,uk_traffic1214)

uk_traffic <- bind_rows(uk_traffic0507, uk_traffic0911, uk_traffic1214)
ukTrafficAADF <- fread(file = '*D:/1.6_million_UK_traffic_accidents/ukTrafficAADF.csv',
                       na.strings =c("NA","","N/A","null"), stringsAsFactors = F, header = T, integer64 = 'numeric')

# 释放内存空间
rm(uk_traffic0507, uk_traffic0911, uk_traffic1214)

str(uk_traffic)
