# plot4.R
#
# Written by Mike Silva
#
# This script takes the Individual household electric power consumption Data 
# Set from UC Irvine Machine Learning Repository (http://archive.ics.uci.edu/ml/) 
# and creates a plot with four graphs

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

# Combine the date and time into a datetime
data$datetime <- strptime(paste(data$Date, data$Time), '%d/%m/%Y %H:%M:%S')

if(create.png)
  png(filename = 'plot4.png')

par(mfrow=c(2,2))

# Plot2
plot(data[c('datetime','Global_active_power')], type='l', xaxt='n', xlab='', ylab='Global Active Power (kilowatts)')
axis.POSIXct(1, data$datetime, format="%a")

plot(data[c('datetime','Voltage')], type='l', xaxt='n')
axis.POSIXct(1, data$datetime, format="%a")

# Plot3
plot(data[c('datetime','Sub_metering_1')], type='l', xaxt='n', xlab='', ylab='Energy sub metering')
axis.POSIXct(1, data$datetime, format="%a")
lines(data[c('datetime','Sub_metering_2')], col='red')
lines(data[c('datetime','Sub_metering_3')], col='blue')
legend('topright', c('Sub_metering_1', 'Sub_metering_2', 'Sub_metering_3'), lty=c(1,1,1), col=c('black', 'red','blue'), cex=0.7, bty = 'n') 


plot(data[c('datetime','Global_reactive_power')], type='l', xaxt='n')
axis.POSIXct(1, data$datetime, format="%a")


if(create.png)
  dev.off()