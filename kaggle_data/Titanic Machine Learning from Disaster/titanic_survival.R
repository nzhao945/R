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
# 更简洁的方式是用lapply函数
# factor_vars <- c('PassengerId','Pclass','Sex','Embarked','Title','Surname','Family','FsizeD')
# comb[factor_vars] <- lapply(comb[factor_vars], function(x) as.factor(x))
# 合并train和test,自动补全test中的Survived=NA
comb <- dplyr::bind_rows(train,test)

# 缺失值可视化，图中可以看到：cabin缺失最多(687)，其次是age(177),最后是emarked（2）
aggr(train, prop = FALSE, combined = TRUE, numbers = TRUE, sortVars = TRUE, sortCombs = TRUE)

# 增加Title列
comb$Title <- gsub('(.*, )|(\\..*)', '', comb$Name) 
# 这里的(\\..*)子表达式不理解，所以又想出如下的方法,fixed=F精确匹配字符，若=T则为正则
# comb$Title <- sapply(comb$Name,function(x)strsplit(x,split = '[,.]',fixed = FALSE)[[1]][2])

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
comb$Surname <- sapply(comb$Name,function(x) strsplit(x, split = '[,.]')[[1]][1])
# Create a family variable 
comb$Family <- paste(comb$Surname, comb$Fsize, sep='_')
# 同样对Family size进行分类
comb$FsizeD[comb$Fsize == 1] <- 'singleton'
comb$FsizeD[comb$Fsize < 5 & comb$Fsize > 1] <- 'small'
comb$FsizeD[comb$Fsize > 4] <- 'large'

### 紧接着尝试填补缺失值，然而因为Cabin缺失值太多，只能暂时放弃
# 填补Embarked、Fare
comb$Embarked[c(62, 830)] <- 'C'
comb$Fare[1044] <- median(comb[comb$Pclass == '3' & comb$Embarked == 'S', ]$Fare, na.rm = TRUE)

# 因子化部分变量
factor_vars <- c('PassengerId','Pclass','Sex','Embarked',
                 'Title','Surname','Family','FsizeD')
comb[factor_vars] <- lapply(comb[factor_vars], function(x) as.factor(x))

# Age可以用mice插补
imp <- mice(comb[, !names(comb) %in% c('PassengerId','Name','Ticket','Cabin','Family','Surname','Survived')], method = 'rf', seed = 129)
mice_result <- complete(mice_mod)
