#!/bin/bash

SDKVERSION="10.2"
LIB_PATH="x264"
ARCHS="i386 x86_64 armv7s armv7"
OUTPUTDIR="../output/lib_x264"

OLD_DEVELOPER_PATH="/Developer"
NEW_DEVELOPER_PATH="/Applications/Xcode.app/Contents/Developer"
# Get the install path
if [ -d "$NEW_DEVELOPER_PATH" ]
then
DEVELOPER="$NEW_DEVELOPER_PATH"
else
DEVELOPER="$OLD_DEVELOPER_PATH"
fi



CurrentPath=$(cd "$(dirname "$0")"; pwd)
LIB_PATH="$CurrentPath/$LIB_PATH"
OUTPUTDIR="$CurrentPath/$OUTPUTDIR"

cd $LIB_PATH

for ARCH in ${ARCHS}
do
#if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64"];
if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ];
then
PLATFORM="iPhoneSimulator"
else
PLATFORM="iPhoneOS"

fi
PLATFORM_SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"
MIN_VERSION_FLAG="-miphoneos-version-min=${SDKVERSION}"
HOST="${ARCH}-apple-darwin"
export CC="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
export CFLAGS="${MIN_VERSION_FLAG} -arch ${ARCH} -I${PLATFORM_SDK}/usr/include"
export LDFLAGS="${MIN_VERSION_FLAG} -arch ${ARCH} -isysroot ${PLATFORM_SDK}"
export LIBS="-L${PLATFORM_SDK}/usr/lib"
export CXXFLAGS="${MIN_VERSION_FLAG} -arch ${ARCH} -I${PLATFORM_SDK}/usr/include"


mkdir -p "${OUTPUTDIR}/${ARCH}"

make clean
echo "** CC=${CC}"
echo "** CFLAGS=${CFLAGS}"
echo "** LDFLAGS=${LDFLAGS}"
echo "** LIBS=${LIBS}"
echo "** CXXFLAGS=${CXXFLAGS}"
./configure --prefix="${OUTPUTDIR}/${ARCH}" --disable-asm --enable-static --host="${HOST}" --with-sysroot="${PLATFORM_SDK}"
make && make install && make clean
done

mkdir -p "${OUTPUTDIR}/universal/lib"

cd "${OUTPUTDIR}/armv7/lib"
for file in *.a
do

cd "${OUTPUTDIR}"
xcrun -sdk iphoneos lipo -output universal/lib/$file  -create -arch armv7 armv7/lib/$file -arch armv7s armv7s/lib/$file -arch i386 i386/lib/$file -arch x86_64 x86_64/lib/$file
echo "Universal $file created."

done
cp -r ${OUTPUTDIR}/armv7/include ${OUTPUTDIR}/universal/

cp -r ${OUTPUTDIR}/universal/lib/ /usr/local/lib

echo "Done."
