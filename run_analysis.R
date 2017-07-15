if(!file.exists("UCI HAR Dataset")) { #Check wether the folder containing the data sets exists in the working directory.
    if(!file.exists("UCI HAR Dataset.zip")){ # If not then see whether the zip file exist. #If not then download it.
            switch(Sys.info()[['sysname']],
                   Windows = {download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                                            "UCI HAR Dataset.zip", method = "wininet", mode = "wb")},
                   Linux  = {download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                                           "UCI HAR Dataset.zip", method="curl")},
                   Darwin = {download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                                           "UCI HAR Dataset.zip", method="curl")})
        unzip(normalizePath("UCI HAR Dataset.zip"), exdir=getwd()) #And unzip it
    } else if (file.exists("UCI HAR Dataset.zip")) { # If the zip exists then unzip it.
        unzip(normalizePath("UCI HAR Dataset.zip"), exdir=getwd())
    }
        }

#load dplyr
library(dplyr)
library(tidyr)

#function to make a combines data frame
make.p = function(){
        #Load activity_labels.txt
        activityLabels = read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("V1", "Activity"), stringsAsFactors = F)
        
        #Make the labels factor variable + assign labels with desired levels.
        activityLabels$Activity=factor(activityLabels$Activity, levels = as.character(activityLabels$Activity))  
        
        #Load features.txt
        features = read.table("UCI HAR Dataset/features.txt", stringsAsFactors = F) 
        
        #Load X_train.txt and X_test.txt. row bind them. Select only variables with mean and SD, excluding meanFrequency.
        x = bind_rows(read.table("UCI HAR Dataset/train/X_train.txt", stringsAsFactors = F, col.names = features$V2), 
                      read.table("UCI HAR Dataset/test/X_test.txt", stringsAsFactors = F, col.names = features$V2)) %>%
                select(grep("-mean\\()",features$V2), grep('-std\\()',features$V2))
        
        #Load y_train.txt and y_test.txt. Row bind them.
        y = bind_rows(read.table("UCI HAR Dataset/train/y_train.txt", stringsAsFactors = F), 
                      read.table("UCI HAR Dataset/test/y_test.txt", stringsAsFactors = F))
        
        #Load subject_train.txt and subject_test.txt. Row bind them.
        subjectNumber = bind_rows(read.table("UCI HAR Dataset/train/subject_train.txt"), 
                                  read.table("UCI HAR Dataset/test/subject_test.txt"))
        
        #Add activity labels according to the numbers in y$V1
        yactivity = left_join(y,activityLabels, 'V1')
        
        #Column bind all data frames
        cbind(subjectNumber, yactivity$Activity, x)    
}

#make a combines data frame
p = make.p()

#Give the df variable names.
colnames(p)[1:2] = c("Subject.Number", "Activity")

for (i in 3:68) {
        colnames(p)[i] <- gsub('\\.', "", colnames(p)[i]) %>% 
                sub("^t", "Time.",.) %>% 
                sub("^f", "frequency.",.) %>%
                sub("BodyBody|Body", "Body.", .) %>%
                sub("Mag", "Magnitude.", .) %>%
                sub("Acc", "Acceleration.", .) %>%
                sub("Jerk", "Jerk.", .) %>%
                sub("Gyro", "Gyro.", .) %>%
                sub("std", "SD.", .) %>%
                sub("mean", "Mean.", .)
}


#Group by Subject Number and Activity
#Create average of each variable for each subject/activity group.
#Gather features into a single column
#Export the tidy data frame into .txt file
#p %>%  group_by(Subject.Number, Activity) %>% summarise_all(mean) %>% 
p %>% aggregate(. ~ Subject.Number + Activity, ., mean) %>%
        gather(Features, 'Averages of variable', -Subject.Number, -Activity) %>% 
        write.table(.,paste0(getwd(), '/tidy.txt'), row.name=FALSE)
View(read.table("tidy.txt", header = T))

#Delete the downloaded files.
unlink(grep('^UCI HAR Dataset', dir(), value = T), recursive = T)
