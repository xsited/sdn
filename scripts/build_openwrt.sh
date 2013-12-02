#!/usr/bin/env bash
#
# update-and-make - Update source code and make the build
echo "Update SVN source..."
svn up
svn info >bin/ar71xx/svninfo.txt
echo "...update feeds..."
./scripts/feeds update -a
echo "...install feeds..."
./scripts/feeds install -a
echo "...make defconfig..."
make defconfig
echo "...make menuconfig..."
make menuconfig
echo "...make world..."
make -j 5
