#!/bin/bash
set -ev
if [[ -a .git/shallow ]]; then
   git fetch --unshallow
fi
julia -e 'Pkg.clone("git://github.com/gdziadkiewicz/TestRunner.jl.git")'
if [[ $TRAVIS_OS_NAME != "osx" ]]; then
   xvfb-run julia -e 'Pkg.clone(pwd()); Pkg.build("GUITestRunner"); Pkg.test("GUITestRunner"; coverage=true)'
else
   julia -e 'Pkg.clone(pwd()); Pkg.build("GUITestRunner"); Pkg.test("GUITestRunner"; coverage=true)'
fi
