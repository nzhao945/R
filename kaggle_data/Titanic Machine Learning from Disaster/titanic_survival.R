# 本项目需要加载的包
library(data.table)
library(mice)
library(ggplot2)
library(randomForest)

#导入训练集和测试集
titanic_train <- fread(header = T,stringsAsFactors = F,
                file = "G:/R/kaggle_data/Titanic Machine Learning from Disaster/train.csv")
titanic_test <- fread(header = T,stringsAsFactors = F,
                file = "G:/R/kaggle_data/Titanic Machine Learning from Disaster/test.csv")