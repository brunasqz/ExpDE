#' p-Best recombination for DE
#' 
#' Implements the "/pbest" (p-Best) recombination for the ExpDE framework
#' 
#' @section Recombination Parameters:
#' The \code{recpars} parameter contains all parameters required to define the 
#' recombination. \code{recombination_pbest()} understands the following 
#' fields in \code{recpars}:
#' \itemize{
#'    \item \code{cr} : component-wise probability of using the value in 
#'                      \code{M}.\cr
#'                      Accepts numeric value \code{0 < cr <= 1}.
#'}
#'
#' @section Warning:
#' This routine will search for the iterations counter (\code{t}), the maximum 
#' number of iterations (\code{stopcrit$maxiter}), and the performance vector 
#' of population \code{X} (\code{J}) in list \code{L}.
#' These variables must be defined for \code{recombination_pbest()} to work. 
#'
#' @section References:
#' S.M. Islam, S. Das, S. Ghosh, S. Roy, P.N. Suganthan, "An Adaptive 
#' Differential Evolution Algorithm With Novel Mutation and Crossover 
#' Strategies for Global Numerical Optimization", IEEE. Trans. Systems, Man
#' and Cybernetics - Part B 42(2), 482-500, 2012
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

recombination_pbest <- function(L, recpars) {
  X       = L$X
  M       = L$M

  # ========== Error catching and default value definitions
  assertthat::assert_that(assertthat::has_name(recpars, "cr"),
                          is_within(recpars$cr, 0, 1),
                          all(assertthat::has_name(L, 
                                                   c("t", "stopcrit", "J"))),
                          assertthat::has_name(L$stopcrit, "maxiter"))
    # ==========
  
  # Extract relevant values from the parent environment
  G    <- L$t
  Gmax <- L$stopcrit$maxiter
  J    <- L$J
  
  # Sort X by performance (i.e., in ascending order of J)
  X <- X[order(J), ]
  
  # Draw recombination partners from the p-best vectors
  # p = ceiling(0.5 * popsize * (1 - (t - 1)/maxiter))
  Indx <- sample.int(ceiling(0.5 * nrow(X) * (1 - (G - 1)/Gmax)), 
                     size    = nrow(X), 
                     replace = TRUE)
  
  # Assemble recombination partner matrix
  Xcross <- X[Indx, ]
  
  # Perform binomial recombination with the selected partners
  return(recombination_bin(Xcross, M, recpars))
  
}
