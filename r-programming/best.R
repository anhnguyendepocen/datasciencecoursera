# best.R
#
# Written by Mike Silva
#
# Best that take two arguments: the 2-character abbreviated name of a state and 
# an outcome name. The function reads the outcome-of-care-measures.csv file and
# returns a character vector with the name of the hospital that has the best 
# (i.e. lowest) 30-day mortality for the specified outcome in that state. The 
# outcomes can be one of "heart attack", "heart failure", or "pneumonia". 
# Hospitals that do not have data on a particular outcome are excluded
# from the set of hospitals when deciding the rankings.
#
# If there is a tie for the best hospital for a given outcome, then the 
# hospital names should be sorted in alphabetical order and the first 
# hospital in that set should be chosen.

best <- function(state, outcome) {
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
  
  # Find the "best" outcome rate by sorting the results
  attach(csv, warn.conflicts = FALSE)
  csv <- csv[order(OutcomeRate,HospitalName),]  
  
  # Return hospital name in that state with lowest 30-day death
  # rate
  csv$HospitalName[1]
}