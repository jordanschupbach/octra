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

#ifdef __cplusplus
extern "C" {
#endif

typedef struct octra_linked_list_node {
  void*                          data;
  struct octra_linked_list_node* next;
} octra_linked_list_node;

typedef struct octra_linked_list {
  octra_linked_list_node* head;
  octra_linked_list_node* tail;
} octra_linked_list;

octra_linked_list* octra_linked_list_alloc();
void               octra_linked_list_free(octra_linked_list* self);
void               octra_linked_list_insert_front(octra_linked_list* self, void* data);
void               octra_linked_list_insert_back(octra_linked_list* self, void* data);
void*              octra_linked_list_find(octra_linked_list* self, void* data);
int                octra_linked_list_size(octra_linked_list* self);
void               octra_linked_list_clear(octra_linked_list* self);
void               octra_linked_list_erase(octra_linked_list* self, int index);
void               octra_linked_list_push_front(octra_linked_list* self, void* data);
void               octra_linked_list_push_back(octra_linked_list* self, void* data);
void               octra_linked_list_pop_back(octra_linked_list* self);
void               octra_linked_list_swap(octra_linked_list* self, int index1, int index2);
void               octra_linked_list_print(octra_linked_list* self, void (*printData)(void*));

octra_linked_list_node* octra_linked_list_next();

#ifdef __cplusplus
};
#endif
