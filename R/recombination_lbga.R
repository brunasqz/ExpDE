#' Linear BGA recombination for DE
#' 
#' Implements the "/lbga" (Linear Breeder Genetic Algorithm) recombination for 
#' the ExpDE framework
#'
#' @section Warning:
#' This recombination operator evaluates the candidate solutions in \code{M}, 
#' which adds an extra \code{popsize} evaluations per iteration.
#' 
#' @section References:
#' F. Herrera, M. Lozano, A. M. Sanchez, "A taxonomy for the crossover
#' operator for real-coded genetic algorithms: an experimental study", 
#' International Journal of Intelligent Systems 18(3) 309-338, 2003.\cr
#' D. Schlierkamp-voosen , H. Muhlenbein, "Strategy Adaptation by 
#' Competing Subpopulations", Proc. Parallel Problem Solving from Nature 
#' (PPSN III), 199-208, 1994.
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

recombination_lbga <- function(L, ...) {
  X       = L$X
  M       = L$M
  # ========== Error catching and default value definitions

  assertthat::assert_that(all(assertthat::has_name(L, 
                                                   c("J", "probpars", "nfe"))))
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
  
  # Set recombination parameters.
  eps <- 1e-15
  Lambda <- (C2 - C1) / matrix(rep(sqrt(rowSums((C1 - C2) ^ 2))+ eps, ncol(X)),
                               ncol = ncol(X),
                               byrow = FALSE)
  
  
  mr <- matrix(stats::runif(nrow(X) * 16), 
               ncol = 16) <= 1 / 16
  
  ms <- matrix(rep((2^-(0:15)), 
                   times = nrow(X)), 
               ncol  = 16, 
               byrow = TRUE)
  
  delta <- matrix(rep(rowSums(mr * ms), 
                     times = ncol(X)), 
                 ncol = ncol(X),
                 byrow = FALSE)
  
  # Return recombined population
  return (C1 + 0.5 * sign(0.1 - randM(X)) * delta * Lambda)
  }
