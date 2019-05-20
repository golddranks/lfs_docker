#!/bin/bash -e

shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

echo "Chapter 3 of the book."
echo "Next, we'll prepare the packages and patches for LFS."

echo "Creating a directory inside the LFS file system to host the package sources."

echo ""
trace_on
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources
trace_off

echo ""
echo "Next, we'll download a list of packages we'll need, and then download the packages themselves."
echo "The list is from http://www.linuxfromscratch.org/lfs/view/stable-systemd/wget-list"
echo ""
trace_on
wget -O - http://www.linuxfromscratch.org/lfs/view/stable-systemd/wget-list | \
sed s/openssl.org/www.openssl.org/g > wget-list
wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
trace_off

echo ""
echo "Let's verify the MD5 sums of the packages."
echo "(http://www.linuxfromscratch.org/lfs/view/stable-systemd/md5sums)"
echo ""

wget http://www.linuxfromscratch.org/lfs/view/stable-systemd/md5sums --directory-prefix=$LFS/sources
pushd $LFS/sources
md5sum -c md5sums
popd

echo ""
echo "We now have downloaded and verified all the packages and patches needed for the build."
echo "(End of chapter 3 of the book.)"
