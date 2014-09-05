# rankhospital.R
#
# Written by Mike Silva
#
# Rank hospital that take three arguments: the 2-character abbreviated name of
# a state, an outcome name, and the rank number. The function reads the 
# outcome-of-care-measures.csv file and returns a character vector with the 
# name of the hospital that has the matching 30-day mortality rank for the 
# specified outcome in that state. The outcomes can be one of "heart attack", 
# "heart failure", or "pneumonia". Hospitals that do not have data on a 
# particular outcome are excluded from the set of hospitals when deciding the 
# rankings.
#
# If there is a tie for the best hospital for a given outcome, then the 
# hospital names should be sorted in alphabetical order and the first 
# hospital in that set should be chosen.

rankhospital <- function(state, outcome, num = "best") {
  # Read outcome data
  csv <- read.csv("outcome-of-care-measures.csv", colClasses="character")
  
  # Check the validity of the state argument
  if(!state %in% csv$State){
    stop("invalid state")
  }
  
  # Check the validity of the outcome argument
  valid.outcome <- c('heart attack', 'heart failure', 'pneumonia')
  if(!outcome %in% valid.outcome){
    stop("invalid outcome")
  }
  
  # Subset the CSV by State
  csv <- csv[csv$State == state,]
  
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
  csv <- csv[c("HospitalName", "OutcomeRate")]
  
  # Change the OutcomeRate to a numeric w/o any warnings about NAs introduced by coercion
  csv$OutcomeRate <- suppressWarnings(as.numeric(csv$OutcomeRate))
  
  # Remove the NAs
  csv <- csv[!is.na(csv$OutcomeRate),]
  
  # Find the "best" outcome rate by sorting the results
  attach(csv, warn.conflicts = FALSE)
  csv <- csv[order(OutcomeRate,HospitalName),]  
  
  # Change the text to a number
  if(num == "best"){
    num <- 1
  } else if(num == "worst"){
    num <- nrow(csv)
  }
  
  # Return hospital name in that state with 30-day death rate ranking  
  csv$HospitalName[num]
}