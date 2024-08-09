export const helloWorld = function () {
  console.log("Hello, world!");
};

var example = import("./build/Release/octrajs");
x = new example.DynArray(10);
x.set(0, 1.1);
console.log(x.get(0));
