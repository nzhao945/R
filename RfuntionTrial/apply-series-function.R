## apply函数族
# 清空环境变量
rm(list=ls())

# 封装fun1
fun1<-function(x){
     myFUN<- function(x, c1, c2) {
         c(sum(x[c1],1), mean(x[c2])) 
       }
     apply(x,1,myFUN,c1='x1',c2=c('x1','x2'))
   }
# 封装fun2
fun2<-function(x){
     df<-data.frame()
     for(i in 1:nrow(x)){
         row<-x[i,]
         df<-rbind(df,rbind(c(sum(row[1],1), mean(row))))
       }
   }
# 封装fun3
fun3<-function(x){
     data.frame(x1=x[,1]+1,x2=rowMeans(x))
   }

# 生成数据集
x <- cbind(x1=3, x2 = c(400:1, 2:500))

# 分别统计3种方法的CPU耗时。
system.time(fun1(x))
system.time(fun2(x))
system.time(fun3(x))