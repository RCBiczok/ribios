\name{setDebug}
\alias{setDebug}
\alias{unsetDebug}
\alias{isDebugging}
\alias{isIntDebugging}
\title{
  Functions for command-line Rscript debugging
}
\description{
  These functions are used to debug command-line executable Rscripts in
  R sessions
}
\usage{
setDebug()
unsetDebug()
isDebugging()
isIntDebugging()
}
\details{
  \code{setDebug} sets the environmental variable
  \code{RIBIOS_SCRIPT_DEBUG} as \code{TRUE}. \code{unsetDebug} unsets
  the variable. \code{isDebugging} checks whether the variable is set or
  not. \code{isIntDebugging} tests whether the scripts runs
  interactively or runs in the debugging mode. The last one can be
  useful when debugging Rscript in a R session.

  A programmer wishing to debug a Rscript can explicitly set (or
  unset) the \code{RIBIOS_SCRIPT_DEBUG} variable in order to activate
  (inactivate) certain trunks of codes. This can be automated via
  \code{isDebugging}, or probably more conveniently, by
  \code{isIntDebugging}: if the script runs in an interactive
  mode, or the debugging flag is set, the function returns \code{TRUE}.
}
\value{
  \code{setDebug} and \code{unsetDebug} returns an invisible value
  indicating whether the variable setting (unsetting) was successful.

  \code{isDebugging} and \code{isIntDebugging} returns logical
  values.
}
\author{
  Jitao David Zhang <jitao_david.zhang@roche.com>
}
\examples{
unsetDebug()
print(isDebugging())
setDebug()
print(isDebugging())
unsetDebug()
print(isDebugging())
print(isIntDebugging())
}
