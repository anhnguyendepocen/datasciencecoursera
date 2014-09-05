################################################################################
## Cache Matrix
##
## Written by Mike Silva for the R Programming Coursera Course
##
## Put comments here that give an overall description of what your
## functions do


## This function creates a special "matrix" object that can cache its inverse

makeCacheMatrix <- function(x = matrix()) {
  cache.matrix <- NULL
  set <- function(y) {
    x <<- y
    cache.matrix <<- NULL
  }
  get <- function() x
  setcachematrix <- function(m) cache.matrix <<- m
  getcachematrix <- function() cache.matrix
  list(set = set, get = get,
       setcachematrix = setcachematrix,
       getcachematrix = getcachematrix)
}

## This function computes the inverse of the special "matrix" returned by 
## makeCacheMatrix above.  If the inverse has already been calculated (and the 
## matrix has not changed), then the cachesolve should retrieve the inverse 
## from the cache.

cacheSolve <- function(x, ...) {
  m <- x$getcachematrix()
  if(!is.null(m)) {
    ## getting cached data
    return(m)
  }
  data <- x$get()
  m <- solve(data, ...)
  x$setcachematrix(m)
  ## Return a matrix that is the inverse of 'x'
  m   
}
