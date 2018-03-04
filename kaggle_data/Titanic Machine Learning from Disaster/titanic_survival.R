# 本项目需要加载的包
library(data.table)
library(dplyr)
library(mice)
library(rpart) #决策树包，此处用于预测Age缺失值
library(VIM)
library(ggplot2)
library(randomForest)
library(party) # cforest

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

#############################挖掘有价值的变量###################################################
# 增加Title列，(\\..*)中的"\\'是R特有的，参考read.csv中的文件路径，所以子表达式的含义是字符‘.’+任意个字符
comb$Title <- gsub('(.*, )|(\\..*)', '', comb$Name) 
# 又想出如下的方法,fixed=T精确匹配字符，若=F则为正则
# comb$Title <- sapply(comb$Name,function(x)strsplit(x,split = '[,. ]',fixed = FALSE)[[1]][3])

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

# 还剩下ticket变量未进行特征工程
ticket.count <- aggregate(comb$Ticket, by=list(comb$Ticket),function(x) sum(!is.na(x)))
# 接下来将所有乘客按照Ticket分为两组，一组是使用单独票号，另一组是与他人共享票号
comb$TicketCount <- apply(comb,1,function(x) ticket.count[which(ticket.count[,1] == x['Ticket']),2]) %>% sapply(function(x) ifelse(x>1,'Share','Unique')) %>% factor()


################################缺失值填补，然而因为Cabin缺失值太多，只能暂时放弃#########################################
# 填补Embarked、Fare
comb$Embarked[c(62, 830)] <- 'C'
comb$Fare[1044] <- median(comb[comb$Pclass == '3' & comb$Embarked == 'S', ]$Fare, na.rm = TRUE)

# 因子化部分变量
factor_vars <- c('PassengerId','Pclass','Sex','Embarked',
                 'Title','Surname','Family','FsizeD')
comb[factor_vars] <- lapply(comb[factor_vars], function(x) as.factor(x))

# comb$Age可以用mice插补
# imp <- mice(comb[, !names(comb) %in% c('PassengerId','Name','Ticket','Cabin','Family','Surname','Survived')], method = 'rf', seed = 129)
# mice_result <- complete(mice_mod)
# comb$Age <- mice_result$Age
# rf_modelV2基于rpart进行插补Age
Age_rpart <- rpart(Age ~ Pclass + Sex + SibSp + Parch + Fare + Embarked + Title + Fsize, data=comb[!is.na(comb$Age),], method='anova')
comb$Age[is.na(comb$Age)] <- predict(Age_rpart,comb[!is.na(comb$Age),])

### create a couple of new age-dependent variables: Child and Mother. 
comb$Child[comb$Age < 18] <- 'Child'
comb$Child[comb$Age >= 18] <- 'Adult'
table(comb$Child, comb$Survived)
comb$Mother <- 'Not Mother'
comb$Mother[comb$Sex == 'female' & comb$Parch > 0 & comb$Age > 18 & comb$Title != 'Miss'] <- 'Mother'
table(comb$Mother, comb$Survived)
# 因子化
comb$Child  <- factor(comb$Child)
comb$Mother <- factor(comb$Mother)

################开始randomforest预测前，先将所有基于comb进行的数据填补、类型转换等返回给train和test###########
train <- comb[1:891,]
test <- comb[892:1309,]
rf_model <- randomForest(Survived ~ Pclass + Sex + Age + SibSp + Parch +Fare + Embarked +
                        Title + FsizeD + Child + Mother, data = train, importance = T)
plot(rf_model, ylim=c(0,0.36))
legend('topright', colnames(rf_model$err.rate), col=1:3, fill=1:3)
# Get variable importance
varImportance <- importance(rf_model) %>% data.frame(Variables = row.names(.), Importance = round(.[,'MeanDecreaseGini'],2))
# Create a rank variable based on importance
rankImportance <- varImportance %>%
  mutate(Rank = paste0('#',dense_rank(desc(Importance))))
# Use ggplot2 to visualize the relative importance of variables
ggplot(rankImportance, aes(x = reorder(Variables, Importance), y = Importance, fill = Importance)) +
  geom_bar(stat='identity') + 
  geom_text(aes(x = Variables, y = 0.5,label = Rank),hjust=0, vjust=0.55, size = 4,colour = 'red') +
  labs(x = 'Variables') +
  coord_flip() +
  theme_classic()
# 最终结果预测，并导出
solution <- predict(rf_model,test) %>% data.frame(PassengerID = test$PassengerId, Survived = .)
fwrite(solution, row.names = FALSE,
      file = 'G:/R/kaggle_data/Titanic Machine Learning from Disaster/submission_titanic.csv')

########################party::cforest,0.80861，rank703,TOP 8%#############################
set.seed(355)
rf_modelV2 <- cforest(Survived ~ Pclass + Sex + Age +Fare + Embarked +Title + FsizeD + TicketCount,data = train, controls = cforest_unbiased(ntree = 1000, mtry = 3))
solution_V2 <- predict(rf_modelV2,test, OOB = T, type = 'response') %>% data.frame(PassengerID = test$PassengerId, Survived = .)
fwrite(solution_V2, row.names = FALSE, file = 'G:/R/kaggle_data/Titanic Machine Learning from Disaster/submission_titanic.csv')
