library(ggplot2)
p <- ggplot(mtcars,aes(mpg,wt,col=cyl))+
  geom_point()
  # +geom_smooth()
