library(reshape2)

FileDataSet <- "getdata_dataset.zip"

## Downloading the file and then unzipping it 
if (!file.exists(FileDataSet)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, FileDataSet, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(FileDataSet) 
}

# Loading activity labels and corresponding data
ActivityLabelsData <- read.table("UCI HAR Dataset/activity_labels.txt")
ActivityLabelsData[,2] <- as.character(ActivityLabelsData[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresWantedFromData <- grep(".*mean.*|.*std.*", features[,2])
featuresWantedFromData.names <- features[featuresWantedFromData,2]
featuresWantedFromData.names = gsub('-mean', 'Mean', featuresWantedFromData.names)
featuresWantedFromData.names = gsub('-std', 'Std', featuresWantedFromData.names)
featuresWantedFromData.names <- gsub('[-()]', '', featuresWantedFromData.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWantedFromData]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWantedFromData]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWantedFromData.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = ActivityLabelsData[,1], labels = ActivityLabelsData[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
