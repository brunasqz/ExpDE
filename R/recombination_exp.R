#' Exponential recombination for DE
#' 
#' Implements the "/exp" (exponential) recombination for the ExpDE framework
#' 
#' @section Recombination Parameters:
#' The \code{recpars} parameter contains all parameters required to define the 
#' recombination. \code{recombination_exp()} understands the following 
#' fields in \code{recpars}:
#' \itemize{
#'    \item \code{cr} : component-wise probability of selection as a cut-point.
#'    \cr
#'    Accepts numeric value \code{0 < cr <= 1}.
#' }
#' 
#' @section References:
#' K. Price, R.M. Storn, J.A. Lampinen, "Differential Evolution: A 
#' Practical Approach to Global Optimization", Springer 2005
#'
#' @section X:
#' Population matrix (original).
#' @section M: 
#' Population matrix (mutated).
#' 
#' @param L list with all parameters for ExpDE framework 
#' @param recpars recombination parameters (see \code{Recombination parameters} 
#' for details)
#' 
#' @return Matrix \code{U} containing the recombined population
#' 
#' @export

recombination_exp <- function(L, recpars) {
  X       = L$X
  M       = L$M
  
  # ========== Error catching and default value definitions
  assertthat::assert_that(assertthat::has_name(recpars, "cr"),
                          is_within(recpars$cr, 0, 1))
  # ==========
  
  # Start points for mutation: for each row, a value between 1 and length(x),
  # uniformly distributed
  mut.start <- sample.int(n       = ncol(X),
                          size    = nrow(X),
                          replace = TRUE)
  
  # End points for mutation: for each row, a value between mut.start and 
  # (mut.start + length(x) - 1), exponentially distributed
  probs <- recpars$cr^(1:ncol(X) - 1) - recpars$cr^(1:ncol(X))
  mut.end    <- mut.start + sample(x    = 1:ncol(X) - 1,
                                   size = nrow(X),
                                   replace = TRUE,
                                   prob = probs / sum(probs))
  
  # Helper function for setting mutation indices: 
  # for each row wrap around the end of the vector, 
  # e.g., if n = 5, s = 3 and e = 6, returns z = [1, 0, 1, 1, 1] (pos 3,4,5,1)
  # e.g., if n = 5, s = 1 and e = 1, returns z = [1, 0, 0, 0, 0] (pos 1)
  setfun <- function(n, s, e) {
    z<-numeric(n)
    z[(s - 1):(e - 1) %% n + 1] <- 1
    z
  }
  
  # Recombination matrix - using mapply() to apply over multiple indexed objects
  R <- t(mapply(FUN      = setfun, 
                n        = rep(ncol(X), nrow(X)),
                s        = mut.start,
                e        = mut.end,
                SIMPLIFY = TRUE))
  
  # Return recombined population
  return(R*M + (1 - R)*X)
}
