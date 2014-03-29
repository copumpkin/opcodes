#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

#include "shim.h"

static int fpf(void *data, const char *fmt, ...) {
  shim_t *p = (shim_t *)data;
  
  va_list args;
  char *buffer = NULL;

  va_start(args, fmt);
  vasprintf(&buffer, fmt, args);
  va_end(args);
  p->cb(buffer);
  free(buffer);

  return 0;
}

size_t shim_decode(disassembler_ftype fn, callback cb, enum bfd_architecture arch, long location, void *buffer, size_t len) {
  shim_t p;
  init_disassemble_info(&p.info, &p, fpf);
  p.cb = cb;
  p.info.application_data = &p;
  p.info.buffer = buffer;
  p.info.buffer_length = len;
  p.info.buffer_vma = 0;
  p.info.arch = arch;
  p.info.mach = 0;

  return fn(location, &p.info);
}
