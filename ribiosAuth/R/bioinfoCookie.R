#' Get bioinfo cookie
#'
#' @param force.refresh Logical. If set to \code{TRUE}, cached cookie is not used and a new cookie is fetched.
#' @return A character string representing the cookie
#' @details   User name is obtained by querying the operating system.
#'
#' The function first checks whether a cached cookie exists: if so, it
#' simply returns it without querying the webserver; otherwise, it
#' fetches a newly backed cookie from the webserver.
#' @note the package has to authenticate itself with the server baking the cookie. The username and password is set in src/get_bioinfo_cookie_pw.h. This should be configured before installation.   
#' @author Jitao David Zhang, Detlef Wolf, and Clemens Brogers
#' @examples
#' \dontrun{bioinfoCookie()}
#' @export
#' @useDynLib ribiosAuth get_bioinfo_cookie
bioinfoCookie <- function(force.refresh=FALSE) {
  ## examine environment
  CACHE_VAR <- "RIBIOS_BIOINFO_COOKIE"
  biocookie <- unname(Sys.getenv("RIBIOS_BIOINFO_COOKIE"))
  if(!identical(biocookie, "") && !force.refresh) return(biocookie)

  ## no existing bioinfo cookie
  out <- .Call("get_bioinfo_cookie")
  rawCookie <- grep("^Set-Cookie",strsplit(out, "\r\n")[[1]],value=TRUE)
  if(length(rawCookie)<1)
    stop("Failed to get cookie, please contact the developer. Debugging information: ", out)
  hot.cookie <- gsub("Set-Cookie: ", "", rawCookie[[1]])
  Sys.setenv("RIBIOS_BIOINFO_COOKIE"=hot.cookie)
  return(hot.cookie)
}
