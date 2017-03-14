#!/bin/bash

###########################################################################
#  Choose your ffmpeg version and your currently-installed iOS SDK version:
#
VERSION="2.0.2"
SDKVERSION="10.2"


echo "install gas-* perl script"
./install-gas.sh

#
#
###########################################################################
#
# Don't change anything under this line!
#
###########################################################################

# No need to change this since xcode build will only compile in the
# necessary bits from the libraries we create
ARCHS="armv7 armv7s i386 x86_64"

DEVELOPER=`xcode-select -print-path`

cd "`dirname \"$0\"`"
REPOROOT=$(pwd)

# Where we'll end up storing things in the end
DEPENDENCYDIR="${REPOROOT}/output" #zhiqiang++
OUTPUTDIR="${DEPENDENCYDIR}/ffmpeg" #zhiqiang++
#mkdir -p ${OUTPUTDIR}/include
#mkdir -p ${OUTPUTDIR}/lib
#mkdir -p ${OUTPUTDIR}/bin

THIRDPARTYDIR="$DEPENDENCYDIR" #zhiqiang++

BUILDDIR="${REPOROOT}/build"
mkdir -p $BUILDDIR

# where we will keep our sources and build from.
SRCDIR="${BUILDDIR}/src"
mkdir -p $SRCDIR
# where we will store intermediary builds
# INTERDIR="${BUILDDIR}/built" #zhiqiang--
INTERDIR="${OUTPUTDIR}/built" #zhiqiang++
mkdir -p $INTERDIR

########################################

cd $SRCDIR

# Exit the script if an error happens
set -e

if [ ! -e "${SRCDIR}/ffmpeg-${VERSION}.tar.bz2" ]; then
	echo "Downloading ffmpeg-${VERSION}.tar.bz2"
    curl -LO http://ffmpeg.org/releases/ffmpeg-${VERSION}.tar.bz2
else
	echo "Using ffmpeg-${VERSION}.tar.bz2"
fi

tar zxf ffmpeg-${VERSION}.tar.bz2 -C $SRCDIR
cd "${SRCDIR}/ffmpeg-${VERSION}"

set +e # don't bail out of bash script if ccache doesn't exist
CCACHE=`which ccache`
if [ $? == "0" ]; then
    echo "Building with ccache: $CCACHE"
    CCACHE="${CCACHE} "
else
    echo "Building without ccache"
    CCACHE=""
fi
set -e # back to regular "bail out on error" mode

for ARCH in ${ARCHS}
do
	if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ];
	then
		PLATFORM="iPhoneSimulator"
        EXTRA_CONFIG="--arch=${ARCH} --disable-asm --enable-cross-compile --target-os=darwin --cpu=${ARCH}"
        EXTRA_CFLAGS="-arch ${ARCH}"
        EXTRA_LDFLAGS="-I${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk/usr/lib -mfpu=neon"
	else
		PLATFORM="iPhoneOS"
        EXTRA_CONFIG="--arch=arm --target-os=darwin --enable-cross-compile --cpu=cortex-a9 --disable-armv5te"
        EXTRA_CFLAGS="-w -arch ${ARCH} -mfpu=neon"
        EXTRA_LDFLAGS="-mfpu=neon"
	fi

	mkdir -p "${INTERDIR}/${ARCH}"

    ./configure --prefix="${INTERDIR}/${ARCH}" \
    --enable-debug=3 \
		--disable-optimizations \
		--disable-stripping \
    --disable-armv6 \
    --disable-armv6t2 \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-iconv \
    --disable-bzlib \
		--enable-libvo-aacenc --enable-version3 \
		--enable-libfdk-aac --enable-nonfree \
		--enable-gpl --enable-libx264 \
    --enable-avresample \
    --sysroot="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk" \
    --cc="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang" \
    --as='/usr/local/bin/gas-preprocessor.pl' \
    --extra-cflags="${EXTRA_CFLAGS} -miphoneos-version-min=${SDKVERSION} -I${OUTPUTDIR}/include -I${THIRDPARTYDIR}/lib_fdkaac/universal/include -I${THIRDPARTYDIR}/lib_x264/universal/include -I${THIRDPARTYDIR}/libvo_aacenc/universal/include" \
    --extra-ldflags="-arch ${ARCH} ${EXTRA_LDFLAGS} -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk -miphoneos-version-min=${SDKVERSION} -L${OUTPUTDIR}/lib -L${THIRDPARTYDIR}/lib_fdkaac/universal/lib -L${THIRDPARTYDIR}/lib_x264/universal/lib -L${THIRDPARTYDIR}/libvo_aacenc/universal/lib" ${EXTRA_CONFIG} \
    --enable-pic \
    --extra-cxxflags="$CPPFLAGS -I${OUTPUTDIR}/include -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"

    make && make install && make clean
	 
done

mkdir -p "${INTERDIR}/universal/lib"

cd "${INTERDIR}/armv7/lib"
for file in *.a
do

cd ${INTERDIR}
xcrun -sdk iphoneos lipo -output universal/lib/$file  -create -arch armv7 armv7/lib/$file -arch armv7s armv7s/lib/$file -arch i386 i386/lib/$file -arch x86_64 x86_64/lib/$file
echo "Universal $file created."

done
cp -r ${INTERDIR}/armv7/include ${INTERDIR}/universal/

echo "Done."



