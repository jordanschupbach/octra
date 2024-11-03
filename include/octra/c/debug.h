// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.
//
// In jurisdictions that recognize copyright laws, the author or authors
// of this software dedicate any and all copyright interest in the
// software to the public domain. We make this dedication for the benefit
// of the public at large and to the detriment of our heirs and
// successors. We intend this dedication to be an overt act of
// relinquishment in perpetuity of all present and future rights to this
// software under copyright law.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// For more information, please refer to <http://unlicense.org/>

#pragma once


#include <time.h> // NOLINT

#define ANSI_COLOR_RED "\x1b[31m"
#define ANSI_COLOR_YELLOW "\x1b[33m"
#define ANSI_COLOR_GREEN "\x1b[32m"
#define ANSI_COLOR_BLUE "\x1b[34m"
#define ANSI_COLOR_CYAN "\x1b[36m"
#define ANSI_COLOR_RESET "\x1b[0m"

#ifdef LOGGER
typedef enum {
  OCTRA_FATAL,
  OCTRA_ERROR,
  OCTRA_WARN,
  OCTRA_INFO,
  OCTRA_DEBUG,
  OCTRA_TRACE
} OctraLogLevel;

#define OCTRA_LOG(level, msg)                                               \
  do {                                                                      \
    time_t    t  = time(NULL);                                              \
    struct tm tm = *localtime(&t);                                          \
    printf(                                                                 \
        "%04d-%02d-%02d %02d:%02d:%02d ",                                   \
        tm.tm_year + 1900,                                                  \
        tm.tm_mon + 1,                                                      \
        tm.tm_mday,                                                         \
        tm.tm_hour,                                                         \
        tm.tm_min,                                                          \
        tm.tm_sec);                                                         \
    if (level == OCTRA_FATAL)                                               \
      printf(ANSI_COLOR_RED "[FATAL] " ANSI_COLOR_RESET "\n%s\n\n", msg);   \
    else if (level == OCTRA_ERROR)                                          \
      printf(ANSI_COLOR_RED "[ERROR] " ANSI_COLOR_RESET "\n%s\n\n", msg);   \
    else if (level == OCTRA_WARN)                                           \
      printf(ANSI_COLOR_YELLOW "[WARN] " ANSI_COLOR_RESET "\n%s\n\n", msg); \
    else if (level == OCTRA_INFO)                                           \
      printf(ANSI_COLOR_GREEN "[INFO] " ANSI_COLOR_RESET "\n%s\n\n", msg);  \
    else if (level == OCTRA_DEBUG)                                          \
      printf(ANSI_COLOR_BLUE "[DEBUG] " ANSI_COLOR_RESET "\n%s\n\n", msg);  \
    else if (level == OCTRA_TRACE)                                          \
      printf(ANSI_COLOR_CYAN "[TRACE] " ANSI_COLOR_RESET "\n%s\n\n", msg);  \
    else                                                                    \
      printf("%s\n", msg);                                                  \
  } while (0)
#endif
