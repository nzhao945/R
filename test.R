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
mtcars_dt[1:10]