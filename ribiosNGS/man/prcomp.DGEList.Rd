% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pca.R
\name{prcomp.DGEList}
\alias{prcomp.DGEList}
\title{Principal component analysis of DGEList}
\usage{
\method{prcomp}{DGEList}(x, ntop = NULL, fun = function(x) cpm(x, log =
  TRUE))
}
\arguments{
\item{x}{A \code{DGEList} object}

\item{ntop}{Integer, how many top-variable genes should be used?}

\item{fun}{Function, how to transform counts in the DGEList into data appropriate for PCA? log-cpm is used by default.}
}
\description{
Principal component analysis of DGEList
}
