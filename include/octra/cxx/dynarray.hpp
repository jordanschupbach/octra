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

// #include <bits/types/struct_FILE.h>
// #include <cstddef>
#include <vector>

extern "C" {
#include <octra/c/dynarray.h>
}

#include <iostream>
#include <string>

namespace octra {

template <typename T> class DynArray {
public:
  DynArray();
  explicit DynArray(size_t n);
  virtual ~DynArray();
  void reserve(size_t capacity);
  void push_back(const T &elmt);
  void push_back(T &&elmt);
  // dm_dynarray_t *data() const;
  void clear();
  size_t capacity() const;
  size_t size() const;
  T &operator[](size_t index);
  T operator[](size_t index) const;
  std::string to_string() const;
  void print();
  // DynArray(const DynArray<T> &other);
  // DynArray(DynArray<T> &&other);
  std::vector<T> to_vec() const;

  // // Copy assignment operator (was commented out)
  // DynArray<T> &operator=(const DynArray<T> other) {
  //   std::swap(*this, other);
  //   return *this;
  // }

  // // Move assignment operator
  // DynArray<T> &operator=(DynArray<T> &&other) noexcept {
  //   std::swap(_data, other._data);
  //   return *this;
  // }

  // explicit DynArray(dm_dynarray *data) : _data(data) {}

  // friend std::ostream &operator<<(std::ostream &os, const DynArray<T> &obj) {
  //   os << obj.to_string();
  //   return os;
  // }

private:
  octra_dynarray_t *_data;
};


// template <typename T> dm_dynarray *DynArray<T>::data() const { return _data; }

template <typename T> std::vector<T> DynArray<T>::to_vec() const {
  std::vector<T> ret;
  for (size_t i = 0; i < size(); i++) {
    ret.push_back((*this)[i]);
  }
  return ret;
}

/**
 * @brief Get capacity of the dynarray.
 *
 * @return capacity of the dynarray (size_t)
 */
template <typename T> size_t DynArray<T>::capacity() const {
  return this->_data->capacity;
}


/**
 * @brief Default constructor
 *
 * This function allocates a dynamic array with a size of 1.
 *
 * @return An instantiated dynarray of the given type.
 */
template <typename T> DynArray<T>::DynArray() {
  T defaultval = T();
  _data = octra_dynarray_alloc(0, 1, sizeof(T), (void*) &defaultval);
}

/**
 * @brief Reserves (reallocs) memory for the dynamic array
 *
 * This function allocates the dynamic array with the given capacity.
 */
template <typename T> void DynArray<T>::reserve(size_t capacity) {
  octra_dynarray_reserve(_data, capacity);
}

/**
 * @brief Print out the dynamic array to the console.
 *
 * This function prints the dynamic array to console (stdout).
 */
template <typename T> void DynArray<T>::print() {
  for (size_t i = 0; i < size(); i++) {
    std::cout << (*this)[i] << " ";
  }
}

// /**
//  * @brief Copy constructor
//  *
//  * Deep copies dynarray (rhs) into a new dynarray (lhs).
//  */
// template <typename T>
// DynArray<T>::DynArray(const DynArray<T> &other) {
//   auto default_val = T();
//   _data = octra_dynarray_alloc(other.size(), other.capacity(), sizeof(T), &default_val);
//   for (size_t i = 0; i < other.size(); ++i) {
//     T *element = static_cast<T *>(octra_dynarray_get(other._data, i));
//     push_back(*element);
//   }
// }

// /**
//  * @brief Move constructor
//  *
//  * Moves dynarray (rhs) into a new dynarray (lhs), invalidating the old.
//  */
// template <typename T>
// DynArray<T>::DynArray(DynArray<T> &&other) : _data(other._data) {
//   other._data = nullptr;
// }

/**
 * @brief Size constructor
 *
 * Constructs dynarray with a given capacity.
 */
template <typename T> DynArray<T>::DynArray(size_t n) {
  auto defaultval = T();
  _data = octra_dynarray_alloc(n, n, sizeof(T), (void*) &defaultval);
  for (size_t i = 0; i < n; i++) {
    octra_dynarray_set(this->_data, i, (void*) (T*) &defaultval);
  }
}

template <typename T> DynArray<T>::~DynArray() { octra_dynarray_free(_data); }

template <typename T> T DynArray<T>::operator[](size_t index) const {
  if (index < size()) {
    auto elmt = octra_dynarray_get(_data, index);
    return *(reinterpret_cast<T *>(elmt));
  }
  throw std::out_of_range("Index out of range");
}

template <typename T> T &DynArray<T>::operator[](size_t index) {
  if (index < size()) {
    auto elmt = octra_dynarray_get(_data, index);
    return *(reinterpret_cast<T *>(elmt));
  }
  throw std::out_of_range("Index out of range");
}

template <typename T> size_t DynArray<T>::size() const {
  return octra_dynarray_size(_data);
}

template <typename T> void DynArray<T>::push_back(const T &elmt) {
  octra_dynarray_push(_data, const_cast<void *>(static_cast<const void *>(&elmt)));
}

template <typename T> void DynArray<T>::clear() { octra_dynarray_clear(_data); }

template <typename T> void DynArray<T>::push_back(T &&elmt) {
  octra_dynarray_push(_data, reinterpret_cast<void *>(&elmt));
}

template <typename T> std::string DynArray<T>::to_string() const {
  std::string ret = "[ ";
  for (size_t i = 0; i < size() - 1; i++) {
    ret += std::to_string((*this)[i]) + ", ";
  }
  ret += std::to_string((*this)[size() - 1]) + " ";
  ret += "]";
  return ret;
}


} // namespace octra
