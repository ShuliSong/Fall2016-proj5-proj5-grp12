library(RColorBrewer)
library(gridExtra)
library(grid)
library(reshape2)

##### Top Label ######

toplable<-function(cityname){
labels<-strsplit(as.character(sub$categories[sub$city2==cityname]), ",")
a<-unlist(labels)
a2<-a[a!="Restaurants" & a!="Food"]
a2[a2 =="American (Traditional)"]<-"American"
m<-data.frame(rate=(summary(as.factor(a2))/length(a2))[1:5])
t<-cbind(m,label=rownames(m))
t$label<-factor(t$label,levels = as.vector(t$label))
p <- ggplot(t, aes(x=label, y=rate, fill=label)) +
  geom_bar(stat="identity") + 
  xlab(cityname) + guides(fill=FALSE) +
  scale_fill_brewer(direction = -1)
return(p)
}
x<-apply(array(rownames(city)),1,toplable)
grid.arrange(x[[1]],x[[2]],x[[3]],x[[4]],x[[5]],x[[6]],x[[7]],x[[8]],x[[9]],ncol=3,nrow=3,
             top=textGrob("Top5 Labels of Restaurants in Each City",gp=gpar(fontsize=15)))


##### Rank Star Distribution ######

c<-table(sub[,c(54,57)])
c1<-c/matrix(colSums(c),ncol=9,nrow=9,byrow = T)

c2<-melt(c1,id.var=stars)
c2$stars<-as.factor(c2$stars)
c2$city2<-factor(c2$city2,levels=as.vector(rownames(city)))
p<-ggplot(c2,aes(x = city2, y = value*100, fill = stars)) +
  geom_bar(stat = "identity")+ 
  scale_fill_brewer(palette = "RdBu",direction = -1)+
  coord_flip() +
  ylab("Percent(%)") +
  xlab("City") + 
  ggtitle("Rank Star Distribution of Restaurants in Each City")
ggplotly(p)


