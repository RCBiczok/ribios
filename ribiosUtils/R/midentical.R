midentical <- function(..., num.eq=TRUE, single.NA=TRUE, 
                       attrib.as.set=TRUE,
                       ignore.bytecode=TRUE, 
                       ignore.environment=FALSE,
                       ignore.srcref=TRUE) {
  li <- list(...)
  if(length(li)==1L) li <- li[[1L]]
  
  stopifnot(length(li)>=2L)
  identical.formals <- names(formals(identical))
  if(!identical(identical.formals,
                c("x", "y", "num.eq", "single.NA",
                  "attrib.as.set",
                  "ignore.bytecode", "ignore.environment", "ignore.srcref"))) {
      stop("formals of identical have changed, please consult the developer")
  }
  call.list <- list(x=li[[1L]], y=li[[2L]],
                    num.eq=num.eq, single.NA=single.NA,
                    attrib.as.set=attrib.as.set,
                    ignore.bytecode=ignore.bytecode,
                    ignore.environment=ignore.environment,
                    ignore.srcref=ignore.srcref)[identical.formals]
  res <- do.call(identical, call.list)
  if(length(li)>2L)
    for(i in 2L:(length(li)-1L)) {
      call.list <- list(x=li[[i]], y=li[[i+1L]],
                        num.eq=num.eq, single.NA=single.NA,
                        attrib.as.set=attrib.as.set,
                        ignore.bytecode=ignore.bytecode,
                        ignore.environment=ignore.environment,
                        ignore.srcref=ignore.srcref)[identical.formals]
      res <- res && do.call(identical, call.list)
      if(!res) return(FALSE)
    }
  return(res)
}
