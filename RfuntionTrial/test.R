# rst <- c(rep("chr",ncol(x)))
# for (i in 1:ncol(x)) {
#     for (j in 1:nrow(x)) {
#     if (x[j,i]>0)  rst[i]<-colnames(x[i])
#     #print(colnames(x[i]))
#   }
#   
# }
# print(rst)
library(data.table)
mtcars_dt <- data.table(mtcars)
temp <- mtcars_dt[1:10]
tmp <- copy(temp)
dt <- data.table(x=rep(c("a","b","c"),times=3),y=1:9,z=rep(1:3,each=3),stringsAsFactors = F)
