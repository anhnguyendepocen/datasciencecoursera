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
  
  # Leave no trace
  rm(url)
}

# Unzip the data
if(!file.exists("UCI HAR Dataset/README.txt")){
  unzip("UCI HAR Dataset.zip")
}

# Step 2: Combine the data
features <- read.table("UCI HAR Dataset/features.txt", sep = " ", col.names = c("column.id", "messy.name"))

# This function cleans up the messy variable names.  It inserts periods 
# in between words, makes them lower case, and removes the () and -
# characters
scrubber <- function(messy){
  messy <- sub("Body",".body", messy)
  messy <- sub("bodybody","body.body", messy)
  messy <- sub("Gyro",".gyro", messy)
  messy <- sub("Gravity",".gravity", messy)
  messy <- sub("Jerk",".jerk", messy)
  messy <- sub("Energy",".energy", messy)
  messy <- sub("Mag", ".mag", messy)
  messy <- sub("arCoeff", "ar.coeff", messy)
  messy <- sub("Acc",".acc", messy)
  # The next line is to ensure this doesn't get pulled in latter
  messy <- sub("meanFreq","avg.freq", messy)
  messy <- sub("gravityMean", "gravity.avg", messy)
  messy <- sub("\\()-",".", messy)
  messy <- sub("\\()","", messy)
  messy <- gsub("-",".", messy)
  messy <- sub("\\(",".", messy)
  messy <- sub("\\)","", messy)
  messy <- sub("\\,",".", messy)
  messy <- tolower(messy)
  messy <- sub("mean.gravity",".avg.gravity", messy)
  sub("bodybody","body.body", messy)
}
# Now that the function is defined, let's scrub some names
features$scrubbed.names <- scrubber(features$messy.name)

# Leave no trace
rm(scrubber)

X_train <- read.table("UCI HAR Dataset/train/X_train.txt", 
                      header = FALSE, 
                      col.names = features$scrubbed.names,
                      comment.char = "",
                      nrow=7352)

X_test <- read.table("UCI HAR Dataset/test/X_test.txt", 
                     header = FALSE, 
                     col.names = features$scrubbed.names,
                     comment.char = "",
                     nrow=2947)

# Since we only want to keep the mean and standard deviation measures, let's
# identify the columns we want to keep out of the 561 posibilities
keep <- names(X_train) %in% c(grep("std",  names(X_train), value=TRUE), 
                           grep("mean", names(X_train), value=TRUE))

# Let's only keep the columns that have std or mean in their name
X_train <- X_train[,keep]
X_test <- X_test[,keep]

# Leave no trace
rm(features)
rm(keep)

# This is just so I can track where the observations came from
#X_test$measure = c("test")
#X_train$measure = c("train")

# Add on the subject id
subject_test <- read.delim("UCI HAR Dataset/test/subject_test.txt", sep = " ", header = FALSE, col.names = c("subject.id"))

subject_train <- read.delim("UCI HAR Dataset/train/subject_train.txt", sep = " ", header = FALSE, col.names = c("subject.id"))

X_test$subject.id <- subject_test$subject.id
X_train$subject.id <- subject_train$subject.id

# Leave no trace
rm(subject_test)
rm(subject_train)

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

# Leave no trace
rm(Y_test)
rm(Y_train)

data <- rbind(X_train, X_test)

# Leave no trace
rm(X_test)
rm(X_train)

# Add on the activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", sep = " ", col.names = c("activity.id", "activity.label"))
# make the activity labels lower case and with a space instead of an underscore
activity_labels$activity.label <- gsub("_"," ", tolower(activity_labels$activity.label))

data$activity.label <- activity_labels[data$activity.id,2]
rm(activity_labels)  # Leave no trace

# data has 10,299 observations and 90 variables

# Step 3: Do the analysis
# This step invloced getting the average of each variable for each combination 
# of subject and activity, and saving it to the tidy.data data frame
data$activity <- as.factor(paste0("Subject ",data$subject.id,": ",data$activity.label))

# exclude variables subject.id, activity.id, activity.label
drop <- names(data) %in% c("subject.id", "activity.id", "activity.label") 

# Tranform data frame into data table
require(data.table)
data <- as.data.table(data[!drop])

# Leave no trace
rm(drop)

# Create the tidy data set
options(datatable.optimize=1)
tidy <- data[, lapply(.SD, mean), by = activity]
