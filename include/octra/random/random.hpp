#pragma once

#include <cstddef>
#include <cstdint>

namespace octra::random {

/// Advances a SplitMix64 state and returns the next 64-bit value.
std::uint64_t splitmix64_next(std::uint64_t& state) noexcept;

/// Returns a uniform variate in [0, 1) derived from SplitMix64.
double splitmix64_runif(std::uint64_t& state) noexcept;

/// Fills `data[0..size)` with uniforms in [0, 1) using SplitMix64 seeded by `seed`.
void fill_runif(double* data, std::size_t size, std::uint64_t seed) noexcept;

} // namespace octra::random
