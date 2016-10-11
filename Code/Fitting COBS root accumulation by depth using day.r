## load in the library
library(nlme)

## Read in the data
rut <- read.csv('Data/rootmeansv2.csv', header=TRUE)

rut$trt<-as.character(rut$trt)
rut$trt[rut$plot %in% c("11", "33", "26", "44")]<-"SC"
rut$trt[rut$plot %in% c('16', "34", "22", "45")]<-"CS"
rut$trt[rut$plot %in% c("12", "35", "21", "43")]<-"CC"
rut$trt[rut$plot %in% c('14', "36", "25", "42")]<-"CCW"
rut$trt[rut$plot %in% c("13", "31", "24", "46")]<-"P"
rut$trt[rut$plot %in% c('15', "32", "23", "41")]<-"PF"

rut$day[rut$year == 2008] <- 153
rut$day[rut$year == 2009] <- 520
rut$day[rut$year == 2010] <- 882
rut$day[rut$year == 2011] <- 1248
rut$day[rut$year == 2012] <- 1619
rut$day[rut$year == 2013] <- 1978

rut$plot.f<-as.factor(rut$plot)

c. <- function(x) scale(x,center=TRUE,scale=FALSE)

rutG <- groupedData(mass ~ day| plot.f, data = rut)

## 5 cm ##
rutG.5 <- subset(rutG, depth == 5)

fitL.5 <- nlsList(mass ~ SSlogis(day, Asym, xmid, scal), data=rutG.5)

rut.5.nlme <- nlme(fitL.5, random=list(Asym ~1))

rut5.lme<-lme(mass ~ c.(day), random=~c.(day)|plot, data=rutG.5)#*

anova(rut.5.nlme, fit5.lme)

## 5 cm without prairies

rutG.5.np<-rutG.5[!rutG.5$trt %in% c("P", "PF"),]

fitL.5.np <- nlsList(mass ~ SSlogis(day, Asym, xmid, scal), data=rutG.5.np)
rut.5.nlme.np <- nlme(fitL.5.np, random=list(Asym + xmid ~1))#*

rut5.lme.np<-lme(mass ~ c.(day), random=~c.(day)|plot, method='ML', data=rutG.5.np)#Works, but not great

anova(rut.5.nlme.np, rut5.lme.np)

plot(augPred(rut.5.nlme.np, level=0:1), main="nlme 0-5 cm, No Prairies")
plot(augPred(rut5.lme.np, level=0:1), main="lme 0-5 cm, No Prairies")

### 5 cm only prairies

rutG.5.p<-rutG.5[rutG.5$trt %in% c("P", "PF"),]

fitL.5.p <- nlsList(mass ~ SSlogis(day, Asym, xmid, scal), data=rutG.5.p)
rut.5.nlme.p <- nlme(fitL.5.p, random=list(Asym + xmid + scal ~1))#*

plot(augPred(rut.5.nlme.p, level=0:1), main="nlme 0-5 cm, Only prairies")

## 15 cm ##
rutG.15 <- subset(rutG, depth == 15)

rut15.lme<-lme(mass ~ c.(day), random=~c.(day)|plot, method='ML', data=rutG.15)#*

fitL.15 <- nlsList(mass ~ SSlogis(day, Asym, xmid, scal), data=rutG.15)#*
rut.15.nlme <- nlme(fitL.15, random=list(Asym + xmid + scal ~1))#*

anova(rut.15.nlme, rut15.lme)
plot(augPred(rut15.lme, level=0:1), main="lme 5-15 cm")
plot(augPred(rut.15.nlme, level=0:1), main="nlme 5-15 cm")

## 30 cm ##
rutG.30 <- subset(rutG, depth == 30)

rut30.lme<-lme(mass ~ c.(day), random=~c.(day)|plot, method='ML', data=rutG.30)#*

fitL.30 <- nlsList(mass ~ SSlogis(day, Asym, xmid, scal), data=rutG.30)#*
rut.30.nlme <- nlme(fitL.30, random=list(xmid ~1), method = 'ML')#*


anova(rut.30.nlme, rut30.lme)
plot(augPred(rut30.lme, level=0:1), main="lme 15-30 cm")
plot(augPred(rut.30.nlme, level=0:1), main="nlme 15-30 cm")

## 60 ##
rutG.60 <- subset(rutG, depth == 60)

fitL.60 <- nlsList(mass ~ SSlogis(day, Asym, xmid, scal), data=rutG.60)#*
rut.60.nlme <- nlme(fitL.60, random=list(xmid  ~1), method = 'REML')#*

rut60.lme<-lme(mass ~ c.(day), random= pdDiag(~c.(day)|plot), data=rutG.60)#Works, but not great

anova(rut.60.nlme, rut60.lme)
plot(augPred(rut60.lme, level=0:1), main="lme 30-60 cm")
plot(augPred(rut.60.nlme, level=0:1), main="nlme 30-60 cm")

## 100 ##
rutG.100 <- subset(rutG, depth == 100)

fitL.100 <- nlsList(mass ~ SSlogis(day, Asym, xmid, scal), data=rutG.100)#*
rut.100.nlme <- nlme(fitL.100, random=list(xmid ~1), method='REML')#*

rut100.lme<-lme(mass ~ c.(day), random=~c.(day)|plot, method='REML', data=rutG.100)#*

anova(rut.100.nlme, rut100.lme)
plot(augPred(rut100.lme, level=0:1), main="lme 60-100 cm")
plot(augPred(rut.100.nlme, level=0:1), main="nlme 60-100 cm")

library(ggplot2)
library(dplyr)
ggplot(augPred(rut.100.nlme), aes(x=day, y=mass, group=.type, color=.type))+
  geom_point()+
  facet_wrap(~.groups)


##All comparisons
pdf("Nonlinear vs linear fits for root accumulation.pdf")
plot(augPred(rut.5.nlme.p, level=0:1), main="nlme 0-5 cm, Only prairies")
plot(augPred(rut.5.nlme.np, level=0:1), main="nlme 0-5 cm, No Prairies")
plot(augPred(rut5.lme.np, level=0:1), main="lme 0-5 cm, No Prairies")
plot(augPred(rut.15.nlme, level=0:1), main="nlme 5-15 cm")
plot(augPred(rut15.lme, level=0:1), main="lme 5-15 cm")
plot(augPred(rut.30.nlme, level=0:1), main="nlme 15-30 cm")
plot(augPred(rut30.lme, level=0:1), main="lme 15-30 cm")
plot(augPred(rut.60.nlme, level=0:1), main="nlme 30-60 cm")
plot(augPred(rut60.lme, level=0:1), main="lme 30-60 cm")
plot(augPred(rut.100.nlme, level=0:1), main="nlme 60-100 cm")
plot(augPred(rut100.lme, level=0:1), main="lme 60-100 cm")
dev.off()

param5p<-coef(rut.5.nlme.p)
param5p$plot<-rownames(param5p)
param5p$trt[param5p$plot %in% c("11", "33", "26", "44")]<-"SC"
param5p$trt[param5p$plot %in% c('16', "34", "22", "45")]<-"CS"
param5p$trt[param5p$plot %in% c("12", "35", "21", "43")]<-"CC"
param5p$trt[param5p$plot %in% c('14', "36", "25", "42")]<-"CCW"
param5p$trt[param5p$plot %in% c("13", "31", "24", "46")]<-"P"
param5p$trt[param5p$plot %in% c('15', "32", "23", "41")]<-"PF"
param5p$depth<-5

param5np<-coef(rut.5.nlme.np)
param5np$plot<-rownames(param5np)
param5np$trt[param5np$plot %in% c("11", "33", "26", "44")]<-"SC"
param5np$trt[param5np$plot %in% c('16', "34", "22", "45")]<-"CS"
param5np$trt[param5np$plot %in% c("12", "35", "21", "43")]<-"CC"
param5np$trt[param5np$plot %in% c('14', "36", "25", "42")]<-"CCW"
param5np$trt[param5np$plot %in% c("13", "31", "24", "46")]<-"P"
param5np$trt[param5np$plot %in% c('15', "32", "23", "41")]<-"PF"
param5np$depth<-5

param15<-coef(rut.15.nlme)
param15$plot<-rownames(param15)
param15$trt[param15$plot %in% c("11", "33", "26", "44")]<-"SC"
param15$trt[param15$plot %in% c('16', "34", "22", "45")]<-"CS"
param15$trt[param15$plot %in% c("12", "35", "21", "43")]<-"CC"
param15$trt[param15$plot %in% c('14', "36", "25", "42")]<-"CCW"
param15$trt[param15$plot %in% c("13", "31", "24", "46")]<-"P"
param15$trt[param15$plot %in% c('15', "32", "23", "41")]<-"PF"
param15$depth<-15

param30<-coef(rut.30.nlme)
param30$plot<-rownames(param30)
param30$trt[param30$plot %in% c("11", "33", "26", "44")]<-"SC"
param30$trt[param30$plot %in% c('16', "34", "22", "45")]<-"CS"
param30$trt[param30$plot %in% c("12", "35", "21", "43")]<-"CC"
param30$trt[param30$plot %in% c('14', "36", "25", "42")]<-"CCW"
param30$trt[param30$plot %in% c("13", "31", "24", "46")]<-"P"
param30$trt[param30$plot %in% c('15', "32", "23", "41")]<-"PF"
param30$depth<-30

param60<-coef(rut.60.nlme)
param60$plot<-rownames(param60)
param60$trt[param60$plot %in% c("11", "33", "26", "44")]<-"SC"
param60$trt[param60$plot %in% c('16', "34", "22", "45")]<-"CS"
param60$trt[param60$plot %in% c("12", "35", "21", "43")]<-"CC"
param60$trt[param60$plot %in% c('14', "36", "25", "42")]<-"CCW"
param60$trt[param60$plot %in% c("13", "31", "24", "46")]<-"P"
param60$trt[param60$plot %in% c('15', "32", "23", "41")]<-"PF"
param60$depth<-60

param100<-coef(rut.100.nlme)
param100$plot<-rownames(param100)
param100$trt[param100$plot %in% c("11", "33", "26", "44")]<-"SC"
param100$trt[param100$plot %in% c('16', "34", "22", "45")]<-"CS"
param100$trt[param100$plot %in% c("12", "35", "21", "43")]<-"CC"
param100$trt[param100$plot %in% c('14', "36", "25", "42")]<-"CCW"
param100$trt[param100$plot %in% c("13", "31", "24", "46")]<-"P"
param100$trt[param100$plot %in% c('15', "32", "23", "41")]<-"PF"
param100$depth<-100

allparam<-rbind(param5p, param5np, param15, param30, param60, param100)

write.csv(allparam, file="Logistic parameters of root accumulationv2.csv", row.names=FALSE)


