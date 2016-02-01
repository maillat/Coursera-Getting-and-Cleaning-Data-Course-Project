#Load libraries
library(dplyr)
library(data.table)

#Step 1
#Download and unzip source data

##Date downloaded
date()

##
getwd()

filesPath <- "C:/Users/jb/Documents/Analytics course/coursera getting and cleaning data/course project/UCI HAR Dataset"
setwd(filesPath)
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

###Unzip DataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")