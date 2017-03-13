#!/bin/bash

DEST=`pwd`/build/ffmpeg && rm -rf $DEST
SOURCE=`pwd`/ffmpeg

#=================GET FFMPEG CODE=====================
if [ -d ffmpeg ]; then
  cd ffmpeg
else
  git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
  cd ffmpeg
fi
#=====================================================

#git reset --hard
#git clean -f -d
#git checkout `cat ../ffmpeg-version`
#[ $PIPESTATUS == 0 ] || exit 1
#git log --pretty=format:%H -1 > ../ffmpeg-version



#====================TOOLCHAIN========================
TOOLCHAIN_32=/tmp/dtp_32
SYSROOT_32=$TOOLCHAIN_32/sysroot/
$ANDROID_NDK/build/tools/make-standalone-toolchain.sh --platform=android-19 --arch=arm --install-dir=$TOOLCHAIN_32

TOOLCHAIN_64=/tmp/dtp_64
SYSROOT_64=$TOOLCHAIN_64/sysroot/
$ANDROID_NDK/build/tools/make-standalone-toolchain.sh --platform=android-21 --toolchain=aarch64-linux-android-4.9 --install-dir=$TOOLCHAIN_64

export PATH=$TOOLCHAIN_32/bin:$PATH
export PATH=$TOOLCHAIN_64/bin:$PATH
#=====================================================

FF_CFG_FLAGS=
EXTRA_CFLAGS=
EXTRA_LDFLAGS=

CFLAGS="-O3 -Wall -pipe \
    -std=c99 \
    -ffast-math \
    -fstrict-aliasing -Werror=strict-aliasing \
    -Wno-psabi -Wa,--noexecstack \
    -DANDROID -DNDEBUG"

FFMPEG_FLAGS="
  --enable-shared \
  --disable-symver \
  --disable-doc \
  --disable-ffplay \
  --disable-ffmpeg \
  --disable-ffprobe \
  --disable-ffserver \
  --disable-avdevice \
  --disable-encoders \
  --disable-muxers \
  --disable-devices \
  --enable-protocols  \
  --enable-parsers \
  --enable-demuxers \
  --enable-decoders \
  --enable-bsfs \
  --enable-jni \
  --enable-mediacodec \
  --enable-network \
  --enable-swscale  \
  --disable-demuxer=sbg \
  --disable-asm \
  --enable-version3"


#for version in neon armv7 vfp armv6 armv8; do
for version in armv7 armv8; do

  cd $SOURCE
  make clean
  make distclean

  case $version in
    armv7)
      FF_CFG_FLAGS="--arch=arm --cpu=cortex-a8"
      FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-neon"
      FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-thumb"
      FF_CROSS_PREFIX=arm-linux-androideabi
      
      EXTRA_CFLAGS="-march=armv7-a -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb"
      EXTRA_LDFLAGS="-Wl,--fix-cortex-a8" 
      ;;
    armv8)
      FF_CFG_FLAGS="--arch=aarch64"
      FF_CROSS_PREFIX=aarch64-linux-android
      
      EXTRA_CFLAGS=""
      EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"
      ;;
    *)
      EXTRA_CFLAGS=""
      EXTRA_LDFLAGS=""
      ;;
  esac

  PREFIX="$DEST/$version" && mkdir -p $PREFIX
  FF_CFG_FLAGS="$FF_CFG_FLAGS $FFMPEG_FLAGS";
  FF_CFG_FLAGS="$FF_CFG_FLAGS --prefix=$PREFIX"
  FF_CFG_FLAGS="$FF_CFG_FLAGS --cross-prefix=${FF_CROSS_PREFIX}-"
  FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-cross-compile"
  FF_CFG_FLAGS="$FF_CFG_FLAGS --target-os=linux"


  export CC="{$FF_CROSS_PREFIX}-gcc"
  export LD="{$FF_CROSS_PREFIX}-ld"
  export AR="{$FF_CROSS_PREFIX}-ar"
  export STRIP="{$FF_CROSS_PREFIX}-strip"

  ./configure $FF_CFG_FLAGS --extra-cflags="$CFLAGS $EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS" | tee $PREFIX/configuration.txt
  cp config.* $PREFIX
  [ $PIPESTATUS == 0 ] || exit 1

  make -j32 || exit 1
  make install || exit 1

  #$AR rcs $PREFIX/libffmpeg.a libavutil/*.o libavcodec/*.o libavformat/*.o libswresample/*.o libswscale/*.o  
  #arm-linux-androideabi-strip --strip-unneeded $PREFIX/libffmpeg.a

done
