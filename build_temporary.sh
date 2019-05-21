#!/bin/bash -e

shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

echo "Sourcing .bashrc and printing environment"

source $HOME/.bashrc
env

echo ""
echo "Installing binutils-2.32 - first pass"

trace_on

tar -xvf binutils-2.32.tar.xz
pushd binutils-2.32
mkdir -v build
cd       build
../configure --prefix=/tools            \
             --with-sysroot=$LFS        \
             --with-lib-path=/tools/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror
make
case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac
make install
popd
rm -rf binutils-2.32

trace_off



echo ""
echo "Installing gcc-8.2.0 - first pass"

trace_on

tar -xvf gcc-8.2.0.tar.xz
pushd gcc-8.2.0
tar -xf ../mpfr-4.0.2.tar.xz
mv -v mpfr-4.0.2 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc


for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
cd       build

../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libmpx                               \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make
make install
popd
rm -rf gcc-8.2.0

trace_off



echo ""
echo "Installing linux-4.20.12 API Headers"

trace_on

tar -xvf linux-4.20.12.tar.xz
pushd linux-4.20.12
make mrproper

make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include

popd
rm -rf linux-4.20.12

trace_off



echo ""
echo "Installing glibc-2.29"

trace_on

tar -xvf glibc-2.29.tar.xz
pushd glibc-2.29

mkdir -v build
cd       build

../configure                             \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=/tools/include

make
make install

echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools' | grep "[Requesting program interpreter: /tools/lib64/ld-linux-x86-64.so.2]"
rm -v dummy.c a.out

popd
rm -rf glibc-2.29

trace_off



echo ""
echo "Installing libstdc++"

trace_on

tar -xvf gcc-8.2.0.tar.xz
pushd gcc-8.2.0

mkdir -v build
cd       build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/8.2.0

make
make install

popd
rm -rf gcc-8.2.0

trace_off



echo ""
echo "Installing binutils-2.32 - second pass"

trace_on

tar -xvf binutils-2.32.tar.xz
pushd binutils-2.32

mkdir -v build
cd       build

CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../configure                   \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot

make
make install

make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin

popd
rm -rf binutils-2.32

trace_off



echo ""
echo "Installing gcc-8.2.0 - second pass"

trace_on

tar -xvf gcc-8.2.0.tar.xz
pushd gcc-8.2.0

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

tar -xf ../mpfr-4.0.2.tar.xz
mv -v mpfr-4.0.2 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc


for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

mkdir -v build
cd       build

CC=$LFS_TGT-gcc                                    \
CXX=$LFS_TGT-g++                                   \
AR=$LFS_TGT-ar                                     \
RANLIB=$LFS_TGT-ranlib                             \
../configure                                       \
    --prefix=/tools                                \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --enable-languages=c,c++                       \
    --disable-libstdcxx-pch                        \
    --disable-multilib                             \
    --disable-bootstrap                            \
    --disable-libgomp

make
make install
ln -sv gcc /tools/bin/cc

echo 'int main(){}' > dummy.c
cc dummy.c
readelf -l a.out | grep ': /tools' | grep "[Requesting program interpreter: /tools/lib64/ld-linux-x86-64.so.2]"
rm -v dummy.c a.out

popd
rm -rf gcc-8.2.0

trace_off




echo ""
echo "Installing tcl-8.6.9"

trace_on

tar -xvf tcl8.6.9-src.tar.gz
pushd tcl8.6.9

cd unix
./configure --prefix=/tools

make
make install
chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh

popd
rm -rf tcl8.6.9

trace_off



echo ""
echo "Installing expect-5.45.4"

trace_on

tar -xvf expect5.45.4.tar.gz
pushd expect5.45.4

cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure

./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include

make
make SCRIPTS="" install

popd
rm -rf expect5.45.4

trace_off



echo ""
echo "Installing DejaGNU-1.6.2"

trace_on

tar -xvf dejagnu-1.6.2.tar.gz
pushd dejagnu-1.6.2

./configure --prefix=/tools
make install
make check

popd
rm -rf dejagnu-1.6.2

trace_off



echo ""
echo "Installing M4-1.4.18"

trace_on

tar -xvf m4-1.4.18.tar.xz
pushd m4-1.4.18

sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

./configure --prefix=/tools
make
make install

popd
rm -rf m4-1.4.18

trace_off



echo ""
echo "Installing Ncurses-6.1"

trace_on

tar -xvf ncurses-6.1.tar.gz
pushd ncurses-6.1

sed -i s/mawk// configure

./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite
make
make install
ln -s libncursesw.so /tools/lib/libncurses.so

popd
rm -rf ncurses-6.1

trace_off



echo ""
echo "Installing Bash-5.0"

trace_on

tar -xvf bash-5.0.tar.gz
pushd bash-5.0

./configure --prefix=/tools --without-bash-malloc

make
make install
ln -sv bash /tools/bin/sh

popd
rm -rf bash-5.0

trace_off



echo ""
echo "Installing Bison-3.3.2"

trace_on

tar -xvf bison-3.3.2.tar.xz
pushd bison-3.3.2

./configure --prefix=/tools

make
make install

popd
rm -rf bison-3.3.2

trace_off



echo ""
echo "Installing Bzip2-1.0.6"

trace_on

tar -xvf bzip2-1.0.6.tar.gz
pushd bzip2-1.0.6

make
make PREFIX=/tools install

popd
rm -rf bzip2-1.0.6

trace_off



echo ""
echo "Installing Coreutils-8.30"

trace_on

tar -xvf coreutils-8.30.tar.xz
pushd coreutils-8.30

./configure --prefix=/tools --enable-install-program=hostname
make
make install

popd
rm -rf coreutils-8.30

trace_off

echo ""
echo "Installing Diffutils-3.7"

trace_on

tar -xvf diffutils-3.7.tar.xz
pushd diffutils-3.7

./configure --prefix=/tools
make
make install

popd
rm -rf diffutils-3.7

trace_off



echo ""
echo "Installing File-5.36"

trace_on

tar -xvf file-5.36.tar.gz
pushd file-5.36

./configure --prefix=/tools
make
make install

popd
rm -rf file-5.36

trace_off



echo ""
echo "Installing Findutils-4.6.0"

trace_on

tar -xvf findutils-4.6.0.tar.gz
pushd findutils-4.6.0

sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h

./configure --prefix=/tools
make
make install

popd
rm -rf findutils-4.6.0

trace_off



echo ""
echo "Installing Gawk-4.2.1"

trace_on

tar -xvf gawk-4.2.1.tar.xz
pushd gawk-4.2.1

./configure --prefix=/tools
make
make install

popd
rm -rf gawk-4.2.1

trace_off



echo ""
echo "Installing Gettext-0.19.8.1"

trace_on

tar -xvf gettext-0.19.8.1.tar.xz
pushd gettext-0.19.8.1

cd gettext-tools
EMACS="no" ./configure --prefix=/tools --disable-shared

make -C gnulib-lib
make -C intl pluralx.c
make -C src msgfmt
make -C src msgmerge
make -C src xgettext

cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin

popd
rm -rf gettext-0.19.8.1

trace_off



echo ""
echo "Installing Grep-3.3"

trace_on

tar -xvf grep-3.3.tar.xz
pushd grep-3.3

./configure --prefix=/tools
make
make install

popd
rm -rf grep-3.3

trace_off



echo ""
echo "Installing Gzip-1.10"

trace_on

tar -xvf gzip-1.10.tar.xz
pushd gzip-1.10

./configure --prefix=/tools
make
make install

popd
rm -rf gzip-1.10

trace_off



echo ""
echo "Installing Make-4.2.1"

trace_on

tar -xvf make-4.2.1.tar.bz2
pushd make-4.2.1

sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
./configure --prefix=/tools --without-guile
make
make install

popd
rm -rf make-4.2.1

trace_off



echo ""
echo "Installing Patch-2.7.6"

trace_on

tar -xvf patch-2.7.6.tar.xz
pushd patch-2.7.6

./configure --prefix=/tools
make
make install

popd
rm -rf patch-2.7.6

trace_off



echo ""
echo "Installing Perl-5.28.1"

trace_on

tar -xvf perl-5.28.1.tar.xz
pushd perl-5.28.1

sh Configure -des -Dprefix=/tools -Dlibs=-lm -Uloclibpth -Ulocincpth
make

cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.28.1
cp -Rv lib/* /tools/lib/perl5/5.28.1

popd
rm -rf perl-5.28.1

trace_off



echo ""
echo "Installing Python-3.7.2"

trace_on

tar -xvf Python-3.7.2.tar.xz
pushd Python-3.7.2

sed -i '/def add_multiarch_paths/a \        return' setup.py
./configure --prefix=/tools --without-ensurepip

make
make install

popd
rm -rf Python-3.7.2

trace_off



echo ""
echo "Installing Sed-4.7"

trace_on

tar -xvf sed-4.7.tar.xz
pushd sed-4.7

./configure --prefix=/tools
make
make install

popd
rm -rf sed-4.7

trace_off



echo ""
echo "Installing Tar-1.31"

trace_on

tar -xvf tar-1.31.tar.xz
pushd tar-1.31

./configure --prefix=/tools
make
make install

popd
rm -rf tar-1.31

trace_off



echo ""
echo "Installing Texinfo-6.5"

trace_on

tar -xvf texinfo-6.5.tar.xz
pushd texinfo-6.5

./configure --prefix=/tools
make
make install

popd
rm -rf texinfo-6.5

trace_off



echo ""
echo "Installing Util-linux-2.33.1"

trace_on

tar -xvf util-linux-2.33.1.tar.xz
pushd util-linux-2.33.1

./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            --without-ncurses              \
            PKG_CONFIG=""
make
make install

popd
rm -rf util-linux-2.33.1

trace_off



echo ""
echo "Installing Xz-5.2.4"

trace_on

tar -xvf xz-5.2.4.tar.xz
pushd xz-5.2.4

./configure --prefix=/tools
make
make install

popd
rm -rf xz-5.2.4

trace_off


echo ""
echo ""
echo "Builds are done!"
