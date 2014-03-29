#ifndef __SHIM_H_
#define __SHIM_H_

#include "config.h"
#include <dis-asm.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>


typedef void (*callback)(const char *);

typedef struct shim_t {
  disassemble_info info;
  callback cb;
} shim_t;

size_t shim_decode(disassembler_ftype, callback, enum bfd_architecture, long, void *, size_t);

#endif // __SHIM_H_