local octra = require("octra")
octra.hello()

local v = octra.make_dvector(1.0, 2.0, 3.0)
print("sum_dvector:", octra.sum_dvector(v))

local p = octra.make_dpair(1.25, 2.75)
print("sum_dpair:", octra.sum_dpair(p))
