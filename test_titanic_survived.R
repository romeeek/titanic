library('dplyr')
library('ggplot2')
library('caret')
library('corrplot')
library('reshape2')
library('zoo')

titanic <- read.csv("~/titanic/titanic.csv")

titanic$Survived <- as.character(titanic$Survived)

titanic_group_by_class <- tbl_df(titanic) %>%
  filter(Fare > 0) %>%
  group_by(Pclass, Embarked)

class_stats <- summarise(titanic_group_by_class, mean(Fare), max(Fare), min(Fare), median(Fare))

plot1 <- ggplot(titanic,aes(x = Survived)) + geom_bar(aes(fill=Sex)) + facet_wrap(~Pclass) + theme_classic()

titanic$Age <- round(na.approx(titanic$Age),2)
titanic_to_cor <- tbl_df(titanic) %>%
  select(Survived,Pclass,Age,SibSp,Parch,Fare, Embarked, Sex)

titanic_to_predict_survived = tbl_df(titanic) %>%
  select( Sex, Fare, Embarked, Pclass, Age, Survived)

set.seed(21)
inTraining <- createDataPartition( y = titanic_to_predict_survived$Survived, p = .75, list = FALSE)

test_ttpf = titanic_to_predict_survived[-inTraining, ]
train_ttpf = titanic_to_predict_survived[inTraining, ]

ctrl <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3)

mtry <- sqrt(ncol(test_ttpf))
tunegrid <- expand.grid(.mtry=c(1:15), .ntree=c(1000, 1500, 2000, 2500))

customRF <- list(type = "Classification", library = "randomForest", loop = NULL)
customRF$parameters <- data.frame(parameter = c("mtry", "ntree"), class = rep("numeric", 2), label = c("mtry", "ntree"))
customRF$grid <- function(x, y, len = NULL, search = "grid") {}
customRF$fit <- function(x, y, wts, param, lev, last, weights, classProbs, ...) {
  randomForest(x, y, mtry = param$mtry, ntree=param$ntree, ...)
}
customRF$predict <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata)
customRF$prob <- function(modelFit, newdata, preProc = NULL, submodels = NULL)
  predict(modelFit, newdata, type = "prob")
customRF$sort <- function(x) x[order(x[,1]),]
customRF$levels <- function(x) x$classes

fit <- train(Survived ~ .,
             data = train_ttpf,
             method = customRF,
             metric = metric,
             tuneGrid = tunegrid,
             trControl = ctrl,
             ntree = 30)

predicted <- predict(fit, test_ttpf)
actual <- test_ttpf[, "Survived"]

testR <- tbl_df(postResample(as.matrix(test_ttpf[,"Survived"]),predicted))

#table <- data.frame(model = c("treningowy","testowy"), RSME = c(fit$results$RMSE,testR$value[1]), Rsuqred = c(fit$results$Rsquared,testR$value[2]))

saveRDS(fit, "~/titanic/titanic_app/fit_survived.rds")