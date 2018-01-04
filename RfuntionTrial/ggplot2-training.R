library(ggplot2)
p <- ggplot(mtcars,mapping=aes(mpg,wt,col=factor(cyl)))+
  geom_point()  #设定散点的颜色为蓝色 geom_point(col="blue") 
  ##geom_point(aes(col="blue"))  错误的映射关系，“在aes内colour等于向量，在外等于颜色”
  ##在aes中, color = “blue”的实际意思是把”blue”当为一个变量，按默认的颜色标度标记为桃红色
   # +geom_smooth()
p

#采用多个数据集或向量数据绘图
mtcars.c <- transform(mtcars, mpg = mpg^2)
ggplot()+
  geom_point(aes(x = hp, y = mpg), data = mtcars, color = "red")+
  geom_point(aes(x = mtcars$hp, y = mtcars$disp), color = "green")+ 
  #在第一张散点图上，叠加了hp~disp的关系
  geom_point(aes(x = hp, y= mpg), data = mtcars.c, color = "blue")  
  #选用不同的数据集,在上一层基础上叠加了mtcars.c的图层  #选用不同的数据集,在上一层基础上叠加了mtcars.c的图层)

#尝试geom_point中aes的新参数shape、size、alpha等
ggplot(data=mtcars,aes(col=factor(cyl)))+
  geom_point(aes(x = hp, y = mpg,shape=factor(gear)), data = mtcars)




