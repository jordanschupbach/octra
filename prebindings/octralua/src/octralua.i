%module octra

%include <stdint.i>
%include <std_vector.i>
%include <std_pair.i>

%template(DPair) std::pair<double, double>;
%template(DVector) std::vector<double>;

%{
#include "octra/octra.hpp"
%}

%include <octra/octra.hpp>

