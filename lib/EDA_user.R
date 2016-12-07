devtools::install_github("mattflor/chorddiag")
library(data.table)
library(Rcpp)
library(ggplot2)
library(plotly)
library(circlize)
library(devtools)
library(chorddiag)
library(Hmisc)
library(dplyr)
library(reshape2)

user <- read.csv(file = file.choose(), header = T)

## Clean data 
user_1 = user[,-c(13,15)]
head(user_1)
summary(user_1)
user_1$year = as.numeric(substr(as.character(user_1$yelping_since),1,4))
user_1$month = as.numeric(substr(as.character(user_1$yelping_since),6,7))
today <- Sys.Date()
today.year = as.numeric(format(today,format = "%Y"))
today.month = as.numeric(format(today,format = "%m"))
user_1$review_int = round(user_1$average_stars)
user_1$length = (today.year-user_1$year)*12 + (today.month-user_1$month)

# Standarlize the compliments by account length
user_1$compliments_cool_sd = as.integer(user_1$compliments_cool/user_1$length+1)
user_1$compliments_cute_sd = as.integer(user_1$compliments_cute/user_1$length+1)
user_1$compliments_funny_sd = as.integer(user_1$compliments_funny/user_1$length+1)
user_1$compliments_hot_sd = as.integer(user_1$compliments_hot/user_1$length+1)
user_1$compliments_photos_sd = as.integer(user_1$compliments_photos/user_1$length+1)
user_1$compliments_plain_sd = as.integer(user_1$compliments_plain/user_1$length+1)
user_1$frequency = user_1$review_count/user_1$length 
summary(user_1$frequency)

# remove the data with total count less than 10 
user_2 = user_1[user_1$review_count>9,]



######################### Exploratory Visualization of the data 
##### Overview of the average data ----ggplot2
p1 = ggplot(user_1, aes(x=average_stars)) + 
  geom_histogram(binwidth = .25, aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "white", high = "dodgerblue3") + 
  labs(title="Histogram for Average Star Reviews") +
  labs(x="Average Review", y="Count")
p1
ggplotly(p1)

p2 = ggplot(user_1, aes(x=frequency)) + 
  geom_histogram(binwidth = .1, aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "white", high = "dodgerblue3") + 
  labs(title="Histogram for Average Review") +
  labs(x="Average Review", y="Count")
p2
ggplotly(p2)


user_1$countFreq <- cut2(user_1$frequency*12, g = 10)
user_1$review_cut <- cut2(user_1$average_stars, cut = seq(1,5,by = .5),onlycuts=T)
p3 = ggplot(user_1, aes(countFreq)) + 
       geom_bar(aes(fill = review_cut)) + 
       coord_flip()+scale_fill_brewer() +
       labs(title="Histograms on Average Reviews Based on Count Frequency/Month") +
       labs(x="Count Frequency", y="Count") +
       labs(fill = "Average Stars")
p3
ggplotly(p3)



user_2$countFreq <- cut2(user_2$frequency, g = 10)
user_2$review_cut <- cut2(user_2$average_stars, cut = seq(1,5,by = .5),onlycuts=T)
p4 = ggplot(user_2, aes(countFreq)) + 
  geom_bar(aes(fill = review_cut)) + 
  coord_flip()+scale_fill_brewer() +
  labs(title="Histograms on Average Reviews Based on Count Frequency/Month") +
  labs(x="Count Frequency (Prople comment more than 10 times as a whole)", y="Count") +
  labs(fill = "Average Stars")
p4
ggplotly(p4)



##### Correlation among several compliments  ---- D3 chord diagram
# convert NA to 0 
cor_matrix = user_2
cor_matrix[is.na(cor_matrix)] = 0
cor_matrix = cor(cor_matrix[,c(25:30)]) 
groupColors <- c("#000000", "#FFDD89", "#957244","#F26223")
chorddiag(na.omit(cor_matrix), groupColors = groupColors, 
          groupnamePadding = 20,tickInterval = .50)


##### correlation between average review and cool compliments ---- D3 chord diagram
user_3 = user_2[,c(24,26:31)]
user_3$n = 1

# factorize average review
user_3$review_int = as.factor(user_3$review_int)


### data to build chord diagriam function 
Review_Comp = function (variable,cut.point){
  # Group compliments cool veriable into several groups 
  user_3$Comp_Code <- cut2(as.numeric(as.character(variable)), cut.point)

  # build the chord diagram 
  Cor = user_3[,which(names(user_3) %in% c("review_int","Comp_Code","n"))]
  Cor = Cor[!is.na(Cor$Comp_Code),]

  comp_tbl <- dplyr::tbl_df(Cor)
  comp_tbl <- comp_tbl %>%
    mutate_each(funs(factor), review_int:Comp_Code)
  by_class_survival <- comp_tbl %>%
    group_by(review_int, Comp_Code) %>%
    summarize(Count = sum(as.numeric(as.character(n))))
  
  ScoreList = sort(unique(Cor$review_int))
  countlist = sort(levels(Cor$Comp_Code))
  matrix = data.frame(review_int = rep(c(1:5),each = length(countlist)),
                      Comp_Code = rep(countlist, times = 5))
  
  Comp.mat = merge(matrix, by_class_survival, 
                   by = c("review_int","Comp_Code"), all=T) 

  # Since it is so skew, it is better to do log for the count. So that we can convert the NA into 1
  Comp.mat[is.na(Comp.mat)] = 1
  Comp.mat <- matrix(Comp.mat$Count, nrow = length(countlist), ncol = 5)
  dimnames(Comp.mat) <- list(Count = levels(Cor$Comp_Code),
                             Avg_Review = c(1:5))
  out = Comp.mat
  
}
cool_mat = Review_Comp(variable = user_3$compliments_cool_sd, cut.point = c(1,2,4,10,20,40,80,200,10000))
cute_mat = Review_Comp(variable = user_3$compliments_cute_sd, cut.point = c(1,2,4,10,20,40,80,200,10000))
funny_mat = Review_Comp(variable = user_3$compliments_funny_sd, cut.point = c(1,2,4,10,20,40,80,200,10000))
hot_mat = Review_Comp(variable = user_3$compliments_hot_sd, cut.point = c(1,2,4,10,20,40,80,200,10000))
plain_mat = Review_Comp(variable = user_3$compliments_plain_sd, cut.point = c(1,2,4,10,20,40,80,200,10000))


# diagram 
chorddiag(round(log(cool_mat)), type = "bipartite", 
          groupColors = groupColors, groupnameFontsize = 10,
          categorynameFontsize = 22, categorynamePadding = 70,
          showZeroTooltips = F,categoryNames = c("Count of Cool Compliments - Interval", "Average Review"),
          tickInterval = 5)

chorddiag(round(log(cute_mat)), type = "bipartite", 
          groupColors = groupColors, groupnameFontsize = 10,
          categorynameFontsize = 22, categorynamePadding = 70,
          showZeroTooltips = F,categoryNames = c("Count of cute Compliments - Interval", "Average Review"),
          tickInterval = 5)

chorddiag(round(log(funny_mat)), type = "bipartite", 
          groupColors = groupColors, groupnameFontsize = 10,
          categorynameFontsize = 22, categorynamePadding = 70,
          showZeroTooltips = F,categoryNames = c("Count of funny Compliments - Interval", "Average Review"),
          tickInterval = 5)

chorddiag(round(log(hot_mat)), type = "bipartite", 
          groupColors = groupColors, groupnameFontsize = 10,
          categorynameFontsize = 22, categorynamePadding = 70,
          showZeroTooltips = F,categoryNames = c("Count of hot Compliments - Interval", "Average Review"),
          tickInterval = 5)

chorddiag(round(log(plain_mat)), type = "bipartite", 
          groupColors = groupColors, groupnameFontsize = 10,
          categorynameFontsize = 22, categorynamePadding = 70,
          showZeroTooltips = F,categoryNames = c("Count of plain Compliments - Interval", "Average Review"),
          tickInterval = 5)



##### Chord Diagram for Reviews and all of the comments 
head(user_3)
# remove NA 
user_NoNa = na.omit(user_3)

# keep all NA to 0 
user_with0 = user_3
user_with0 = apply(user_with0,2,as.numeric)
user_with0[is.na(user_with0)] = 0

user.dt.NoNA <- data.table(user_NoNa)
names(user.dt.NoNA)
sum_table.NoNa = user.dt.NoNA[,list(Cool=sum(compliments_cool_sd), 
                                Cute=sum(compliments_cute_sd),
                                Funny = sum(compliments_funny_sd),
                                Hot = sum(compliments_hot_sd),
                                Plain = sum(compliments_plain_sd)), by='review_int']
sum_table.NoNa = sum_table.NoNa[order(sum_table.NoNa$review_int),][,-1]
rownames(sum_table.NoNa) = c(1:5)
sum_NoNa_matrix <- as.matrix(sum_table.NoNa)
rownames(sum_NoNa_matrix) = c(1:5)
# chorddiagram
chorddiag(round(log(sum_NoNa_matrix)), type = "bipartite", 
          groupColors = groupColors, groupnameFontsize = 15,
          categorynameFontsize = 22, categorynamePadding = 80,
          showZeroTooltips = F,categoryNames = c("Average Review", "Type of Compliments - NoNA"),
          tickInterval = 5)



user.dt.with0 <- data.table(user_with0)
names(user.dt.with0)
sum_table.with0 = user.dt.with0[,list(Cool=sum(compliments_cool_sd), 
                                 Cute=sum(compliments_cute_sd),
                                 Funny = sum(compliments_funny_sd),
                                 Hot = sum(compliments_hot_sd),
                                 Plain = sum(compliments_plain_sd)), by='review_int']
sum_table.with0 = sum_table.with0[order(sum_table.with0$review_int),][,-1]
rownames(sum_table.with0) = c(1:6)
sum_with0_matrix <- as.matrix(sum_table.with0)
rownames(sum_with0_matrix) = c(1:6)
chorddiag(round(log(sum_with0_matrix)), type = "bipartite", 
          groupColors = groupColors, groupnameFontsize = 15,
          categorynameFontsize = 22, categorynamePadding = 80,
          showZeroTooltips = F,categoryNames = c("Average Review", "Type of Compliments - with 0"),
          tickInterval = 5)



#### Coorrelation among each vote and average reviews 
user_vote = data.frame(Averg_star = round(user_1$average_stars),
                       cool_sd = as.integer(user_1$votes_cool/user_1$length+1),
                       funny_sd = as.integer(user_1$votes_funny/user_1$length+1),
                       useful_sd = as.integer(user_1$votes_useful/user_1$length+1))

user_vote.table <- data.table(user_vote)
names(user_vote.table)
sum_table = user_vote.table[,list(Cool=sum(cool_sd),
                               Funny = sum(funny_sd),
                               useful = sum(useful_sd)), by='Averg_star']
sum_table = sum_table[order(sum_table$Averg_star),][,-1]
rownames(sum_table) = c(0:5)
sum_matrix_reviefan<- as.matrix(sum_table)
rownames(sum_matrix_reviefan) = c(0:5)
chorddiag(round(log(sum_matrix_reviefan)), type = "bipartite", 
          groupColors = groupColors, groupnameFontsize = 15,
          categorynameFontsize = 22, categorynamePadding = 80,
          showZeroTooltips = F,categoryNames = c("Average Review", "Type of Votes"),
          tickInterval = 5)










##### Visualization between review count and fans 
Fans = cut2(user_1$fans,cut = c(0,1,2,5,10,50,300,800))
Average_review = cut2(user_1$frequency*12, cut = c(0,0.5,1,2,3,5,10,50,100,500))
review_fans = data.frame(Average_review,
                         Fans,
                         Count = 1)
re_fans_tbl <- dplyr::tbl_df(review_fans)
re_fans_tbl <- re_fans_tbl %>%
  mutate_each(funs(factor), Average_review:Fans)
by_class <- re_fans_tbl %>%
  group_by(Average_review, Fans) %>%
  summarize(Count = sum(Count))
Review_List = sort(levels(review_fans$Average_review))
Fans_list = sort(levels(review_fans$Fans))
matrix = data.frame(Average_review = rep(Review_List, each = length(Fans_list)),
                    Fans = rep(Fans_list, times = length(Review_List)))
rev_fans.mat = merge(matrix, by_class, 
                 by = c("Average_review","Fans"), all=T) 
# Since it is so skew, it is better to do log for the count. So that we can convert the NA into 1
rev_fans.mat[is.na(rev_fans.mat)] = 1
rev_fans.mat$logcount = log(rev_fans.mat$Count)
p5 = ggplot(data = rev_fans.mat, aes(Fans, Average_review, fill = logcount))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "yellow", high = "dodgerblue3", mid = "darkseagreen1", 
                       space = "Lab", 
                       name="Log Count of users") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  labs(title="Log Count of Users Each Set of Groups- Review Frequency and Number of Fans") +
  labs(x="Number of Fans", y="Review Frequency/Year") +
  labs(fill = "Average Stars") +
  theme(axis.title.x = element_text(vjust=1),
        axis.text.x  = element_text(angle=30, size=10))
p5
ggplotly(p5)





