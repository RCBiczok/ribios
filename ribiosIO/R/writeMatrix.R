#' Export matrix into a commonly used tab-delimited format inside Roche Bioinformatics
#'
#' @description
#' \code{writeMatrix} writes a matrix into a non-quoted, tab-delimited file.
#'
#' @details
#' Different from the default behaviour of \code{write.table}, an empty cell is inserted as the header of row names (equivalent to setting \code{col.names} to \code{NA}
#'
#' @param x a matrix
#' @param file file to be written to
#' @param row.names logical, whether row.names is appended. Default: \code{TRUE}
#' @return NULL
#' @seealso \code{\link{readMatrix}} to read in matrix
#' @examples
#' test.mat <- matrix(rnorm(1000), nrow=10)
#' writeMatrix(test.mat, tempfile())
writeMatrix <- function(x, file, row.names=TRUE) {
  write.table(x, file=file, quote=FALSE, sep="\t",
              row.names=row.names,
              col.names=ifelse(row.names, NA, TRUE),
              dec=".")
}

#' Read in numeric matrix from tab-delimited format written by \code{writeMatrix}
#'
#' @description
#' \code{readMatrix} reads a matrix written by \code{writeMatrix} into a R session
#'
#' @details
#' Default behaviour of \code{read.table} is adapted to the convention used in \code{writeMatrix}
#'
#' @param file file to be read in
#' @param row.names Logical, whether the first column contains row names (should be consistent with the settign in \code{writeMatrix})
#' @param as.matrix Logical, whether the data.frame object should be cast into a matrix
#' @return Matrix when \code{as.matrix} is set to \code{TRUE} and otherwise data.frame
#' @examples
#' test.mat <- matrix(rnorm(1000), nrow=10, dimnames=list(LETTERS[1:10], 1:100))
#' tmpfile <- tempfile()
#' writeMatrix(test.mat, tmpfile)
#' readin.mat <- readMatrix(tmpfile)
#' if(require(ribiosUtils)) identicalMatrix(test.mat, readin.mat)

readMatrix <- function(file, row.names=TRUE, as.matrix=TRUE) {
  if(!row.names) {
    row.names <- NULL
  } else {
    row.names <- 1L
  }
  res <- read.table(file, header=TRUE, sep="\t", quote="",
                    row.names=row.names,
                    dec=".", check.names=FALSE, strip.white=TRUE,
                    comment.char="")
  if(as.matrix) {
    return(as.matrix(res))
  } else {
    return(res)
  }
}

#' Read in data.frame from tab-delimited format written by \code{writeMatrix}
#'
#' \code{readTable} reads a data.frame written by \code{writeMatrix} into a R session
#'
#' @details
#' Default behaviour of \code{read.table} is adapted to the convention used in \code{writeMatrix}
#'
#' @param file file to be read in
#' @param row.names Logical, whether the first column contains row names (should be consistent with the settign in \code{writeMatrix})
#'
#' @return A \code{data.frame} object
#' @examples
#' test.df <- data.frame(Team=c("HSV", "BVB", "VFB"), Score=c(21, 19, 17))
#' tmpfile <- tempfile()
#' writeMatrix(test.df, tmpfile)
#' readin.df <- readTable(tmpfile)
#' stopifnot(identical(as.character(readin.df$Team), c("HSV", "BVB", "VFB")))
#' stopifnot(identical(readin.df$Score, c(21L, 19L, 17L)))

readTable <- function(file, row.names=TRUE) {
    return(readMatrix(file, row.names=row.names, as.matrix=FALSE))
}
