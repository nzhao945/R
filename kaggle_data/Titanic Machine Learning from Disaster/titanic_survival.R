# 本项目需要加载的包
library(data.table)
library(dplyr)
library(mice)
library(VIM)
library(ggplot2)
library(randomForest)

# 导入训练集和测试集,发现部分空值不能正确读取为NA，故加入参数na.strings = c("NA","")
train <- fread(header = T, stringsAsFactors = F,na.strings = c("NA","","N/A","null"),
                file = "G:/R/kaggle_data/Titanic Machine Learning from Disaster/train.csv")
test <- fread(header = T, stringsAsFactors = F,na.strings = c("NA","","N/A","null"),
                file = "G:/R/kaggle_data/Titanic Machine Learning from Disaster/test.csv")

# 了解数据集
str(train)
train <- train %>% mutate(Survived = factor(Survived),Pclass = factor(Pclass),
                          Embarked = factor(Embarked),Sex = factor(Sex))
str(test)
test <- test %>% mutate(Pclass = factor(Pclass),
                        Embarked = factor(Embarked),Sex = factor(Sex))
# 合并train和test,自动补全test中的Survived=NA
comb <- dplyr::bind_rows(train,test)

# 增加Title列
comb$Title <- gsub('(.*, )|(\\..*)', '', comb$Name) 
# 这里的(\\..*)子表达式不理解，所以又想出如下的方法
# comb$Title <- sapply(comb$Name,function(x)strsplit(x,split = '[,.]')[[1]][2])

# 缺失值可视化，图中可以看到：cabin缺失最多(687)，其次是age(177),最后是emarked（2）
aggr(train, prop = FALSE, combined = TRUE, numbers = TRUE, sortVars = TRUE, sortCombs = TRUE)

###下面开始进行初步探索数据集###
table(comb$Sex,comb$Title)
rare_title <- c("Capt","Col","Don","Dona","Dr","Jonkheer","Lady","Major","Rev","Sir","the Countess")
comb$Title[comb$Title == 'Mlle'] <- 'Miss' 
comb$Title[comb$Title == 'Ms'] <- 'Miss'
comb$Title[comb$Title == 'Mme'] <- 'Mrs' 
comb$Title[comb$Title %in% rare_title] <- 'Rare Title'
comb$Title <- factor(comb$Title)

### sibsp和parch的特征工程
comb$Fsize <- comb$SibSp + comb$Parch + 1
# Create a family variable 
comb$Family <- paste(comb$Surname, comb$Fsize, sep='_')
# 同样对Family size进行分类
comb$FsizeD[comb$Fsize == 1] <- 'singleton'
comb$FsizeD[comb$Fsize < 5 & comb$Fsize > 1] <- 'small'
comb$FsizeD[comb$Fsize > 4] <- 'large'

### 紧接着就是填补缺失值Cabin
