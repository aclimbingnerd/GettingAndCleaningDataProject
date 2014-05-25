library(reshape2)

# Read in the Data Files 
xTest <- read.table("UCI_HAR_Dataset/test/X_test.txt")
yTest <- read.table("UCI_HAR_Dataset/test/Y_test.txt")
xTrain <- read.table("UCI_HAR_Dataset/train/x_train.txt")
yTrain <- read.table("UCI_HAR_Dataset/train/Y_train.txt")
sTest <- read.table("UCI_HAR_Dataset/test/subject_test.txt")
sTrain <- read.table("UCI_HAR_Dataset/train/subject_train.txt")

# Note sure if we need to keep the test and train lable info in the 
# data set 
#xTrain$type <- "train"
#xTest$type <- "test"

# Merge Test and Traing
xMerged <- rbind(xTest,xTrain)
yMerged <- rbind(yTest,yTrain)
sMerged <- rbind(sTest,sTrain)

#Lable Data 
dataNames <- read.table("UCI_HAR_Dataset/features.txt")
names(xMerged) <- dataNames$V2
names(yMerged) <- "activity_labels"
names(sMerged) <- "subjects"

#Merge x and y data sets
merged <- cbind(sMerged,yMerged,xMerged)

#Clean up unused variables 
rm(xTest, xTrain, yTest, yTrain, xMerged, yMerged, dataNames, sMerged, sTest, sTrain)

# Find the columns of for the mean and std measurments
# 1:2 are the column index of the y values and subjects 
stdAndMeanIndex <- c(1:2, grep("mean|std", colnames(merged), ignore.case=TRUE))
stdAndMeanDF <- merged[,stdAndMeanIndex]

# Label the activy types and create factor variables  
activity_labels <- read.table("UCI_HAR_Dataset/activity_labels.txt")
stdAndMeanDF$activity_labels <- factor(stdAndMeanDF$activity_labels, labels=activity_labels$V2)
stdAndMeanDF$subjects <- factor(stdAndMeanDF$subjects)
write.table(x=stdAndMeanDF, file="tidyData.csv")

# group by means  
meansForEachActivtyLevel <- aggregate(stdAndMeanDF[,-c(1,2)], by = list(stdAndMeanDF$activity_labels), mean)
names(meansForEachActivtyLevel[1]) <- "activity_labels"
# Melt seperates the id's from the data
B<-melt(stdAndMeanDF, id=c("subjects", "activity_labels"))
tidyData<-dcast(B, subjects + activity_labels ~ variable, fun.aggregate=mean)

write.table(x=tidyData, file="tidyDataMeans.csv")
