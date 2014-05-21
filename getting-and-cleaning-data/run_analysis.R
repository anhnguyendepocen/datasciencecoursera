##
# run_analysis.R
#
# Written by: Mike Silva (mike.a.silva@gmail.com)
#
##

# Step 1: Get the data
# Download the data
if(!file.exists("UCI HAR Dataset.zip")){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url,destfile="UCI HAR Dataset.zip")
  
  # This was designed for a Windows 7 environment.  If this doesn't work you 
  # will need to uncomment the following line.
  #download.file(url,destfile="UCI HAR Dataset.zip",method="curl")
  
  rm(url)  # Leave no trace
}

# Unzip the data
if(!file.exists("UCI HAR Dataset/README.txt")){
  unzip("UCI HAR Dataset.zip")
}

# Step 2: Build tidy table
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", sep = " ", col.names = c("activity.id", "activity.label"))
subject_test <- read.delim("UCI HAR Dataset/test/subject_test.txt", sep = " ", header = FALSE, col.names = c("subject.id"))
subject_train <- read.delim("UCI HAR Dataset/train/subject_train.txt", sep = " ", header = FALSE, col.names = c("subject.id"))
features <- read.table("UCI HAR Dataset/features.txt", sep = " ", col.names = c("column.id", "messy.name"))

# Step 3: Scrub the feature names
scrubber <- function(messy){
  messy <- sub("Body",".body", messy)
  messy <- sub("Gyro",".gyro", messy)
  messy <- sub("Jerk",".jerk", messy)
  messy <- sub("arCoeff", "ar.coeff", messy)
  messy <- sub("Acc",".acc", messy)
  messy <- sub("\\()-",".", messy)
  messy <- sub("\\()","", messy)
  messy <- gsub("-",".", messy)
  messy <- sub("\\(",".", messy)
  messy <- sub("\\)","", messy)
  messy <- sub("\\,",".", messy) 
  tolower(messy)
}
features$scrubbed.names <- scrubber(features$messy.name)

widths <- rep(16, 561) 

X_train <- read.fwf("UCI HAR Dataset/train/X_train.txt", 
                    widths = widths, 
                    header = FALSE, 
                    col.names = features$scrubbed.names)

Y_train <- read.fwf("UCI HAR Dataset/train/y_train.txt", 
                    widths = widths, 
                    header = FALSE, 
                    col.names = features$scrubbed.names)


X_test <- read.fwf("UCI HAR Dataset/test/X_test.txt", 
                   widths = widths, 
                   header = FALSE, 
                   col.names = features$scrubbed.names)

Y_test <- read.fwf("UCI HAR Dataset/test/Y_test.txt", 
                   widths = widths, 
                   header = FALSE, 
                   col.names = features$scrubbed.names)

keep <- names(Y_train) %in% c(grep("std",  names(Y_train), value=TRUE), 
                              grep("mean", names(Y_train), value=TRUE))