library('dplyr')
library('ggplot2')
library('caret')
library('reshape2')
library('zoo')

titanic <- read.csv('~/titanic/titanic.csv')

titanic_group_by_class <- tbl_df(titanic) %>%
  filter(Fare > 0) %>%
  group_by(Pclass, Embarked)

class_stats <- summarise(titanic_group_by_class, mean(Fare), max(Fare), min(Fare), median(Fare))

plot1 <- ggplot(titanic,aes(x = Survived)) + geom_bar(aes(fill=Sex)) + facet_wrap(~Pclass) + theme_classic()

titanic$Age <- round(na.approx(titanic$Age),2)
titanic_to_cor <- tbl_df(titanic) %>%
  select(Survived,Pclass,Age,SibSp,Parch,Fare, Embarked, Sex)

titanic_to_predict_fare = tbl_df(titanic) %>%
  select( Sex, Fare, Embarked, Pclass, Age)

set.seed(21)
inTraining <- createDataPartition( y = titanic_to_predict_fare$Fare, p = .75, list = FALSE)

test_ttpf = titanic_to_predict_fare[-inTraining, ]
train_ttpf = titanic_to_predict_fare[inTraining, ]

ctrl <- trainControl(
  method = "repeatedcv",
  number = 2,
  repeats = 5)


fit <- train(Fare ~ .,
             data = train_ttpf,
             method = "rf",
             preProc = c("center", "scale"),
             trControl = ctrl,
             ntree = 30)


predicted <- predict(fit, test_ttpf)
actual <- test_ttpf[, "Fare"]

testR <- tbl_df(postResample(as.matrix(test_ttpf[,"Fare"]),predicted))

#table <- data.frame(model = c("treningowy","testowy"), RSME = c(fit$results$RMSE,testR$value[1]), Rsuqred = c(fit$results$Rsquared,testR$value[2]))

saveRDS(fit, "~/titanic/titanic_app/fit_fare.rds")