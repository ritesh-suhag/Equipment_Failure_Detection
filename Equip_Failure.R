#install.packages("corrplot")
library("corrplot")
library("caret")
library("kernlab")
library("e1071")
library("outliers")
library("dplyr")
library("tidyverse")
library("tidyr")

set.seed(999)
clean_data <- data.frame(Try = c(1:length(equip_failures_training_set$id)))

#Changing into numeric values
for (i in c(1:length(equip_failures_training_set))) {
  clean_data[,i] <- as.numeric(unlist(equip_failures_training_set[,i]))
}

#Making the column headers same
colnames(clean_data) <- colnames(equip_failures_training_set)

#Forming correlation heatmap
cor_clean_data <- cor(clean_data, use = "complete.obs")

#Selecting the correlation with only the target variable and plotting the graph.
#corrplot(as.matrix(head(cor_clean_data["target",order(cor_clean_data["target",],decreasing = T)], 10)))
#Forming a data frame of the correlations of target column with the rest of the columns.
cor_table <- as.matrix(cor_clean_data["target",])
cor_table <- as.data.frame(cor_table)
cor_table$row_id <- c(1:length(cor_table$V1))
cor_table <- cor_table[order(cor_table$V1, decreasing = T), ]
cor_table <- cor_table[complete.cases(cor_table),]
cor_table_1 <- cor_table[cor_table$V1 > 0.05,]
cor_table_2 <- cor_table[cor_table$V1 < -0.05,]
cor_table_3 <- rbind(cor_table_1,cor_table_2)

#Selecting only the required columns from the clean data.
clean_data <- clean_data[,order(cor_table_3$row_id)]

#Breaking the tables according to the fault location to get better
target_0 <- clean_data[clean_data$target==0,]
target_1 <- clean_data[clean_data$target==1,]

#Replacing all NA values in columns with 0/mean/median according to repective target values.
for (i in c(3:length(target_0))) {
  if (colnames(target_0)[i] == "sensor2_measure"){
    next()
  }
  target_0[,i][is.na(target_0[,i])] <- median(target_0[,i],na.rm = T)
}

for (i in c(3:length(target_1))) {
  if (colnames(target_0)[i] == "sensor2_measure"){
    next()
  }
  target_1[,i][is.na(target_1[,i])] <- median(target_1[,i],na.rm = T)
}

#Combing the broken tables back together.
clean_data <- target_0
clean_data <- rbind(target_0,target_1)

#Making target as the first column.
clean_data <- clean_data %>% select(target, everything())

#Taking out Id column because we don't require it in prediction model
clean_data$id <- NULL

#We remove all the NULL values in the sensor2_measure columns.
clean_data <- clean_data[complete.cases(clean_data),]
clean_data$sensor2_measure <- NULL

#Finding out columns with near 0 variance to take out of prediction model, as they would have least
#affect on the prediction model.
nearZeroVarianceList <- nearZeroVar(clean_data)
nearZeroVarianceList <- nearZeroVarianceList[-1]
clean_data <- clean_data[,-nearZeroVarianceList]

#We split the data into test and train dataset to first evaluate the accuracy of 
#prediction model
#90% is used to train the predictive model, and 10% is used for testing processes.
trainset <- createDataPartition(y = clean_data$target, p=0.9 , list = F)
training <- clean_data[trainset,]
testing <- clean_data[-trainset,]

#Making the target column as a factor in both training and test dataset as
#required by the SVM.
training[["target"]] <- factor(training[["target"]])
testing[["target"]] <- factor(testing[["target"]])
trainControlList <- trainControl(method = "repeatedcv", number = 4, repeats = 2)
#Training the SVM linear model.
svm_Linear_Grid <- train(target ~., data = training, method = "svmLinear",
                         trControl=trainControlList,
                         preProcess = c("center", "scale"),
                         tuneLength = 10)
#Predicting the test dataset, using the SVM model trained.
test_pred <- predict(svm_Linear_Grid, newdata = testing)
#Trying to find out rough accuracy of the model across the test dataset.
table(test_pred,testing$target)
rough_accuracy <- confusionMatrix(test_pred, testing$target)
rough_accuracy$overall["Accuracy"]
#Storing the dependent variables to show to the client.
dependent_var_12 <- caret::varImp(svm_Linear_Grid)
