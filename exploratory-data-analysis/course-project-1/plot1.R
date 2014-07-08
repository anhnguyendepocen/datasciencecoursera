# plot1.R
#
# Written by Mike Silva
#
# This script takes the Individual household electric power consumption Data 
# Set from UC Irvine Machine Learning Repository (http://archive.ics.uci.edu/ml/) 
# and creates a histogram of the Gobal Active Power variable

create.png <- TRUE ## Set this to FALSE if you don't want a png created

# Check to see if the dataset is on the computer
if(!file.exists('household_power_consumption.txt')) {
  # Download the 20 Mb dataset if it does not exist
  file.path <- 'household_power_consumption.zip'
  if(!file.exists(file.path)){
    file.url <- 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip'
    download.file(file.url, file.path)
  }
  unzip(file.path)
}

# Loading the Data
data <- read.csv2('household_power_consumption.txt', 
                  na.strings='?', 
                  stringsAsFactors=FALSE)

# Subset the data to only have the 1st and second day of Feb. in 2007
data <- data[data$Date %in% c('1/2/2007','2/2/2007'),]

if(create.png)
  png(filename = 'plot1.png')

# Draw the histogram
hist(as.numeric(data$Global_active_power), 
     col='red', 
     main='Gobal Active Power', 
     xlab='Global Active Power (kilowatts)')

if(create.png)
  dev.off()