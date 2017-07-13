if(!file.exists("UCI HAR Dataset")){
    if(!file.exists("UCI HAR Dataset.zip")){
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fpfiles%2FUCI%20HAR%20Dataset.zip", 
                      "UCI HAR Dataset.zip", "curl")
        unzip(normalizePath("UCI HAR Dataset.zip"), exdir=getwd())
    } else if (file.exists("UCI HAR Dataset.zip")) {
        unzip(normalizePath("UCI HAR Dataset.zip"), exdir=getwd())
    }
} 

library(dplyr)

activityLabels = read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("V1", "Activity"), stringsAsFactors = F)
activityLabels$Activity = factor(activityLabels$Activity,levels=as.character(activityLabels$Activity))
features = read.table("UCI HAR Dataset/features.txt", stringsAsFactors = F)

x = bind_rows(read.table("UCI HAR Dataset/train/X_train.txt", stringsAsFactors = F, col.names = features$V2), 
          read.table("UCI HAR Dataset/test/X_test.txt", stringsAsFactors = F, col.names = features$V2))
x = select(x, grep("-mean\\()",features$V2), grep('-std\\()',features$V2))
y = bind_rows(read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactors = F), 
          read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactors = F))
subjectNumber = bind_rows(read.table("UCI HAR Dataset/train/subject_train.txt"), 
                      read.table("UCI HAR Dataset/test/subject_test.txt"))
yactivity = left_join(y,activityLabels, 'V1')


p = cbind(subjectNumber, yactivity$Activity, x)
colnames(p)[1:2] = c("Subject Number", "Activity")
for (i in 3:ncol(p)) {
    colnames(p)[i] = sub("^t", "time", colnames(p)[i])
    colnames(p)[i] = sub("^f", "frequency", colnames(p)[i])
    colnames(p)[i] =  sub("BodyBody|Body", "Body", colnames(p)[i])
    colnames(p)[i] =  sub("Mag", "Magnitude", colnames(p)[i])
    colnames(p)[i] =  sub("Acc", "Acceleration", colnames(p)[i])
    colnames(p)[i] =  sub("std", "SD", colnames(p)[i])
    colnames(p)[i] =  sub("mean", "Mean", colnames(p)[i])
    colnames(p)[i] =  gsub('\\.', "", colnames(p)[i])
}

p %>%  group_by(`Subject Number`, Activity) %>% summarise_all(mean) %>% write.table(.,paste0(getwd(), '/tidy.txt'))
View(read.table("tidy.txt", header = T))