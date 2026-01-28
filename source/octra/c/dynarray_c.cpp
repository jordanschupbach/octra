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

#include <octra/c/dynarray_c.hpp>
#include <string.h>
#include <stdio.h>

// ----------- Implementation ------------
octra_dynarray_t *octra_dynarray_alloc(
    size_t size,
    size_t capacity,
    size_t element_size,
    void* default_value)
{
  if(size > capacity) {
    capacity = size;
  }
  octra_dynarray_t *self = (octra_dynarray_t *)malloc(sizeof(octra_dynarray_t));
  self->data = malloc(capacity * element_size);
  self->size = 0;
  self->capacity = capacity;
  self->elementSize = element_size;
  self->defaultValue = default_value;
  for(size_t i=0; i<size; i++) {
    octra_dynarray_push(self, default_value);
  }
  return self;
}


/**
 * @brief Reserve up to new capacity
 *
 * Note, I think it wrongly assumes this is larger than current.
 */
void octra_dynarray_reserve(octra_dynarray_t *self, size_t new_capacity) 
{
  if (new_capacity > self->capacity) {
    self->data = (void *)realloc(self->data, new_capacity * self->elementSize);
    self->capacity = new_capacity;
  }
}

/**
 * @brief Push element onto the back of the dynarray
 *
 * If size of dynarray after push exceeds capacity, it first doubles
 * the capacity by reallocating to new memory.
 */
void octra_dynarray_push(octra_dynarray_t *self, void *element) 
{
  if (self->size >= self->capacity) {
    self->capacity *= 2;
    self->data = realloc(self->data, self->capacity * self->elementSize);
  }

  void *dest = (char *)self->data + self->size * self->elementSize;
  memcpy(dest, element, self->elementSize);
  self->size++;
}


/**
 * @brief Insert element at given index.
 *
 * Inserts element at given index. O(n) b/c it needs to move
 * O(n) elements 
 * 
 */
void octra_dynarray_insert(octra_dynarray_t *self, size_t index, void *element) 
{
  if (index > self->size) {
    // Invalid index
    return;
  }
  if (self->size >= self->capacity) {
    self->capacity *= 2;
    self->data = realloc(self->data, self->capacity * self->elementSize);
  }
  // Shift elements to make space for the new element
  void *src = (char *)self->data + index * self->elementSize;        // NOLINT
  void *dest = (char *)self->data + (index + 1) * self->elementSize; // NOLINT
  size_t num_to_move = self->size - index;
  if (num_to_move > 0) {
    memmove(dest, src, num_to_move * self->elementSize);
  }
  // Insert the new element
  memcpy(src, element, self->elementSize);
  self->size++;
}

void octra_dynarray_remove(octra_dynarray_t *self, size_t index) 
{
  if (index >= self->size) {
    // Out of bounds
    return;
  }
  // Shift elements to fill the gap
  void *src = (char *)self->data + (index + 1) * self->elementSize; // NOLINT
  void *dest = (char *)self->data + index * self->elementSize;      // NOLINT
  size_t numToMove = self->size - index - 1;
  if (numToMove > 0) {
    memmove(dest, src, numToMove * self->elementSize);
  }
  self->size--;
}


/**
 * @brief Get element at the idx index (0 based)
 * 
 * @return generic void* at idx index
 */
void *octra_dynarray_get(octra_dynarray_t *arr, size_t idx) 
{
  if (idx >= arr->size) {
    // NOTE: Out of bounds.. How should handle?
    return NULL;
  }
  return (char *)arr->data + idx * arr->elementSize;
}

/**
 * @brief Set element at the idx index to given value
 *
 * Copy occurs, so that the dynarray owns all of its data.
 * 
 * @param self dynarray ptr to set the element for
 * @param idx index to set value to
 * @param element ptr to data to set value as
 */
void octra_dynarray_set(octra_dynarray_t *self, size_t index, void *element) 
{
  if (index >= self->size) {
    // Out of bounds
    return;
  }
  void *dest = (char *)self->data + index * self->elementSize;
  memcpy(dest, element, self->elementSize);
}

void octra_dynarray_free(octra_dynarray_t *arr)
{
  free(arr->data);
  free(arr);
}

void octra_dynarray_print(octra_dynarray_t *arr, void (*printFunc)(void *))
{
  for (size_t i = 0; i < arr->size; i++) {
    printFunc((char *)arr->data + i * arr->elementSize);
  }
  printf("\n");
}

size_t octra_dynarray_size(octra_dynarray_t *self) { return self->size; }

void print_int(void *data) { printf("%d ", *((int *)data)); }

void print_double(void *data) { printf("%f ", *((double *)data)); }

void octra_dynarray_clear(octra_dynarray_t *self) { self->size = 0; }

void octra_dynarray_sort(octra_dynarray_t *self, // NOLINT
                      int (*compareFunc)(const void *, const void *)) {
  qsort(self->data, self->size, self->elementSize, compareFunc);
}

typedef struct {
  octra_dynarray_t *dynArray;
  size_t currentIndex;
} octra_dynarray_iterator;

octra_dynarray_iterator *octra_dynarray_iterator_create(octra_dynarray_t *arr) {
  octra_dynarray_iterator *iter =
      (octra_dynarray_iterator *)malloc(sizeof(octra_dynarray_iterator));
  iter->dynArray = arr;
  iter->currentIndex = 0;
  return iter;
}

void octra_dynarray_iterator_reset(octra_dynarray_iterator *iter) {
  iter->currentIndex = 0;
}

int octra_dynarray_iterator_has_next(octra_dynarray_iterator *iter) {
  return iter->currentIndex < iter->dynArray->size;
}

void *octra_dynarray_iterator_next(octra_dynarray_iterator *iter) {
  if (octra_dynarray_iterator_has_next(iter)) {
    void *data = octra_dynarray_get(iter->dynArray, iter->currentIndex);
    iter->currentIndex++;
    return data;
  }
  return NULL;
}

void octra_dynarray_iterator_free(octra_dynarray_iterator *iter) { free(iter); }

octra_dynarray_t *octra_dynarray_map_alloc(octra_dynarray_t *self,
                                   void *(*mapFunc)(void *)) {
  octra_dynarray_t *ret = octra_dynarray_alloc(0, self->capacity, self->elementSize, self->defaultValue);

  for (size_t i = 0; i < octra_dynarray_size(self); i++) {
    void *mapped_element = mapFunc(octra_dynarray_get(self, i));
    octra_dynarray_push(ret, mapped_element);
  }

  return ret;
}

// octra_dynarray_t *octra_dynarray_ewise_sum_alloc(octra_dynarray_t *self,
//                                          octra_dynarray_t *other) {
//   if (octra_dynarray_size(self) != octra_dynarray_size(other)) {
//     // Error
//     return NULL;
//   }
// 
//   octra_dynarray_t *ret = octra_dynarray_alloc(0, self->capacity, self->elementSize, self->defaultValue);
// 
//   for (size_t i = 0; i < octra_dynarray_size(self); i++) {
//     double sum;
//     sum = *((double *)octra_dynarray_get(self, i)) +
//           *((double *)octra_dynarray_get(other, i));
//     octra_dynarray_push(ret, &sum);
//   }
// 
//   return ret;
// }

octra_dynarray_t *octra_dynarray_ewise_prod_alloc(octra_dynarray_t *self,
                                          octra_dynarray_t *other) {
  if (octra_dynarray_size(self) != octra_dynarray_size(other)) {
    // Error
    return NULL;
  }

  octra_dynarray_t *ret = octra_dynarray_alloc(0, self->capacity, self->elementSize, self->defaultValue);

  for (size_t i = 0; i < octra_dynarray_size(self); i++) {
    double prod;
    prod = *((double *)octra_dynarray_get(self, i)) *
           *((double *)octra_dynarray_get(other, i));
    octra_dynarray_push(ret, &prod);
  }
  return ret;
}
