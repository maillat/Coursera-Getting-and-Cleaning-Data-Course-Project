#Anticipated libraries
library(dplyr)
library(plyr)
library(data.table)
library(tidyr)


#***********************************************************************************
# Preliminary Step - Download and unzip source data
#***********************************************************************************
# Download files
      filesPath <- "/Users/Data Science Coursera/Getting and Cleaning Data course project"
      setwd(filesPath)
      if(!file.exists("./data")){dir.create("./data")}
      fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
      download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

# Unzip DataSet to /data directory
      unzip(zipfile="./data/Dataset.zip",exdir="./data")

# Record date downloaded
      date()
      #[1] "Sun Jan 31 09:55:06 2016"

# Reset working directory
      filesPath <- "/Users/Data Science Coursera/Getting and Cleaning Data course project/data/UCI HAR Dataset/"

# Read subject, test and train files
      #Subject files
      subject_test <-read.table(file.path(filesPath, "test/subject_test.txt"))
      subject_train <-read.table(file.path(filesPath, "train/subject_train.txt"))
      
      #Activity Number Labels
      y_test <-read.table(file.path(filesPath, "test/y_test.txt"))
      y_train <-read.table(file.path(filesPath, "train/y_train.txt"))
      
      #Data files
      x_test <-read.table(file.path(filesPath, "test/X_test.txt"))
      x_train <-read.table(file.path(filesPath, "train/X_train.txt"))
      
#***********************************************************************************
# Step 1 - Merges the training and the test sets to create one data set.
#***********************************************************************************
# Combine train and test datasets for each type of file
      #Combine subject files and rename
      all_subject_data <- rbind(subject_train, subject_test)
      setnames(all_subject_data, "V1", "subject")

      #Combine activities and rename
      all_y_data <- rbind(y_train, y_test)
      setnames(all_y_data, "V1", "activityNum")
      
      #Combine data files
      all_x_data <- rbind(x_train, x_test)
            
      #View(all_x_data)
      
# Change variable names in data table to feature names
      features <- read.table(file.path(filesPath, "features.txt")) 
      setnames(features, names(features), c("featureNum", "featureName"))
      colnames(all_x_data) <- features$featureName
      
      #View(all_x_data)
      
# Add activity label to activity number
      activityLabels <- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
      setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))
      
      #View(activityLabels)
      
# Merge all columns into single table
      all_sub_y_data <- cbind(all_subject_data, all_y_data)
      all_x_data <- cbind(all_sub_y_data, all_x_data)
            #audit
            #str(all_x_data)

            
#***********************************************************************************     
# Step 2 - Extracts only the measurements on the mean and standard deviation for each measurement.
#***********************************************************************************
# Get only columns with mean() or std() in their names
      featuresKeep <- grep("mean\\(\\)|std\\(\\)",features$featureName,value=TRUE)
      
# Subset the desired columns
      featuresKeep <- union(c("subject","activityNum"), featuresKeep)
      all_x_data <- subset(all_x_data,select=featuresKeep) 
          #audit
          #str(all_x_data)
      
          
#***********************************************************************************      
# Step 3 - Use descriptive activity names to name the activities in the data set
#***********************************************************************************
# Include activity label in data table
      all_data <- merge(activityLabels, all_x_data , by="activityNum", all.x=TRUE)
      
      #Remove activityNum since it is redundant
      all_data$activityNum <- NULL
            #audit
            #str(all_data)   
            

      
#***********************************************************************************     
# Step 4 - Appropriately label the data set with descriptive variable names.
#***********************************************************************************
# Audits before writing out tidy dataset
      #str(all_data)
      
      #subject is an integer - change to factor
      #Convert subject to factor
      all_data$subject <- as.factor(all_data$subject)
      
      #Check list of distinct subjectIDs and activity names
      #unique(all_data$subject)
      #unique(all_data$activityName)

#Convert to all lower case
      colnames(all_data) <- tolower(colnames(all_data))
      
      
# Clean up column names
      #Expand abbreviations to make more legible
      names(all_data)<-gsub("std()", "SD", names(all_data))#leave as caps to emphasize
      names(all_data)<-gsub("mean()", "MEAN", names(all_data)) #leave as caps to emphasize
      names(all_data)<-gsub("^t", "time", names(all_data))
      names(all_data)<-gsub("^f", "frequency", names(all_data))
      names(all_data)<-gsub("acc", "accelerometer", names(all_data))
      names(all_data)<-gsub("gyro", "gyroscope", names(all_data))
      names(all_data)<-gsub("mag", "magnitude", names(all_data))
      names(all_data)<-gsub("bodybody", "body", names(all_data))


#***********************************************************************************     
# Step 5 - From the data set in step 4, create a second independent tidy data set 
          # with the average of each variable for each activity and each subject.
#***********************************************************************************      
# Create dataTable with variable means sorted by subject and Activity
      all_data_means<- aggregate(. ~ subject - activityname, data = all_data, mean) 
      all_data_means<- tbl_df(arrange(all_data_means,subject,activityname))
      #audit - One last check
      str(all_data_means)   

# Write dataset to text file
      write.table(all_data_means, "tidy.txt", sep="\t", row.names = FALSE, quote = FALSE)
      


      