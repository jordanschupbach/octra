local ok, mod = pcall(require, "octra")
assert(ok, "failed to require 'octra': " .. tostring(mod))
assert(type(mod) == "table", "expected octra module to be a table")
assert(type(mod.hello) == "function", "expected octra.hello to be a function")

-- Smoke test: call into the native library.
mod.hello()

-- std::vector<double> roundtrip + by-const-ref usage
assert(type(mod.make_dvector) == "function", "expected octra.make_dvector to be a function")
assert(type(mod.sum_dvector) == "function", "expected octra.sum_dvector to be a function")
local v = mod.make_dvector(1.0, 2.0, 3.0)
local sumv = mod.sum_dvector(v)
assert(sumv == 6.0, ("expected sum_dvector=6.0, got %s"):format(tostring(sumv)))

-- std::pair<double,double> roundtrip + by-const-ref usage
assert(type(mod.make_dpair) == "function", "expected octra.make_dpair to be a function")
assert(type(mod.sum_dpair) == "function", "expected octra.sum_dpair to be a function")
local p = mod.make_dpair(1.25, 2.75)
local sump = mod.sum_dpair(p)
assert(sump == 4.0, ("expected sum_dpair=4.0, got %s"):format(tostring(sump)))
