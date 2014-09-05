complete <- function(directory, id = 1:332) {
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files
  
  ## 'id' is an integer vector indicating the monitor ID numbers
  ## to be used
  
  ## Return a data frame of the form:
  ## id nobs
  ## 1  117
  ## 2  1041
  ## ...
  ## where 'id' is the monitor ID number and 'nobs' is the
  ## number of complete cases
  
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
  
  ## Get the complete cases
  csv <- csv[complete.cases(csv),]
  
  ## Build the data frame
  nobs <- c(0)
  data <- data.frame(id,nobs)
  ## Fill the data frame's number of observations
  for(i in id){
    data$nobs[which(data$id==i)]<- NROW(csv[which(csv$ID==i),])
  }
  data
}