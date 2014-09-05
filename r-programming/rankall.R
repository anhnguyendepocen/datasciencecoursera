# rankall.R
#
# Written by Mike Silva
#
# Rank hospital that take two arguments: the outcome name, and the rank number.
# The function reads the outcome-of-care-measures.csv file and returns a data 
# frame character with the name of the hospital and state abbreviation that has
# the matching 30-day mortality rank for the specified outcome. The outcomes 
# can be one of "heart attack", "heart failure", or "pneumonia". Hospitals that 
# do not have data on a particular outcome are excluded from the set of 
# hospitals when deciding the rankings.
#
# If there is a tie for the best hospital for a given outcome, then the 
# hospital names should be sorted in alphabetical order and the first 
# hospital in that set should be chosen.

rankall <- function(outcome, num = "best") {
  # Read outcome data
  csv <- read.csv("outcome-of-care-measures.csv", colClasses="character")
  
  # Set up the data frame that will hold the results
  s <- csv$State  # Get the states 
  s <- s[!duplicated(s) ]  # Remove the duplicates
  df <- data.frame(hospital = c(NA),state = s)  # Build the data frame
  df <- df[order(state),]  # Sort alphabetically
  row.names(df) <- df$state  # Rename the row names
  
  # Check the validity of the outcome argument
  valid.outcome <- c('heart attack', 'heart failure', 'pneumonia')
  if(!outcome %in% valid.outcome){
    stop("invalid outcome")
  }

  # Clean up the awful variable names
  names(csv) = gsub("[.]","", names(csv))
  
  # Rename variable we are interested in to "OutcomeRate"
  if(outcome == "heart attack"){
    names(csv)[names(csv) == 'Hospital30DayDeathMortalityRatesfromHeartAttack'] <- 'OutcomeRate'
  } else if(outcome == "heart failure"){
    names(csv)[names(csv) == 'Hospital30DayDeathMortalityRatesfromHeartFailure'] <- 'OutcomeRate'
  } else {
    names(csv)[names(csv) == 'Hospital30DayDeathMortalityRatesfromPneumonia'] <- 'OutcomeRate'
  }
  
  # Only keep HospitalName and OutcomeRate
  csv <- csv[c("HospitalName", "OutcomeRate","State")]
  
  # Change the OutcomeRate to a numeric w/o any warnings about NAs introduced by coercion
  csv$OutcomeRate <- suppressWarnings(as.numeric(csv$OutcomeRate))
  
  # Remove the NAs
  csv <- csv[!is.na(csv$OutcomeRate),]
  
  # Sort the data for ranking
  attach(csv, warn.conflicts = FALSE)
  if(num == "worst"){
    # Sort with the worst outcomes at the top
    csv <- csv[order(State, -OutcomeRate, HospitalName),]
    
    # Rank the hospitals in groups
    csv$Rank <- ave(csv$OutcomeRate, csv$State, FUN=function(x)rank(-x,ties.method= "first"))
    
    # Set the index for the worst
    num <- 1
    
  } else{
    # Sort with the best outcomes at the top
    csv <- csv[order(State, OutcomeRate, HospitalName),]
    
    # Rank the hospitals in groups
    csv$Rank <- ave(csv$OutcomeRate, csv$State, FUN=function(x)rank(x,ties.method= "first"))
    
    if(num == "best"){
      # Set the index for the best
      num <- 1
    }
  }
  
  
  # Only keep the ranking we care about
  csv <- csv[csv$Rank == num,]
  
  # Update the data frame with the hospital names
  df$hospital <- csv[match(df$state, csv$State),1]
  
  # Return a data frame with the hospital names and the
  # (abbreviated) state name
  df
}