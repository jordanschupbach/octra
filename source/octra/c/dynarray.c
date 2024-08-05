
#include <octra/c/dynarray.h>

// typedef struct {
//   int *data;
//   size_t size;
//   size_t capacity;
// } octra_dynarray;

// typedef struct {
//   int *data;
//   size_t size;
//   size_t capacity;
// } octra_dynarray;

octra_dynarray *octra_dynarray_alloc(size_t size) {
  octra_dynarray *arr = (octra_dynarray *)malloc(sizeof(octra_dynarray) * size);
  if (arr == NULL) {
    return NULL; // Memory allocation failed
  }
  arr->data = NULL;
  arr->size = 0;
  arr->capacity = size;
  return arr;
}

void freeDynamicArray(octra_dynarray *arr) {
  if (arr != NULL) {
    free(arr->data);
    free(arr);
  }
}

void addToDynamicArray(octra_dynarray *arr, int value) {
  // Implement the function to add elements to the dynamic array here
}
