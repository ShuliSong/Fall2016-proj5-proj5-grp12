library(plotly)
library(dplyr)
library(ggmap)
library(ggplot2)
library(maps)
library(devtools)
devtools::install_github("dkahle/ggmap")
devtools::install_github("hadley/ggplot2")
install_version("ggplot2", version = "2.1.0", repos = "http://cran.us.r-project.org")
sub<-read.csv("subset_bycity_bycat.csv")[,-1]

##### City Map ######
getMap<-function(cityname){
  qmap(cityname, zoom = 10,color = 'bw')+
  geom_point(aes(x = longitude, y = latitude),color="red",alpha=0.2,size=4,data = sub )
}

title1=textGrob(" ", gp=gpar(fontsize=80))

grid.arrange(arrangeGrob(getMap("Phoenix"),bottom=textGrob("Phoneix",gp=gpar(fontsize=40))),
             arrangeGrob(getMap("Las Vegas"),bottom=textGrob("Las Vegas",gp=gpar(fontsize=40))),
             arrangeGrob(getMap("Montreal"),bottom=textGrob("Montreal",gp=gpar(fontsize=40))),
             arrangeGrob(getMap("Charlotte"),bottom=textGrob("Charlotte",gp=gpar(fontsize=40))),
             arrangeGrob(getMap("Pittsburgh"),bottom=textGrob("Pittsburgh",gp=gpar(fontsize=40))),
             arrangeGrob(getMap("Edinburgh"),bottom=textGrob("Edinburgh",gp=gpar(fontsize=40))),
             arrangeGrob(getMap("Madison"),bottom=textGrob("Madison",gp=gpar(fontsize=40))),
             arrangeGrob(getMap("Karlsruhe"),bottom=textGrob("Karlsruhe",gp=gpar(fontsize=40))),
             arrangeGrob(getMap("Champaign"),bottom=textGrob("Champaign",gp=gpar(fontsize=40))),
             ncol=3,nrow=3,top=title1)
              

##### World Map ######

lat=c(33.4484,36.1699,45.5017,35.2271,40.4406,55.9533,43.0731,49.0069,40.1164)
long=c(-112.0740,-115.1398,-73.5673,-80.8431,-79.9959,-3.1883,-89.4012,8.4037,-88.2434)
city<-sort(summary(sub$city2)[1:9],decreasing = T)
city<-cbind(cnt=city,long=long,lat=lat)

mapWorld <- borders("world", colour="grey", fill="grey21") 
ggplot()+
  mapWorld+
  geom_point(aes(x=city[,2], y=city[,3]) ,color="red", size=sqrt(city[,1])/1,alpha=0.5)







# map projection
geo <- list(
  scope = 'world',
  projection = list(type = 'Mercator'),
  showland = TRUE,
  showcountries=TRUE,
  landcolor = toRGB("black95"),
  countrycolor = toRGB("gray80")
)

p <- plot_geo(locationmode = 'world', color = I("red")) %>%
  add_markers(
    data = city, x = ~long, y = ~lat,size = ~cnt, 
   # data=sub,x=~longitude,y=~latitude,
    hoverinfo = "text", alpha = 0.9,
  )%>%
  layout(
    title = 'blabla',
    geo = geo, showlegend = FALSE, height=800
  )
p

points(subset(sub,sub$city2=="Las Vegas")$longitude,subset(sub,sub$city2=="Las Vegas")$latitude)

