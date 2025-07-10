
#include <stdlib.h>
#include <stdio.h>
#include <octra/c/dynarray.h>

typedef struct {
    void *key;
    void *value;
} octra_hmap_entry;

typedef struct {
    octra_dynarray_t *entry_pairs;
    void (*print_function)(void *);
    unsigned int (*hash_function)(void *);
    int (*comparison_function)(void *, void *);
  size_t size;
} octra_flat_hmap_t;

octra_flat_hmap_t *octra_flat_hmap_alloc(void (*print_function)(void *),
                                         unsigned int (*hash_function)(void *),
                                         int (*comparison_function)(void *, void *),
                                         size_t initial_capacity) {
    octra_flat_hmap_t *hmap = (octra_flat_hmap_t*) malloc(sizeof(octra_flat_hmap_t));
    hmap->entry_pairs = octra_dynarray_alloc(0, initial_capacity, sizeof(octra_hmap_entry), NULL);
    hmap->print_function = print_function;
    hmap->hash_function = hash_function;
    hmap->comparison_function = comparison_function;
    hmap->size = 0;
    // Initialize all key-value pairs to null initially
    for (size_t i = 0; i < initial_capacity; i++) {
        octra_hmap_entry entry = { .key = NULL, .value = NULL };
        octra_dynarray_push(hmap->entry_pairs, &entry);
    }

    return hmap;
}

void *octra_flat_hmap_find(octra_flat_hmap_t *self, void *key) {
    for (size_t i = 0; i < octra_dynarray_size(self->entry_pairs); i++) {
        octra_hmap_entry *entry = (octra_hmap_entry*) octra_dynarray_get(self->entry_pairs, i);
        if (entry->key && self->comparison_function(entry->key, key) == 0) {
            return entry->value;
        }
    }
    return NULL;
}

void *octra_flat_hmap_insert(octra_flat_hmap_t *self, void *key, void *value) {
    for (size_t i = 0; i < octra_dynarray_size(self->entry_pairs); i++) {
        octra_hmap_entry *entry = (octra_hmap_entry*) octra_dynarray_get(self->entry_pairs, i);
        if (entry->key == NULL || (self->comparison_function(entry->key, key) == 0)) {
            entry->key = key;
            entry->value = value;
            self->size = self->size + 1;
            return value;
        }
    }
    // Handle the case when there are no empty slots available
    // You may need to resize the dynamic array or handle this situation differently
    return NULL;
}

void *octra_flat_hmap_remove(octra_flat_hmap_t *self, void *key){
    for (size_t i = 0; i < octra_dynarray_size(self->entry_pairs); i++) {
        octra_hmap_entry *entry = (octra_hmap_entry*) octra_dynarray_get(self->entry_pairs, i);
        if (self->comparison_function(entry->key, key) == 0) {
            octra_dynarray_remove(self->entry_pairs, i);
            self->size = self->size + 1;
            return entry->value;
        }
    }
    self->size -= 1;
    return NULL;
}

size_t octra_flat_hmap_size(octra_flat_hmap_t *self){
  return self->size;
}

void octra_flat_hmap_clear(octra_flat_hmap_t *self){
    octra_dynarray_clear(self->entry_pairs);
}

void print_key_value_pair(void *data);

unsigned int hash_int(void *key);

int compare_int(void *key1, void *key2);

int main() {
    octra_flat_hmap_t *hmap = octra_flat_hmap_alloc(print_key_value_pair, hash_int, compare_int, 16);

    int key1 = 5;
    int value1 = 50;
    octra_flat_hmap_insert(hmap, &key1, &value1);

    int key2 = 10;
    int value2 = 100;
    octra_flat_hmap_insert(hmap, &key2, &value2);

    int key3 = 5;
    int *result = (int *)octra_flat_hmap_find(hmap, &key3);
    if (result) {
        printf("Value found: %d\n", *result);
    } else {
        printf("Value not found for key: %d\n", key3);
    }

    // Remove the entry for key1
    octra_flat_hmap_remove(hmap, &key1);
    printf("HashMap size: %lu\n", octra_flat_hmap_size(hmap));
    octra_flat_hmap_clear(hmap);
    octra_dynarray_free(hmap->entry_pairs);
    free(hmap);

    return 0;
}

void print_key_value_pair(void *data) {
    octra_hmap_entry *entry = (octra_hmap_entry *)data;
    printf("Key: %d, Value: %d\n", *((int *)(entry->key)), *((int *)(entry->value)));
}

unsigned int hash_int(void *key) {
    // Simple hash function for integers
    return *((int *)key);
}

int compare_int(void *key1, void *key2) {
    // Comparison function for integers
    return *((int *)key1) - *((int *)key2);
}
