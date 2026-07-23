#include <gtest/gtest.h>

#include <array>
#include <cstdint>
#include <limits>
#include <octra/random/random.hpp>
#include <vector>

TEST(octra_random, splitmix64_next_is_deterministic) {
  std::uint64_t state = 0;

  EXPECT_EQ(octra::random::splitmix64_next(state), 0xe220a8397b1dcdafULL);
  EXPECT_EQ(octra::random::splitmix64_next(state), 0x6e789e6aa1b965f4ULL);
  EXPECT_EQ(octra::random::splitmix64_next(state), 0x06c45d188009454fULL);
}

TEST(octra_random, splitmix64_runif_stays_in_unit_interval) {
  std::uint64_t state = 123456789ULL;

  for (int i = 0; i < 1024; ++i) {
    const double value = octra::random::splitmix64_runif(state);
    EXPECT_GE(value, 0.0);
    EXPECT_LT(value, 1.0);
  }
}

TEST(octra_random, fill_runif_is_reproducible_for_same_seed) {
  std::array<double, 8> first{};
  std::array<double, 8> second{};

  octra::random::fill_runif(first.data(), first.size(), 42ULL);
  octra::random::fill_runif(second.data(), second.size(), 42ULL);

  EXPECT_EQ(first, second);
}

TEST(octra_random, fill_runif_differs_for_different_seeds) {
  std::array<double, 8> first{};
  std::array<double, 8> second{};

  octra::random::fill_runif(first.data(), first.size(), 1ULL);
  octra::random::fill_runif(second.data(), second.size(), 2ULL);

  EXPECT_NE(first, second);
}

TEST(octra_random, fill_runif_handles_null_and_empty_buffers) {
  std::vector<double> values{1.0, 2.0, 3.0};
  const auto          original = values;

  octra::random::fill_runif(nullptr, values.size(), 7ULL);
  octra::random::fill_runif(values.data(), 0, 7ULL);

  EXPECT_EQ(values, original);
}

TEST(octra_random, splitmix64_runif_seeded_matches_runif) {
  std::uint64_t state = 42ULL;

  EXPECT_EQ(octra::random::splitmix64_runif_seeded(42ULL), octra::random::splitmix64_runif(state));
}

TEST(octra_random, fill_runif_populates_all_values_in_range) {
  std::vector<double> values(4096, std::numeric_limits<double>::quiet_NaN());

  octra::random::fill_runif(values.data(), values.size(), 987654321ULL);

  for (double value : values) {
    EXPECT_GE(value, 0.0);
    EXPECT_LT(value, 1.0);
  }
}
