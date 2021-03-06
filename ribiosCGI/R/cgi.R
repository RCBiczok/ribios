#' @useDynLib ribiosCGI, .registration = TRUE
#' @importFrom ribiosUtils assertFile haltifnot
#' @importFrom methods getFunction

#' @export cgiIsCGI
cgiIsCGI <- function() {
  .Call("r_cgiIsCGI")
}

#' @export cgiInit
cgiInit <- function() {
  invisible(.Call("r_cgiInit"))
}

#' Makes it possible to call cgiGetNext(), which will return the first field of the POSTed data, if any
#' 
#' @export cgiGetInit
cgiGetInit <- function()  {
  invisible(.Call("r_cgiGetInit"));
}

#' @export cgiGet2Post
cgiGet2Post <- function() {
  invisible(.Call("r_cgiGet2Post"))
}

#' @export cgiGet2PostReset
cgiGet2PostReset <- function() {
  invisible(.Call("r_cgiGet2PostReset"))
}

#' @export cgiHeader
cgiHeader <- function(header) {
  invisible(.Call("r_cgiHeader",
                  as.character(header)))
}

#' @export cgiSendFile
cgiSendFile <- function(file, header=NULL) {
  assertFile(file <- as.character(file))
  if(!is.null(header)) header <- as.character(header)
  
  invisible(.Call("r_cgiSendFile",
                  file, header));
}

#' @export cgiEncodeWord
cgiEncodeWord <- function(word) {
  .Call("r_cgiEncodeWord", as.character(word));
}

#' @export cgiDecodeWord
cgiDecodeWord <- function(word) {
  .Call("r_cgiDecodeWord", as.character(word));
}

#' @export cgiParams
cgiParams <- function() {
  return(.Call("r_cgiParameters"))
}

#' @export cgiParam
cgiParam <- function(name, ignore.case=FALSE, default=NULL) {
  return(.Call("r_cgiParam", as.character(name), as.logical(ignore.case), default))
}

## Following functions are based on cgiParam
## cgiNumParam: parse numeric CGI paramters

#' @export cgiNumParam
cgiNumParam <- function(name, ignore.case=FALSE, expLen=NULL, default=NULL) {
  x <- cgiParam(name,
                ignore.case=ignore.case, default=NULL)
  if(is.null(x)) return(default)
  x <- strsplit(x, ",| ")[[1]] ## allow comma-sep or plus-sep values
  x <- x[ x != "" ]

  xnum <- suppressWarnings(as.numeric(x))
  isNum <- all(!is.na(xnum))
  if(!is.null(expLen))
    isNum <- isNum && length(x) == expLen
  if(isNum)
    return(xnum)
  else
    return(default)
}

## cgiCateParam/cgiEnumParam: parse categorical variable CGI parameters
#' @export cgiCateParam
#' @export cgiEnumParam
cgiCateParam <- function(name, ignore.case=FALSE,
                         allowed.values=NULL, default=NULL) {
  haltifnot(length(allowed.values)>=1,
            msg="Empty allowed.values is not allowed")
  haltifnot(is.null(default) || default %in% allowed.values,
            msg="The default value must be either NULL or in the allowed.values")
  x <- cgiParam(name, ignore.case=ignore.case, default=default)
  haltifnot(is.null(x) || x %in% allowed.values,
            msg=paste("Allowed values of '", name, "' include\n",
              paste(allowed.values, collapse=", "),
              ".\n The input value '", x ,"' was invalid", sep=""))
  return(x)
}
cgiEnumParam <- cgiCateParam

## cgiStrParam: parse string CGI parameters
#' @export cgiStrParam
cgiStrParam <- function(name, ignore.case=FALSE, default=NULL) {
  x <- cgiParam(name, ignore.case=ignore.case, default=NULL)
  if(is.null(x)) return(default)
  x <- gsub("\"", "", x)
  x <- strsplit(x, " ")[[1]]
  if(length(x)==0) return(default)
  return(x)
}

## cgiLogiParam: parse logical CGI parameters
#' @export cgiLogiParam
cgiLogiParam <- function(name, ignore.case=FALSE, default=FALSE) {
  haltifnot(is.logical(default), msg="Default must be a logical value")
  x <- cgiParam(name, ignore.case=ignore.case, default=default)
  xl <- as.logical(x)
  if(!is.na(xl))  return(xl)
  return(default)
}

## cgiFunParam: parse CGI parameters for R function
#' @export cgiFuncParam
cgiFuncParam <- function(name, ignore.case=FALSE, default=NULL) {
  x <- cgiParam(name, ignore.case=ignore.case, default=NULL)
  if(is.null(x)) return(default)
  if(grepl("function", x)) { ## a user defined function
    fun <- eval(parse(text=x))
  } else {
    fun <- getFunction(x, mustFind=TRUE)
  }
  attr(fun, "label") <- x
  return(fun)
}

## cgiPairParam: parse CGI parameters as key-value pairs
#' @export cgiPairParam
cgiPairParam <- function(name, ignore.case=FALSE,
                         default=NULL,
                         sep=":", collapse="\\+") {
  x <- cgiParam(name, ignore.case=ignore.case, default=NULL)
  if(is.null(x)) return(default)
  x <- strsplit(x, collapse)[[1]]
  if(length(x)==0) return(default)
  sepl <- strsplit(x, sep)
  if(!all(sapply(sepl, length)==2)) {
    badPairs <- sapply(sepl,length)!=2
    warning("Following pairs are not valid and discarded:\n",
            paste(sepl[badPairs],sep=":", collapse=", "))
    sepl <- sepl[!badPairs]
  }
  if(length(sepl)==0) return(default)
  keys <- sapply(sepl, "[[", 1L)
  values <- sapply(sepl, "[[", 2L)
  return(data.frame(keys=keys, values=values))
}
