%module octrar

// {{{ core

// {{{ stl
%include <std_shared_ptr.i>
%include <stdint.i>
%include <std_vector.i>
%include <std_string.i>
%include <std_pair.i>

%template(IPair) std::pair<int, int>;
%template(DPair) std::pair<double, double>;
%template(IVector) std::vector<int>;
%template(DVector) std::vector<double>;
%template(SizeVector) std::vector<size_t>;

// }}} stl

// }}} Core

// %{
//   #include "octra/octra.hpp"
// %}
// %include "octra/octra.hpp"
