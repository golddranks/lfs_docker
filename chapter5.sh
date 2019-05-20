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
set +x

echo ""
echo "Stripping debug symbols and deleted unneeded files."

set -x

strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}
find /tools/{lib,libexec} -name \*.la -delete

set +x
echo "Changing ownership of $LFS/tools back to root."
set -x
chown -R root:root $LFS/tools

set +x
echo "We have this much empty space in $LFS:"

df -h $LFS

echo ""
echo "We have now successfully built the temporary system."
echo "(End of chapter 5 of the book.)"
