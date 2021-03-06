% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/factors.R
\name{encodeFactor}
\alias{encodeFactor}
\title{Encode factors into plain character strings}
\usage{
encodeFactor(fac)
}
\arguments{
\item{fac}{A factor vector

\code{encodeFactor} encodes a factor vector into a string vector that can be
decoded by \code{decodeFactor}. This is especially useful when factors need
to be written into relational database management systems (RDMS) while it is
desired that the order of the levels is kept.}
}
\description{
Encode factors into plain character strings
}
\examples{
testFac <- factor(c("HBV", "FCB", "BVB", "HBV"), levels=c("HBV", "FCB", "BVB"))
testFacStr <- encodeFactor(testFac)
testFacOut <- decodeFactor(testFacStr)
testthat::expect_equivalent(testFac, testFacOut)

}
