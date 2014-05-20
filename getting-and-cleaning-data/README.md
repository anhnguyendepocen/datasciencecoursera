README
========================================================

run_analysis.R does the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive activity names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Data Layout
-------------------------

![Data Layout](http://coursera-forum-screenshots.s3.amazonaws.com/d3/2e01f0dc7c11e390ad71b4be1de5b8/Slide2.png)

How it Works
-------------------------
This script accomplishes the objectives outlined above by doing the 
### Step 1: Get the data
This script will create a directory for storing the data, download a zip file and extract the data for you if you don't have it on your local computer
```{r}
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
```
### Step 2: Import the text files
```{r}

```