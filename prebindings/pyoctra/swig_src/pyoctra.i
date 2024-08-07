%module pyoctra

%{
  #include "../octra/cxx/dynarray.hpp"
%}


%include "../octra/cxx/dynarray.hpp"

%template(DynArrayInt) octra::DynArray<int>;
%template(DynArrayDouble) octra::DynArray<double>;
