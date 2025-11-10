#define LOGGER
#include <octra/c/debug.hpp>

#include <stdio.h>

int main(int argc, char* argv[]) {
  printf("\n");
  OCTRA_LOG(OCTRA_INFO, "Logging an INFO message");
  OCTRA_LOG(OCTRA_ERROR, "Logging an ERROR message");
  return 0;
}
