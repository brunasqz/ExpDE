#' /sbx recombination for DE
#' 
#' Implements the "/sbx" (Simulated Binary) recombination for the ExpDE 
#' framework
#' 
#' @section Recombination Parameters:
#' The \code{recpars} parameter contains all parameters required to define the 
#' recombination. \code{recombination_sbx()} understands the following field in 
#' \code{recpars}:
#' \itemize{
#'    \item \code{eta} : spread factor.\cr
#'    Accepts numeric value \code{eta > 0}.
#'  }
#'    
#'
#' @section References:
#' K. Price, R.M. Storn, J.A. Lampinen, "Differential Evolution: A 
#' Practical Approach to Global Optimization", Springer 2005\cr
#' F. Herrera, M. Lozano, A. M. Sanchez, "A taxonomy for the crossover
#' operator for real-coded genetic algorithms: an experimental study", 
#' International Journal of Intelligent Systems 18(3) 309-338, 2003.\cr
#' K. Deb, R.B. Agrawal, "Simulated binary crossover for continuous search 
#' space", Complex Systems (9):115-148, 1995.
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

recombination_sbx <- function(L, recpars) {
  X       = L$X
  M       = L$M

  # ========== Error catching and default value definitions
  assertthat::assert_that(assertthat::has_name(recpars, "eta"),
                          is.numeric(recpars$eta),
                          recpars$eta > 0)
  # ==========
  R <- randM(X)
  S <- R <= 0.5

  #Define beta parameters
  mexp <- (1 / (recpars$eta + 1))
  beta <- S * ((2 * R) ^ mexp) + (!S) * ((2 * (1 - R)) ^ mexp)
  
  # Return recombined population
  dir  <- sign(0.5 - matrix(rep(stats::runif(nrow(X)),
                                times = ncol(X)),
                            ncol = ncol(X)))
  return(0.5 * ((1 + dir * beta) * X + (1 - dir * beta) * M ))
}
