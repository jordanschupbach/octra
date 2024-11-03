#include <octra/c/linked_list.h>

#include <stdio.h>
#include <stdlib.h>

octra_linked_list* octra_linked_list_alloc() {
  octra_linked_list* list = (octra_linked_list*)malloc(sizeof(octra_linked_list));
  printf("Allocating linked list");
  list->head              = NULL;
  list->tail              = NULL;
  return list;
}

// void octra_linked_list_free(octra_linked_list* self) {
//   octra_linked_list_node* current = self->head;
//   while (current != NULL) {
//     octra_linked_list_node* next = current->next;
//     free(current);
//     current = next;
//   }
//   free(self);
// }

//  void octra_linked_list_insert_front(octra_linked_list* self, void* data) {
//    octra_linked_list_node* newoctra_linked_list_node =
//        (octra_linked_list_node*)malloc(sizeof(octra_linked_list_node));
//    newoctra_linked_list_node->data = data;
//    newoctra_linked_list_node->next = self->head;
//    self->head                      = newoctra_linked_list_node;
//    if (self->tail == NULL) {
//      self->tail = newoctra_linked_list_node;
//    }
//  }
//
//  void octra_linked_list_insert_back(octra_linked_list* self, void* data) {
//    octra_linked_list_node* newoctra_linked_list_node =
//        (octra_linked_list_node*)malloc(sizeof(octra_linked_list_node));
//    newoctra_linked_list_node->data = data;
//    newoctra_linked_list_node->next = NULL;
//
//    if (self->tail == NULL) {
//      self->head = newoctra_linked_list_node;
//      self->tail = newoctra_linked_list_node;
//
//    } else {
//      self->tail->next = newoctra_linked_list_node;
//      self->tail       = newoctra_linked_list_node;
//    }
//  }
//
//  void* octra_linked_list_find(octra_linked_list* self, void* data) {
//    octra_linked_list_node* current = self->head;
//    while (current != NULL) {
//      if (current->data == data) {
//        return current->data;
//      }
//      current = current->next;
//    }
//    return NULL;
//  }
//
//  int octra_linked_list_size(octra_linked_list* self) {
//    int                     count   = 0;
//    octra_linked_list_node* current = self->head;
//    while (current != NULL) {
//      count++;
//      current = current->next;
//    }
//    return count;
//  }
//
//  void octra_linked_list_clear(octra_linked_list* self) {
//    octra_linked_list_node* current = self->head;
//    while (current != NULL) {
//      octra_linked_list_node* next = current->next;
//      free(current);
//      current = next;
//    }
//    self->head = NULL;
//    self->tail = NULL;
//  }
//
//  void octra_linked_list_erase(octra_linked_list* self, int index) {
//    if (index < 0 || index >= octra_linked_list_size(self)) {
//      return;
//    }
//
//    if (index == 0) {
//      octra_linked_list_node* temp = self->head;
//      self->head                   = self->head->next;
//      free(temp);
//      return;
//    }
//
//    octra_linked_list_node* current = self->head;
//
//    for (int i = 0; i < index - 1; i++) {
//      current = current->next;
//    }
//
//    octra_linked_list_node* temp = current->next;
//
//    current->next = temp->next;
//
//    free(temp);
//  }
//
//  void octra_linked_list_push_front(octra_linked_list* self, void* data) {
//    octra_linked_list_insert_front(self, data);
//  }
//
//  void octra_linked_list_push_back(octra_linked_list* self, void* data) {
//    octra_linked_list_insert_back(self, data);
//  }
//
//  void octra_linked_list_pop_back(octra_linked_list* self) {
//    if (self->head == NULL) {
//      return;
//    }
//
//    if (self->head->next == NULL) {
//      free(self->head);
//      self->head = NULL;
//      self->tail = NULL;
//      return;
//    }
//
//    octra_linked_list_node* current = self->head;
//    while (current->next->next != NULL) {
//      current = current->next;
//    }
//
//    free(current->next);
//
//    current->next = NULL;
//  }
//
//  void octra_linked_list_swap(octra_linked_list* self, int index1, int index2) {
//    // To be implemented based on the specific requirements
//  }
//
//  void octra_linked_list_print(octra_linked_list* self, void (*printData)(void*)) {
//    octra_linked_list_node* current = self->head;
//
//    while (current != NULL) {
//      printData(current->data);
//      printf(" -> ");
//      current = current->next;
//    }
//
//    printf("NULL\n");
//  }
//
//  /**
//   * @brief Next element in the linked list
//   *
//   * @param self The linked list.
//   * @param node The node prior to the next element.
//   * @return A pointer to the next node in the list
//   */
//  octra_linked_list_node* octra_linked_list_next(
//      octra_linked_list*      self,
//      octra_linked_list_node* node) {
//    return node->next;
//  }
//
//  // /**
//  //  * @brief Previous element in the list
//  //  *
//  //  * @param self The linked list.
//  //  * @param node The node prior to the next element.
//  //  * @return A pointer to the next node in the list
//  //  */
//  // octra_linked_list_node* octra_linked_list_previous(
//  //     octra_linked_list*      self,
//  //     octra_linked_list_node* node) {
//  //   return node->next;
//  // }
