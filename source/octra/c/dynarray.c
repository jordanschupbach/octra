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

#include "dynarray.h"

#include <memory.h>
#include <stdio.h>

octra_dynarray* octra_dynarray_alloc(
    size_t initial_capacity, // NOLINT
    size_t element_size) {
  octra_dynarray* self = (octra_dynarray*)malloc(sizeof(octra_dynarray)); // NOLINT
  self->data           = malloc(initial_capacity * element_size);
  self->size           = 0;
  self->capacity       = initial_capacity;
  self->elementSize    = element_size;
  return self;
}

void octra_dynarray_reserve(octra_dynarray* self, size_t new_capacity) {
  if (new_capacity > self->capacity) {
    self->data     = (void*)realloc(self->data, new_capacity * self->elementSize);
    self->capacity = new_capacity;
  }
}

void octra_dynarray_push(octra_dynarray* self, void* element) {
  if (self->size >= self->capacity) {
    self->capacity *= 2;
    self->data = realloc(self->data, self->capacity * self->elementSize);
  }

  void* dest = (char*)self->data + self->size * self->elementSize;
  memcpy(dest, element, self->elementSize);
  self->size++;
}

void octra_dynarray_insert(octra_dynarray* self, size_t index, void* element) {
  if (index > self->size) {
    // Invalid index
    return;
  }
  if (self->size >= self->capacity) {
    self->capacity *= 2;
    self->data = realloc(self->data, self->capacity * self->elementSize);
  }
  // Shift elements to make space for the new element
  void*  src         = (char*)self->data + index * self->elementSize;       // NOLINT
  void*  dest        = (char*)self->data + (index + 1) * self->elementSize; // NOLINT
  size_t num_to_move = self->size - index;
  if (num_to_move > 0) {
    memmove(dest, src, num_to_move * self->elementSize);
  }
  // Insert the new element
  memcpy(src, element, self->elementSize);
  self->size++;
}

void octra_dynarray_remove(octra_dynarray* self, size_t index) {
  if (index >= self->size) {
    // Out of bounds
    return;
  }
  // Shift elements to fill the gap
  void*  src       = (char*)self->data + (index + 1) * self->elementSize; // NOLINT
  void*  dest      = (char*)self->data + index * self->elementSize;       // NOLINT
  size_t numToMove = self->size - index - 1;
  if (numToMove > 0) {
    memmove(dest, src, numToMove * self->elementSize);
  }
  self->size--;
}

void* octra_dynarray_get(octra_dynarray* arr, size_t index) {
  if (index >= arr->size) {
    // Out of bounds
    return NULL;
  }
  return (char*)arr->data + index * arr->elementSize; // NOLINT
}

void octra_dynarray_set(octra_dynarray* self, size_t index, void* element) {
  if (index >= self->size) {
    // Out of bounds
    return;
  }
  void* dest = (char*)self->data + index * self->elementSize;
  memcpy(dest, element, self->elementSize);
}

void octra_dynarray_free(octra_dynarray* arr) {
  free(arr->data);
  free(arr);
}

void octra_dynarray_print(octra_dynarray* arr, void (*printFunc)(void*)) {
  for (size_t i = 0; i < arr->size; i++) {
    printFunc((char*)arr->data + i * arr->elementSize);
  }
}

const size_t octra_dynarray_size(octra_dynarray* self) {
  return self->size;
}

void print_int(void* data) {
  printf("%d ", *((int*)data));
}

void print_double(void* data) {
  printf("%f ", *((double*)data));
}

void octra_dynarray_clear(octra_dynarray* self) {
  self->size = 0;
}

void octra_dynarray_sort(
    octra_dynarray* self, // NOLINT
    int (*compareFunc)(const void*, const void*)) {
  qsort(self->data, self->size, self->elementSize, compareFunc);
}

typedef struct {
  octra_dynarray* dynArray;
  size_t          currentIndex;
} octra_dynarray_iterator;

octra_dynarray_iterator* octra_dynarray_iterator_create(octra_dynarray* arr) {
  octra_dynarray_iterator* iter = (octra_dynarray_iterator*)malloc(sizeof(octra_dynarray_iterator));
  iter->dynArray                = arr;
  iter->currentIndex            = 0;
  return iter;
}

void octra_dynarray_iterator_reset(octra_dynarray_iterator* iter) {
  iter->currentIndex = 0;
}

int octra_dynarray_iterator_has_next(octra_dynarray_iterator* iter) {
  return iter->currentIndex < iter->dynArray->size;
}

void* octra_dynarray_iterator_next(octra_dynarray_iterator* iter) {
  if (octra_dynarray_iterator_has_next(iter)) {
    void* data = octra_dynarray_get(iter->dynArray, iter->currentIndex);
    iter->currentIndex++;
    return data;
  }
  return NULL;
}

void octra_dynarray_iterator_free(octra_dynarray_iterator* iter) {
  free(iter);
}
