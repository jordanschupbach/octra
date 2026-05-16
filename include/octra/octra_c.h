#pragma once

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct octra_dpair {
  double first;
  double second;
} octra_dpair;

void octra_hello(void);

/* Writes 3 doubles to `out3` (must point to at least 3 elements). */
void octra_make_dvector(double a, double b, double c, double* out3);

double octra_sum_dvector(const double* values, size_t len);

octra_dpair octra_make_dpair(double a, double b);

double octra_sum_dpair(octra_dpair values);

#ifdef __cplusplus
} /* extern "C" */
#endif

