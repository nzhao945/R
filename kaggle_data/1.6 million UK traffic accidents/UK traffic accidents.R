library(data.table)

uk_traffic0507 <- fread(file = "D:/1.6_million_UK_traffic_accidents/accidents_2005_to_2007.csv",
                        na.strings =c("NA","","N/A","null"), stringsAsFactors = F, header = T)
uk_traffic0911 <- fread(file = 'D:/1.6_million_UK_traffic_accidents/accidents_2009_to_2011.csv',
                        na.strings =c("NA","","N/A","null"), stringsAsFactors = F, header = T)
uk_traffic1214 <- fread(file = 'D:/1.6_million_UK_traffic_accidents/accidents_2012_to_2014.csv',
                        na.strings =c("NA","","N/A","null"), stringsAsFactors = F, header = T)
uk_traffic <- rbind(uk_traffic0507,uk_traffic0911,uk_traffic1214)
