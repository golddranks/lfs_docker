#!/bin/bash

shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

echo "Chapter 4 of the book."
echo "Next, we'll prepare do some final preparations to be able to build the"
echo "temporary system which we'll need for building LFS."
echo ""
echo "Creating a directory for temporary tools and symlinking it to the host system."
echo ""

trace_on
mkdir -v $LFS/tools
ln -sv $LFS/tools /
trace_off

echo ""
echo "Creating an unprivileged user for building the temporary system,"
echo "and giving it permissions over the tools and sources directories."
echo ""

trace_on
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
chown -v lfs $LFS/tools
chown -v lfs $LFS/sources
trace_off

echo ""
echo "Creating environment settings for the new user."
echo ""

trace_on
sudo -u lfs -s <<'EOF2'

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF

EOF2
trace_off

echo ""
echo "We now have an unprivileged user for building the temporary system."
echo "(End of chapter 4 of the book.)"
