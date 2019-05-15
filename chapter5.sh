#!/bin/bash

echo "Chapter 5 of the book."
echo "Next, we finally build the temporary system which we'll need for building LFS."
echo ""
echo "If you only care about building the final system, you can just autopilot"
echo "over building this temporary system, but if you are interested in"
echo "bootstrapping and cross-compiling, be sure to read the introduction and"
echo "technical notes of chapter 5 and the build instructions until the"
echo "second pass compilation of GCC; the compilation method and the technical"
echo "hurdles to overcome might prove very interesting."
echo ""

echo ""
echo "Logging in the unprivileged lfs user and building the temporary tools."

WORKDIR="$PWD"

set -x
cd $LFS/sources
sudo -u lfs $WORKDIR/build_temporary.sh
