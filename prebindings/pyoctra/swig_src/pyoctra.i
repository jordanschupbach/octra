%module(docstring="These are the python bindings to the octra library") octra

%include "std_shared_ptr.i"
%include "stdint.i"
%include "std_vector.i"
%include "std_string.i"
%include "std_pair.i"
%include "std_unordered_set.i"

%template(IPair) std::pair<int, int>;
%template(IVec) std::vector<int>;
%template(IIVec) std::vector<std::vector<int>>;
%template(SizeVec) std::vector<size_t>;
%template(DVec) std::vector<double>;
%template(DDVec) std::vector<std::vector<double>>;

%{
  #include "../octra/cxx/dynarray.hpp"
%}
%include "../octra/cxx/dynarray.hpp"

%extend octra::DynArray {

  std::string __repr__() {
    std::string ret = $self->to_string();
    return ret;
  }

  std::string __str__() {
    std::string ret = $self->to_string();
    return ret;
  }

  void __setitem__(size_t index, double value) {
    (*self)[index] = value;
  }

  double __getitem__(size_t index) {
    return (*self)[index];
  }
}


%template(DynArrayInt) octra::DynArray<int>;
%template(DynArrayDouble) octra::DynArray<double>;
