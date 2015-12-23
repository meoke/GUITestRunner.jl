# GUITestRunner

[![Build Status](https://travis-ci.org/meoke/GUITestRunner.jl.svg?branch=master)](https://travis-ci.org/meoke/GUITestRunner.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/48rq1qu2hetxyalw?svg=true)](https://ci.appveyor.com/project/gdziadkiewicz/guitestrunner-jl)

`GUITestRunner.jl` is a Julia standalone GUI for `TestRunner.jl` package based on `Tk.jl`. It is designed to display tests defined in `FactCheck.jl` and run them. 

MIT Licensed - see LICENSE.md

**Installation**: `julia> Pkg.clone("https://github.com/meoke/GUITestRunner.jl.git")` 

### Usage
Just call
`julia> GUITestRunner.start_test_runner()`

