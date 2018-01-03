library(ggplot2)
p <- ggplot(mtcars,mapping=aes(mpg,wt,col=cyl))+
  geom_point()  #设定散点的颜色为蓝色 geom_point(col="blue) 
  ##geom_point(aes(col="blue"))  错误的映射关系，
  ##在aes中, color = “blue”的实际意思是把”blue”当为一个变量，按默认的颜色标度标记为桃红色
   # +geom_smooth()
p
