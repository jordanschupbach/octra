#include <gtest/gtest.h>
#include <octra/cxx/dynarray.hpp>

// extern "C" {
//   #include <octra/c/dynarray.h>
// }

TEST(octra_dynarray, alloc) {
  octra_dynarray_t* x = octra_dynarray_alloc(0, 10, sizeof(int), (void*) 0);
  ASSERT_EQ(0, octra_dynarray_size(x));
  int a = 0;
  int b = 2;
  int c = 8;
  octra_dynarray_push(x, (void*) &a);
  octra_dynarray_push(x, (void*) &b);
  octra_dynarray_push(x, (void*) &c);
  // dm_dynarray_print(x, print_int);
  ASSERT_EQ(3, octra_dynarray_size(x));
}

TEST(DynArray, construct) {
  octra::DynArray<int> x;
  ASSERT_EQ(0, x.size());
  ASSERT_EQ(1, x.capacity());
}

