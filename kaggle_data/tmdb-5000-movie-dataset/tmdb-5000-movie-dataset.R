library(data.table)

tmdb_5000_credits <- fread(file = 'D:/tmdb-5000-movie-dataset/tmdb_5000_credits.csv', 
                           na.strings = c("NA","","N/A","null"), stringsAsFactors = F, header = T)
tmdb_5000_movies <- fread(file = 'D:/tmdb-5000-movie-dataset/tmdb_5000_movies.csv', 
                          na.strings = c("NA","","N/A","null"), stringsAsFactors = F, header = T)
