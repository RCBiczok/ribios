#include "ribios_cgi.h"

#include "format.h"
#include "log.h"
#include "http.h"
#include "html.h"

#include "cgi.h"

SEXP r_cgiIsCGI() {
  return ScalarLogical(cgiIsCGI());
}

SEXP r_cgiInit() {
  cgiInit();
  return R_NilValue;
}

SEXP r_cgiGetInit() {
  cgiGetInit();
  return R_NilValue;
}

SEXP r_cgiGet2Post() {
  char *res=cgiGet2Post();
  if(res) {
    return mkString(res);
  }
  return R_NilValue;
}

SEXP r_cgiGet2PostReset() {
  cgiGet2PostReset();
  return R_NilValue;
}

SEXP r_cgiHeader(SEXP header) {
  char *fn=cStr(header);
  cgiHeader(fn);
  return R_NilValue;
}

SEXP r_cgiParameters() {
  int i;
  char *name;
  Stringa value=stringCreate(16);
  Texta keys=textCreate(8);
  Texta values=textCreate(8);
  SEXP r_keys, r_values;

  cgiGetInit();

  while(name = cgiGetNext(value)) {
    textAdd(keys, name);
    textAdd(values, string(value));
  }
  
  int n=arrayMax(keys);
  PROTECT(r_keys=allocVector(STRSXP, n));
  PROTECT(r_values=allocVector(STRSXP, n));
  for(i=0; i<n; ++i) {
    SET_STRING_ELT(r_keys, i, mkChar(textItem(keys,i)));
    SET_STRING_ELT(r_values, i, mkChar(textItem(values,i)));
  }
  setNames(r_values, r_keys);

  stringDestroy(value);
  textDestroy(keys);
  textDestroy(values);
  UNPROTECT(2);
  return(r_values);
}

int myStrEqual(char* a, char* b) {
  return strEqual(a, b);
}
int myStrCaseEqual(char* a, char* b) {
  return strCaseEqual(a, b);
}

SEXP r_cgiParam(SEXP r_param, SEXP ignore_case, SEXP r_default) {
  if(r_param == R_NilValue) return(R_NilValue);

  char* name;
  Stringa value=stringCreate(16);

  char *param=cStr(r_param);
  char *str=NULL;

  SEXP res;
  int (*fPtr)(char*, char*);
  fPtr=cBool(ignore_case) ? &myStrCaseEqual : &myStrEqual;

  cgiGetInit();

  while(name = cgiGetNext(value)) {
    if((*fPtr)(name, param)) {
      str=hlr_strdup(string(value));
      break;
    }
  }
  
  stringDestroy(value);

  if(str) {
    return mkString(str);
  } else {
    return r_default;
  }
}

SEXP r_cgiEncodeWord(SEXP word) {
  static Stringa value;
  stringCreateOnce(value, 16);
  static char *s;
  
  s=cStr(word);
  cgiEncodeWord(s, value);
  return mkString(string(value));
}

SEXP r_cgiDecodeWord(SEXP word) {
  static Stringa value;
  stringCreateOnce(value, 16);
  
  stringCpy(value, cStr(word));
  cgiDecodeWord(value);
  return mkString(string(value));
}
