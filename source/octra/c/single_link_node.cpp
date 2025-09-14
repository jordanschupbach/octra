#include <octra/c/single_link_node.hpp>

octra_sl_node_t* octra_sl_node_create(void* data, size_t data_size) {
  octra_sl_node_t* node = (octra_sl_node_t*)malloc(sizeof(octra_sl_node_t));
  if (node == NULL) {
    return NULL;
  }
  node->data      = data;
  node->data_size = data_size;
  node->next      = NULL;
  return node;
}

void octra_sl_node_destroy(octra_sl_node_t* node) {
  free(node);
}

void octra_sl_node_set_next(octra_sl_node_t* node, octra_sl_node_t* next) {
  node->next = next;
}

octra_sl_node_t* octra_sl_node_get_next(octra_sl_node_t* node) {
  return node->next;
}

void octra_sl_node_set_data(octra_sl_node_t* node, void* data, size_t data_size) {
  node->data      = data;
  node->data_size = data_size;
}

void* octra_sl_node_get_data(octra_sl_node_t* node) {
  return node->data;
}

size_t octra_sl_node_get_data_size(octra_sl_node_t* node) {
  return node->data_size;
}

// void octra_sl_node_set_data_size(octra_sl_node_t* node, size_t data_size) {
//   node->data_size = data_size;
// }
