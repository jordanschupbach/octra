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


#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>

struct octra_dynarray {
  void *data;
  size_t size;
  size_t capacity;
  size_t elementSize;
  void* defaultValue;
};

typedef struct octra_dynarray octra_dynarray_t;

octra_dynarray_t *octra_dynarray_alloc(size_t size, size_t capacity, size_t element_size, void* default_value);

void octra_dynarray_reserve(octra_dynarray_t *arr, size_t new_capacity);

void octra_dynarray_push(octra_dynarray_t *arr, void *element);

void octra_dynarray_insert(octra_dynarray_t *self, size_t index, void *element);

void octra_dynarray_remove(octra_dynarray_t *self, size_t index);

void *octra_dynarray_get(octra_dynarray_t *arr, size_t index);

void octra_dynarray_set(octra_dynarray_t *self, size_t index, void *element);

void octra_dynarray_free(octra_dynarray_t *arr);

void octra_dynarray_print(octra_dynarray_t *arr, void (*print_func)(void *));

size_t octra_dynarray_size(octra_dynarray_t *self);


// TODO:  move and rename these
void print_int(void *data);

void print_double(void *data);

void octra_dynarray_clear(octra_dynarray_t *self);

void octra_dynarray_sort(octra_dynarray_t *self, int (*compare_func)(const void *, const void *));

// void octra_fill_runif(octra_dynarray *self, size_t n, double min, double max);

octra_dynarray_t *octra_dynarray_map_alloc(octra_dynarray_t *self, void *(*mapFunc)(void *));

// octra_dynarray_t *octra_dynarray_ewise_sum_alloc(octra_dynarray_t *self, octra_dynarray_t *other);
octra_dynarray_t *octra_dynarray_ewise_prod_alloc(octra_dynarray_t *self, octra_dynarray_t *other);

#ifdef __cplusplus
};
#endif
