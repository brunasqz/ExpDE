#' One-point recombination for DE
#' 
#' Implements the one-point recombination (as used in the Simple GA).
#' 
#' @section Recombination Parameters:
#' The \code{recpars} parameter contains all parameters required to define the 
#' recombination. \code{recombination_onepoint()} understands the following 
#' fields in recpars:
#'    - \code{K} : cut point for crossover. Defaults to NULL.
#'    Accepts integer value \code{0 < K < n}, where \code{n} is the 
#'    dimension of the problem; or \code{K = NULL} for randomly choosing a 
#'    position for each pair of points.
#'
#' @section References:
#' F. Herrera, M. Lozano, A. M. Sanchez, "A taxonomy for the crossover
#' operator for real-coded genetic algorithms: an experimental study", 
#' International Journal of Intelligent Systems 18(3) 309-338, 2003.
#'
#' @param X population matrix (original)
#' @param M population matrix (mutated) 
#' @param recpars recombination parameters (see \code{Recombination parameters} 
#' for details)
#' 
#' @return Matrix \code{U} containing the recombined population

recombination_onepoint <- function(X, M, recpars = list(K = NULL)) {

  # Error catching and default value definitions
  if (!("K" %in% names(recpars))){
    recpars$K <- NULL
  }
  if (!is.null(recpars$K)) {
    if(!(0 < recpars$K & recpars$K < ncol(X))){
      stop("recombination_onepoint() requires 0 < recpars$K < n")
    }
    if(is.character(all.equal(recpars$K, as.integer(recpars$K)))){
      stop("recombination_onepoint() requires an integer value for K")
    }
  }
  if (!identical(dim(X),dim(M))) {
    stop("recombination_exp() requires dim(X) == dim(M)")
  }
  
  if(is.null(recpars$K)){
    # Matrix of cut points
    cuts <-  matrix(rep(sample.int(n = ncol(X)-1, 
                                   size = nrow(X), 
                                   replace = TRUE),
                        times = ncol(X)),
                    nrow = nrow(X),
                    byrow=FALSE)
    
    # Matrix of inheritance
    chg <- cuts < matrix(rep(1:ncol(X),
                              times = nrow(X),
                              byrow = FALSE),
                          nrow = nrow(X),
                          byrow = TRUE)
  } else{
    # Matrix of inheritance
    chgvec <- logical(ncol(X))
    chgvec[1:recpars$K] <- TRUE
    chg <- matrix(rep(chgvec, times = nrow(X)),
                  nrow = nrow(X),
                  byrow = TRUE)
  }
  
  # Randomize which population will donate the variables with the lowermost 
  # indexes
  if (runif(1) < 0.5){ 
     chg <- !chg    
	 }
        
  # Return recombined population
  return(chg*M + (!chg)*X) 

}