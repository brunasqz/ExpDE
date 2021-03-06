#' Heuristic Wright recombination for DE
#' 
#' Implements the "/wright" (Heuristic Wright) recombination for the ExpDE 
#' framework.
#'
#' @section Warning:
#' This recombination operator evaluates the candidate solutions in \code{M}, 
#' which adds an extra \code{popsize} evaluations per iteration.
#'
#' @section References:
#' F. Herrera, M. Lozano, A. M. Sanchez, "A taxonomy for the crossover
#' operator for real-coded genetic algorithms: an experimental study", 
#' International Journal of Intelligent Systems 18(3) 309-338, 2003.\cr
#' A.H. Wright, "Genetic Algorithms for Real Parameter Optimization",
#' Proc. Foundations of Genetic Algorithms, 205-218, 1991.
#'
#' @section X:
#' Population matrix (original).
#' @section M: 
#' Population matrix (mutated).
#' 
#' @param L list with all parameters for ExpDE framework 
#' @param ... optional parameters (unused)
#' 
#' @return Matrix \code{U} containing the recombined population
#' 
#' @export

recombination_wright <- function(L, ...) {
  X       = L$X
  M       = L$M
  
  # ========== Error catching and default value definitions
  
  assertthat::assert_that(all(assertthat::has_name(L, c("J", "probpars", "nfe"))))
  # ==========
  
  # Performance values of the current population (X)
  f.X <- L$J
  
  #Evaluate population M
  f.M <- evaluate_population(probpars = L$probpars, 
                             Pop      = M)
  
  # Update NFE counter in calling environment
  L$nfe <- L$nfe + nrow(M)
  
  # Get best parent indicator matrix
  X.is.best <- matrix(rep(f.X <= f.M,
                          times = ncol(X)),
                      ncol = ncol(X),
                      byrow = FALSE)
  
  
  # Get 'best' and 'worst' parents
  C1 <- X * X.is.best + M * !X.is.best
  C2 <- M * X.is.best + X * !X.is.best
  
  # Return recombined population
  return (randM(X) * (C1 - C2) + C1)
}
