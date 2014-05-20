##
# run_analysis.R
#
# Written by: Mike Silva (mike.a.silva@gmail.com)
#
##

if(!file.exists("./data")){dir.create("./data")}

if(!file.exists("./data/UCI HAR Dataset.zip")){
  # Since the file doesn't exist lets download it
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url,destfile="./data/UCI HAR Dataset.zip")
  # This was designed for a Windows 7 environment.  If this doesn't work you 
  # will need to uncomment the following line.
  #download.file(url,destfile="./data/UCI HAR Dataset.zip",method="curl")
}

if(!file.exists("./data/UCI HAR Dataset/README.txt")){
  # The files have not been unzipped
  setwd("./data")
  unzip("UCI HAR Dataset.zip")
  setwd("~")
}