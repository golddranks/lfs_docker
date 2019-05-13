#!/bin/bash

shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

echo ""
echo "This script clears the boring parts of building a LFS system."
echo "It configures the host environment (chapter 2), downloads the packages (chaper 3),"
echo "doing the final preparations of the host system (chapter 4)"
echo "and constructs the temporary system (chapter 5) that serves as the platform"
echo "to build the LFS system itself."
echo ""
echo "The temporary system is built because we don't want to build the LFS binaries"
echo "using the host system tools: they might be basically anything, varying from"
echo "user to user, so the end result isn't reliable and reproduceable."
echo "(Of course, they are reproduceable as we are using Docker, but that's not what"
echo "the original authors of the book had in mind.)"
echo ""
echo "We will build the temporary system using the host system tools, but we'll"
echo "boostrap, building the core tools second time using the tools built first time"
echo "to make the builds reproduceable and minimise the effects host system tools might"
echo "have to our tooling."
echo ""
echo "The first thing we do is create a partition for the LFS system. For ease,"
echo "we'll build a virtual filesystem."
echo ""
echo "Creating an image for a virtual file system."
echo "The book suggests 6 GiB as a minimum size, but let's build a 7 GiB partition"
echo "as I have hit the size limits before."
echo "7 GiB with 4096 byte block size is 1835008 blocks."
echo ""
trace_on
dd if=/dev/zero of=lfs-image count=1835008 bs=4096
trace_off

echo ""
echo "Creating an ext4 file system inside the image."
echo ""
trace_on
mkfs -v -t ext4 lfs-image
trace_off

echo ""
echo "Mounting the image to $LFS"
echo ""

trace_on
mount -v -t ext4 lfs-image $LFS
trace_off

echo ""
echo "This concludes configuring the host system for building the temporary system,"
echo "to, in turn, build LFS."
echo "(End of chapter 2 of the book.)"
