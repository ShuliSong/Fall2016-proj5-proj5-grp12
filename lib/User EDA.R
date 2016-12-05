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

user <- read.csv(file.choose(), header = T)

## Clean data 
user_1 = user[,-c(15,18,19)]
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

# remove the data with total count less than 10 
user_2 = user_1[user_1$review_count>9,]



######################### Exploratory Visualization of the data 
##### Overview of the average data ----ggplot2
p1 = ggplot(user_1, aes(x=review_int)) + 
  geom_histogram(binwidth = 1, aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "white", high = "dodgerblue3") + 
  labs(title="Histogram for Average Review") +
  labs(x="Average Review", y="Count")
p1
ggplotly(p1)



##### Correlation among several compliments  ---- D3 chord diagram
# convert NA to 0 
cor_matrix = user_2
cor_matrix[is.na(cor_matrix)] = 0
cor_matrix = cor(cor_matrix[,c(25:30)]) 
groupColors <- c("#000000", "#FFDD89", "#957244","#F26223")
chorddiag(na.omit(cor_matrix), groupColors = groupColors, 
          groupnamePadding = 20,tickInterval = .50)


##### correlation between average review and cool compliments ---- D3 chord diagram
user_3 = user_2[,c(23,25:30)]
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












################################ Reference ######################
Sys.setenv("plotly_username"="ruifancu")
Sys.setenv("plotly_api_key"="3TGzua7is3i0aDFQDcAp")

f <- list(
  family = "Courier New, monospace",
  size = 18,
  color = "#7f7f7f"
)
x <- list(
  title = "Review Stars",
  titlefont = f
)
y <- list(
  title = "Frequency",
  titlefont = f
)

# Axes font 
a <- list(
  autotick = FALSE,
  ticks = "outside",
  tick0 = 0,
  dtick = 0.25,
  ticklen = 5,
  tickwidth = 2,
  tickcolor = toRGB("blue")
)
s <- seq(1, 4, by = 0.25)
p <- plot_ly(x = ~s, y = ~s) %>%
  layout(xaxis = a, yaxis = a)
p


p1 = plot_ly(x = ~user_1$average_stars, color = user_1$review_int, carattype = "bar")%>%
  layout(xaxis = x, yaxis = y)

p1 = ggplot(user_1, aes(x=review_int)) + 
  geom_histogram(binwidth = 1, aes(fill=..count..)) +
  scale_fill_gradient("Count", low = "white", high = "dodgerblue3") + 
  labs(title="Histogram for Average Review") +
  labs(x="Average Review", y="Count")
p1
ggplotly(p1)


code = function(Variable,trun1,trun2,trun3,trun4,trun5,trun6,trun7,trun8,trun9,trun10,
                trun11,trun12,trun13,trun14,trun15){
  for (i in 1:length(Variable)){
    group = vector()
    if (is.na(Variable[i])) {
      group[i] = 0
    } else if (Variable[i] == trun1){
      group[i] <- 1
    } else if (Variable[i] == trun2){
      group[i] <- 2
    } else if (Variable[i] == trun3){
      group[i] <- 3
    } else if (Variable[i] == trun4){
      group[i] <- 4
    } else if (Variable[i] < trun5){
      group[i] <- trun5
    } else if (Variable[i] < trun6){
      group[i] <- trun6
    } else if (Variable[i] < trun7){
      group[i] <- trun7
    } else if (Variable[i] < trun8){
      group[i] <- trun8
    } else if (Variable[i] < trun9){
      group[i] <- trun9
    } else if (Variable[i] < trun10){
      group[i] <- trun10
    } else if (Variable[i] < trun11){
      group[i] <- trun11
    } else if (Variable[i] < trun12){
      group[i] <- trun12
    } else if (Variable[i] < trun13){
      group[i] <- trun13
    } else if (Variable[i] < trun13){
      group[i] <- trun13
    } else if (Variable[i] < trun14){
      group[i] <- trun14
    } else if (Variable[i] < trun15){
      group[i] <- trun15
    } else {
      group[i] = 10000
    }
  }
  out = group
}


user_1$compliments_cool_code = code(user_1$compliments_cool,1,2,3,4,6,9,13,20,31,75,150,300,600,1000,3000)
user_1$compliments_cool_code <- cut2(user_1$compliments_cool, c(1,2,3,4,5,7,10,13,20,32,75,150,300,600,1000,3000,10000),levels.mean = T)



chart_link1 = plotly_POST(p1, filename="average starts")
chart_link1
p2 <- plot_ly(x = ~user_food$review_count, type = "histogram")
chart_link2 = plotly_POST(p2, filename="review count")
chart_link2
summary(user_food$review_count)

reg1 <- lm(user_food$fans~user_food$review_count)
summary(reg1)

summary(user_food$yelping_since)


yelping_sincedate <- paste(yelping_since, "-01")
yelping_time <- as.Date(yelping_sincedate, format = "%Y-%m -%d")
NumberOfDays = as.numeric(Sys.Date() - yelping_time)
NumberOfMonths <- NumberOfDays/30
summary(NumberOfMonths)

review_countperday <- review_count/NumberOfDays
review_countpermonth <- review_count/NumberOfMonths
summary(review_countpermonth)
p3 <- plot_ly(x = ~review_countpermonth, type = "histogram")
chart_link3 = plotly_POST(p3, filename="review count per month")
chart_link3
hist(review_countpermonth)
