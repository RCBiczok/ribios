#include <R_ext/Rdynload.h>
#include "ribios_cgi.h"
#include "cgi.h"
#include "cgiSendFile.h"

static const R_CallMethodDef callMethods[] = {
  CALLMETHOD_DEF(r_cgiIsCGI, 0),
  CALLMETHOD_DEF(r_cgiInit, 0),
  CALLMETHOD_DEF(r_cgiGet2Post, 0),
  CALLMETHOD_DEF(r_cgiGet2PostReset, 0),
  CALLMETHOD_DEF(r_cgiHeader, 1),
  CALLMETHOD_DEF(r_cgiSendFile, 2),
  CALLMETHOD_DEF(r_cgiParameters, 0),
  CALLMETHOD_DEF(r_cgiParam, 3),
  CALLMETHOD_DEF(r_cgiEncodeWord, 1),
  CALLMETHOD_DEF(r_cgiDecodeWord, 1),
  {NULL, NULL, 0}
};

void R_init_ribiosCGI(DllInfo *info) {
  R_registerRoutines(info, NULL, callMethods, NULL, NULL);
}
