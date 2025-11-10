
%module joctra

%include <std_string.i>

%{
  #include "octra/cxx/dynarray.hpp"
%}

%include "octra/cxx/dynarray.hpp"


%template(DynArray) octra::DynArray<double>;
%template(DynArrayInt) octra::DynArray<int>;

%{
  #include "octra/cxx/circle.hpp"
%}

%include "octra/cxx/circle.hpp"

