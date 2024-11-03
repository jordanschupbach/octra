#include <gtest/gtest.h>

TEST(Hello, World) {
  const char* hello = "Hello, World!";
  ASSERT_STREQ("Hello, World!", hello);
}

