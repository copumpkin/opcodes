#!/bin/sh

VERSION=2.24
BINUTILS=binutils-$VERSION
OPCODES=opcodes-$VERSION

mkdir tmp
cd tmp

curl -O http://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.gz
tar xf $BINUTILS.tar.gz

mkdir $OPCODES

mv $BINUTILS/opcodes $OPCODES
mv $BINUTILS/libiberty $OPCODES
mv $BINUTILS/include $OPCODES
mv $BINUTILS/bfd $OPCODES

find $OPCODES -name "*.po" -delete -or -name "*.pot" -delete -or -name "*.gmo" -delete -or -name "ChangeLog*" -delete -or -name "*.texi" -delete

mv $BINUTILS/configure $OPCODES
mv $BINUTILS/move-if-change $OPCODES
mv $BINUTILS/install-sh $OPCODES
mv $BINUTILS/config.sub $OPCODES
mv $BINUTILS/config.guess $OPCODES
mv $BINUTILS/Makefile.in $OPCODES
mv $BINUTILS/COPYING $OPCODES
mv $BINUTILS/MAINTAINERS $OPCODES

cp -r $OPCODES ../cbits/

cd ..
rm -rf tmp
