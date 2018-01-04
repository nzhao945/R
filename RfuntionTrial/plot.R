Orange$Tree <- as.numeric(Orange$Tree)
ntrees <- max(Orange$Tree)
xrange <- range(Orange$age)
yrange <- range(Orange$circumference)
plot(xrange,yrange,type = "n")

colors <- rainbow(ntrees)
linetype <- c(1:ntrees)
plotchar <- seq(18,18+ntrees,1)
lgd <- paste("tree",1:ntrees,seq="")
for (i in 1:ntrees) {
  tree <- subset(Orange,Tree==i)
  lines(tree$age,tree$circumference,type = "b",lwd=2,lty=linetype[i],col=colors[i],pch=plotchar[i])
  }
#legend(xrange[1],yrange[2],lgd,cex = .8,col = colors,pch = plotchar,lty = linetype)
legend("topleft",lgd,cex = .8,col = colors,pch = plotchar,lty = linetype)