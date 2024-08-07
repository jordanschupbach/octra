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

extern "C" {
#include "../c/dynarray.h"
}

#include <iostream>
#include <utility>

namespace octra {
template<typename T>
class DynArray {
 public:
  explicit DynArray(size_t n);
  virtual ~DynArray();
  void   push_back(const T& elmt);
  void   push_back(T&& elmt);
  void   clear();
  size_t size() const;
  T&     operator[](size_t index);
  T      operator[](size_t index) const;

  DynArray(const DynArray<T>& other);
  DynArray(DynArray<T>&& other);

  // Copy assignment operator
  DynArray<T>& operator=(DynArray<T> other) {
    std::swap(*this, other);
    return *this;
  }

  // Move assignment operator
  DynArray<T>& operator=(DynArray<T>&& other) noexcept {
    std::swap(_data, other._data);
    return *this;
  }

  friend std::ostream& operator<<(std::ostream& os, const DynArray<T>& obj) {
    for (size_t i = 0; i < obj.size(); i++) {
      os << obj[i] << " ";
    }
    os << std::endl;
    return os;
  }

 private:
  octra_dynarray* _data;
};

template<typename T>
DynArray<T>::DynArray(const DynArray<T>& other)
    : _data(octra_dynarray_alloc(other.size(), sizeof(T))) {
  for (size_t i = 0; i < other.size(); ++i) {
    T* element = static_cast<T*>(octra_dynarray_get(other._data, i));
    push_back(*element);
  }
}

template<typename T>
DynArray<T>::DynArray(DynArray<T>&& other) : _data(other._data) {
  other._data = nullptr;
}

template<typename T>
DynArray<T>::DynArray(size_t n) {
  _data = octra_dynarray_alloc(n, sizeof(T));
}

template<typename T>
DynArray<T>::~DynArray() {
  octra_dynarray_free(_data);
}

template<typename T>
T& DynArray<T>::operator[](size_t index) {
  if (index < size()) {
    auto elmt = octra_dynarray_get(_data, index);
    return *((T*)elmt); // NOLINT
  }
  throw std::out_of_range("Index out of range");
}

template<typename T>
T DynArray<T>::operator[](size_t index) const {
  if (index < size()) {
    auto elmt = octra_dynarray_get(_data, index);
    return *((T*)(elmt));
  }
  throw std::out_of_range("Index out of range");
}

template<typename T>
size_t DynArray<T>::size() const {
  return octra_dynarray_size(_data);
}

template<typename T>
void DynArray<T>::push_back(const T& elmt) {
  octra_dynarray_push(_data, (void*)(&elmt));
}

template<typename T>
void DynArray<T>::push_back(T&& elmt) {
  // TODO: need to invalidate pointer...?
  octra_dynarray_push(_data, (void*)(&elmt));
}

template<typename T>
void DynArray<T>::clear() {
  octra_dynarray_clear(_data);
}

} // namespace octra
