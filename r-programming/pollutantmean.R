pollutantmean <- function(directory, pollutant, id = 1:332) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files
  
  ## 'pollutant' is a character vector of length 1 indicating
  ## the name of the pollutant for which we will calculate the
  ## mean; either "sulfate" or "nitrate".
  
  ## 'id' is an integer vector indicating the monitor ID numbers
  ## to be used
  
  ## Return the mean of the pollutant across all monitors list
  ## in the 'id' vector (ignoring NA values)
  
  ## Import the csvs into a data frame
  files = list.files(path = directory, pattern="*.csv")
  for(file in files[id]){
    path <- paste(directory,"/",file, sep="")
    if(!exists("csv")) {
      ## Create the data frame
      csv <- read.csv(path)
    }
    else {
      ## Append the data to the data frame
      df <- read.csv(path)
      csv <- rbind(csv, df)
    }
  }
  
  ## Subset the csv data based on the function arguments
  ## First the monitor ID's
  subset <- csv[csv$ID %in% id,]
  ## Second the pollutant
  subset <- subset[pollutant]
  ## Third only rows with values (remove NAs)
  subset <- subset[complete.cases(subset),]
  
  ## Return the mean
  mean(subset)
}