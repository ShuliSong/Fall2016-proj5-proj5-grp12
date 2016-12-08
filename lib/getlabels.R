getlables<-function(inputid){
  labels<-strsplit(as.character(sub$categories[sub$business_id %in% inputid]), ",")
  a<-unlist(labels)
  a2<-a[a!="Restaurants" & a!="Food"]
  a2[a2 =="American (Traditional)"]<-"American"
  m<-sort(summary(as.factor(a2)),decreasing=T)
  return(m)
}

