##
# run_analysis.R
#
# Written by: Mike Silva (mike.a.silva@gmail.com)
#
##

# This script has been designed to remove variables after they are no longer
# needed.  If you want to keep the variables in the environment, set this
# variable to FALSE.
leave.no.trace = TRUE

# Step 1: Get the Raw Data Files
if(!file.exists("UCI HAR Dataset.zip")){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url,destfile="UCI HAR Dataset.zip")
  
  # This was designed for a Windows 7 environment.  If this doesn't work you 
  # will need to uncomment the following line.
  #download.file(url,destfile="UCI HAR Dataset.zip",method="curl")
  
  if(leave.no.trace){
    rm(url)
  }
}

# Unzip the data
if(!file.exists("UCI HAR Dataset/README.txt")){
  unzip("UCI HAR Dataset.zip")
}

# Step 2. Combine & Transform the Raw Data Files

# Get the variable names
features <- read.table("UCI HAR Dataset/features.txt", sep = " ", col.names = c("column.id", "messy.name"))

# This function cleans up the messy variable names.  It inserts periods 
# in between words, makes them lower case, and removes the () and -
# characters and makes the variable names easier to understand
scrubber <- function(messy){
  messy <- sub("Body", ".body", messy)
  messy <- sub("bodyBody", "body", messy)
  messy <- sub("Gyro", ".gyroscope", messy)
  messy <- sub("Gravity", ".gravity", messy)
  messy <- sub("Jerk", ".jerk", messy)
  messy <- sub("Energy", ".energy", messy)
  messy <- sub("Mag", ".magnitude", messy)
  messy <- sub("arCoeff", "ar.coeff", messy)
  messy <- sub("Acc", ".accelerometer", messy)
  messy <- sub("\\()-", ".", messy)
  messy <- sub("\\()", "", messy)
  messy <- gsub("-", ".", messy)
  messy <- sub("\\(", ".", messy)
  messy <- sub("\\)", "", messy)
  messy <- sub("\\,", ".", messy)
  messy <- tolower(messy)
  messy <- sub("t.body", "mean.time.body", messy)
  messy <- sub("t.gravity", "mean.time.gravity", messy)
  messy <- sub("f.body", "mean.frequency.body", messy)
  messy <- sub("f.gravity", "mean.frequency.gravity", messy)
  messy <- sub(".std", ".standard.deviation", messy)
  return(messy)
}

# Now that the function is defined, let's scrub some names
features$scrubbed.name <- scrubber(features$messy.name)

if(leave.no.trace){
  rm(scrubber)
}

# Get the test and training data
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", 
                      header = FALSE, 
                      col.names = features$scrubbed.name,
                      comment.char = "",
                      nrow=7352)
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", 
                     header = FALSE, 
                     col.names = features$scrubbed.name,
                     comment.char = "",
                     nrow=2947)

# Since we only want to keep the mean and standard deviation measures, let's
# identify the columns we want to keep out of the 561 posibilities                          
features$keep <- (grepl("std|mean",features$messy.name) & !(grepl("meanFreq",features$messy.name)))
X_train <- X_train[,features$keep]
X_test <- X_test[,features$keep]

if(leave.no.trace){
  rm(features)
}

# Add on the subject id
subject_test <- read.delim("UCI HAR Dataset/test/subject_test.txt", sep = " ", header = FALSE, col.names = c("subject.id"))
subject_train <- read.delim("UCI HAR Dataset/train/subject_train.txt", sep = " ", header = FALSE, col.names = c("subject.id"))
X_test$subject.id <- subject_test$subject.id
X_train$subject.id <- subject_train$subject.id

if(leave.no.trace){
  rm(subject_test)
  rm(subject_train)
}

# Add on the activity id
Y_train <- read.table("UCI HAR Dataset/train/y_train.txt", 
                      header = FALSE, 
                      col.names = c("activity.id"),
                      comment.char = "",
                      nrow=7352)

Y_test <- read.table("UCI HAR Dataset/test/Y_test.txt", 
                     header = FALSE, 
                     col.names = c("activity.id"),
                     comment.char = "",
                     nrow=2947)
X_test$activity.id <- Y_test$activity.id
X_train$activity.id <- Y_train$activity.id

if(leave.no.trace){
  rm(Y_test)
  rm(Y_train)
}

# Combine the training and test data
data <- rbind(X_train, X_test)

if(leave.no.trace){
  rm(X_test)
  rm(X_train)
}

# Add on the activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", sep = " ", col.names = c("activity.id", "activity.label"))
# make the activity labels lower case and with a space instead of an underscore
activity_labels$activity.label <- gsub("_"," ", tolower(activity_labels$activity.label))
data$activity <- activity_labels[data$activity.id,2]

if(leave.no.trace){
  rm(activity_labels)
}

# data has 10,299 observations and 69 variables

# Step 3. Create the Tidy Data Set

# Now that we have the data we need to get the average of each variable for 
# each combination of subject and activity, and saving it to the tidy.data 
# data frame
tidy.data <- aggregate(.~ subject.id + activity, data = data, FUN = mean)

# Exclude activity.id variable from the tidy set
drop <- names(tidy.data) %in% c("activity.id") 
tidy.data <- tidy.data[!drop]

if(leave.no.trace){
  rm(drop)
  rm(leave.no.trace)
}

# Step 4. Export the Tidy Data Set

# Export the tidy.data as a tab deliminated file
write.table(tidy.data, "tidydata.txt", sep="\t")