// NOTE: Supposed to be able to load octrajs from npm package:
// but currently doesnt build the build/Release/octrajs file on install
const octra = require("@octra/octrajs");
// current way to load locally built version:
// const octra = require("./build/Release/octrajs");

octra.hello();
