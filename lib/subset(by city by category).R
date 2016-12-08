

setwd("~/downloads")
business<-read.csv("yelp_academic_dataset_business.csv")
summary(business$city)
summary(business$categories)

sum(summary(business$city)[1:20])
citynames<-names(summary(business$city)[1:20])
subcity<-subset(business,business$city %in% citynames)

city2<-subcity$city

city2[city2 %in% c("North Las Vegas","Henderson") ]<-c("Las Vegas")
city2[city2 %in% c("Chandler","Gilbert","Glendale","Surprise","Tempe","Scottsdale","Mesa","Peoria","Goodyear")]<-c("Phoenix")
subcity<-cbind(subcity,city2=city2)

plot(summary(as.factor(city2)))

id<-read.csv("id.csv",header=F)
id<-as.vector(t(id))
sub<-subcity[subcity$business_id %in% id,]

write.csv(sub,"subset_bycity_bycat.csv")

