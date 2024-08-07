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

#include <stdlib.h>

typedef struct {
  void*  data;
  size_t size;
  size_t capacity;
  size_t elementSize;
} octra_dynarray;

octra_dynarray* octra_dynarray_alloc(size_t initial_capacity, size_t element_size);

void octra_dynarray_reserve(octra_dynarray* arr, size_t newCapacity);

void octra_dynarray_push(octra_dynarray* arr, void* element);

void octra_dynarray_insert(octra_dynarray* self, size_t index, void* element);

void octra_dynarray_remove(octra_dynarray* self, size_t index);

void* octra_dynarray_get(octra_dynarray* arr, size_t index);

void octra_dynarray_set(octra_dynarray* self, size_t index, void* element);

void octra_dynarray_free(octra_dynarray* arr);

void octra_dynarray_print(octra_dynarray* arr, void (*printFunc)(void*));

const size_t octra_dynarray_size(octra_dynarray* self);

void print_int(void* data);
void print_double(void* data);

void octra_dynarray_clear(octra_dynarray* self);

void octra_dynarray_sort(octra_dynarray* self, int (*compareFunc)(const void*, const void*));
