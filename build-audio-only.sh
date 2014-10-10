#!/bin/bash

DEST=`pwd`/build/ffmpeg && rm -rf $DEST
SOURCE=`pwd`/ffmpeg

if [ -d ffmpeg ]; then
  cd ffmpeg
else
  git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
  cd ffmpeg
fi

git reset --hard
git clean -f -d
git checkout `cat ../ffmpeg-version`
[ $PIPESTATUS == 0 ] || exit 1

git log --pretty=format:%H -1 > ../ffmpeg-version

TOOLCHAIN=/tmp/vplayer
SYSROOT=$TOOLCHAIN/sysroot/
$ANDROID_NDK/build/tools/make-standalone-toolchain.sh --platform=android-14 --install-dir=$TOOLCHAIN

export PATH=$TOOLCHAIN/bin:$PATH
export CC="ccache arm-linux-androideabi-gcc"
export LD=arm-linux-androideabi-ld
export AR=arm-linux-androideabi-ar

CFLAGS="-O3 -Wall -mthumb -pipe -fpic -fasm \
  -finline-limit=300 -ffast-math \
  -fstrict-aliasing -Werror=strict-aliasing \
  -fmodulo-sched -fmodulo-sched-allow-regmoves \
  -Wno-psabi -Wa,--noexecstack \
  -D__ARM_ARCH_5__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5TE__ \
  -DANDROID -DNDEBUG"

FFMPEG_FLAGS="--target-os=linux \
  --arch=arm \
  --enable-cross-compile \
  --cross-prefix=arm-linux-androideabi- \
  --enable-shared \
  --enable-static \
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
  --disable-everything \
  --enable-protocol=file  \
  --enable-demuxer=aac \
  --enable-demuxer=ac3 \
  --enable-demuxer=ape \
  --enable-demuxer=amr \
  --enable-demuxer=dts \
  --enable-demuxer=eac3 \
  --enable-demuxer=flac \
  --enable-demuxer=g722 \
  --enable-demuxer=g729 \
  --enable-demuxer=latm \
  --enable-demuxer=ogg \
  --enable-demuxer=wav \
  --enable-demuxer=pcm_laww \
  --enable-demuxer=pcm_f32be \
  --enable-demuxer=pcm_f32le \
  --enable-demuxer=pcm_f64be \
  --enable-demuxer=pcm_f64le \
  --enable-demuxer=pcm_mulaw \
  --enable-demuxer=pcm_s16be \
  --enable-demuxer=pcm_s16le \
  --enable-demuxer=pcm_s24be \
  --enable-demuxer=pcm_s24le \
  --enable-demuxer=pcm_s32be \
  --enable-demuxer=pcm_s32le \
  --enable-demuxer=pcm_s8 \
  --enable-demuxer=pcm_u16be \
  --enable-demuxer=pcm_u16le \
  --enable-demuxer=pcm_u24be \
  --enable-demuxer=pcm_u24le \
  --enable-demuxer=pcm_u32be \
  --enable-demuxer=pcm_u32le \
  --enable-demuxer=pcm_u8 \
  --enable-demuxer=mp3 \
  --enable-demuxer=mov \
  --enable-demuxer=rm \
  --enable-decoder=aac \
  --enable-decoder=aac_latm \
  --enable-decoder=ac3 \
  --enable-decoder=ac3_fixed \
  --enable-decoder=adpcm_4xm \
  --enable-decoder=adpcm_adx \
  --enable-decoder=adpcm_afc \
  --enable-decoder=adpcm_ct \
  --enable-decoder=adpcm_dtk \
  --enable-decoder=adpcm_ea \
  --enable-decoder=adpcm_ea_maxis_xa \
  --enable-decoder=adpcm_ea_r1 \
  --enable-decoder=adpcm_ea_r2 \
  --enable-decoder=adpcm_ea_r3 \
  --enable-decoder=adpcm_ea_xas \
  --enable-decoder=adpcm_g722 \
  --enable-decoder=adpcm_g726 \
  --enable-decoder=adpcm_g726le \
  --enable-decoder=adpcm_ima_amv \
  --enable-decoder=adpcm_ima_apc \
  --enable-decoder=adpcm_ima_dk3 \
  --enable-decoder=adpcm_ima_dk4 \
  --enable-decoder=adpcm_ima_ea_eacs \
  --enable-decoder=adpcm_ima_ea_sead \
  --enable-decoder=adpcm_ima_iss \
  --enable-decoder=adpcm_ima_oki \
  --enable-decoder=adpcm_ima_qt \
  --enable-decoder=adpcm_ima_rad \
  --enable-decoder=adpcm_ima_smjpeg \
  --enable-decoder=adpcm_ima_wav \
  --enable-decoder=wav_pack \
  --enable-decoder=adpcm_ima_ws \
  --enable-decoder=adpcm_ms \
  --enable-decoder=adpcm_sbpro_2 \
  --enable-decoder=adpcm_sbpro_3 \
  --enable-decoder=adpcm_sbpro_4 \
  --enable-decoder=adpcm_swf \
  --enable-decoder=adpcm_thp \
  --enable-decoder=adpcm_vima \
  --enable-decoder=adpcm_xa \
  --enable-decoder=adpcm_yamaha \
  --enable-decoder=alac \
  --enable-decoder=amrnb \
  --enable-decoder=amrwb \
  --enable-decoder=ape \
  --enable-decoder=mp3adu \
  --enable-decoder=mp3adufloat \
  --enable-decoder=mp3float \
  --enable-decoder=mp3on4 \
  --enable-decoder=mp3on4float \
  --enable-decoder=paf_audio \
  --enable-decoder=pcm_alaw \
  --enable-decoder=pcm_bluray \
  --enable-decoder=pcm_dvd \
  --enable-decoder=pcm_f32be \
  --enable-decoder=pcm_f32le \
  --enable-decoder=pcm_f64be \
  --enable-decoder=pcm_f64le \
  --enable-decoder=pcm_lxf \
  --enable-decoder=pcm_mulaw \
  --enable-decoder=pcm_s16be \
  --enable-decoder=pcm_s16be_planar \
  --enable-decoder=pcm_s16le \
  --enable-decoder=pcm_s16le_planar \
  --enable-decoder=pcm_s24be \
  --enable-decoder=pcm_s24daud \
  --enable-decoder=pcm_s24le \
  --enable-decoder=pcm_s24le_planar \
  --enable-decoder=pcm_s32be \
  --enable-decoder=pcm_s32le \
  --enable-decoder=pcm_s32le_planar \
  --enable-decoder=pcm_s8 \
  --enable-decoder=pcm_s8_planar \
  --enable-decoder=pcm_u16be \
  --enable-decoder=pcm_u16le \
  --enable-decoder=pcm_u24be \
  --enable-decoder=pcm_u24le \
  --enable-decoder=bmv_audio \
  --enable-decoder=vorbis \
  --enable-decoder=cook \
  --enable-decoder=dsicinaudio \
  --enable-decoder=eac3 \
  --enable-decoder=flac \
  --enable-decoder=g723_1 \
  --enable-decoder=g729 \
  --enable-decoder=pcm_u32be \
  --enable-decoder=pcm_u32le \
  --enable-decoder=pcm_u8 \
  --enable-decoder=pcm_zork \
  --enable-decoder=gsm_ms \
  --enable-decoder=interplay_dpcm \
  --enable-decoder=mp1 \
  --enable-decoder=mp1float \
  --enable-decoder=mp2 \
  --enable-decoder=mp2float \
  --enable-decoder=mp3 \
  --enable-decoder=wmapro \
  --enable-decoder=wmav1 \
  --enable-decoder=wmav2 \
  --enable-decoder=wmavoice \
  --enable-parser=aac \
  --enable-parser=aac_latm \
  --enable-parser=ac3 \
  --enable-parser=cook \
  --enable-parser=dca \
  --enable-parser=flac \
  --enable-parser=gsm \
  --enable-parser=mpegaudio \
  --enable-parser=vorbis \
  --disable-debug \
  --disable-asm \
  --enable-version3"


for version in armv7 ; do

  cd $SOURCE

  case $version in
    neon)
      EXTRA_CFLAGS="-march=armv7-a -mfpu=neon -mfloat-abi=softfp -mvectorize-with-neon-quad"
      EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
      ;;
    armv7)
      EXTRA_CFLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp"
      EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
      ;;
    vfp)
      EXTRA_CFLAGS="-march=armv6 -mfpu=vfp -mfloat-abi=softfp"
      EXTRA_LDFLAGS=""
      ;;
    armv6)
      EXTRA_CFLAGS="-march=armv6"
      EXTRA_LDFLAGS=""
      ;;
    *)
      EXTRA_CFLAGS=""
      EXTRA_LDFLAGS=""
      ;;
  esac

  PREFIX="$DEST/$version" && mkdir -p $PREFIX
  FFMPEG_FLAGS="$FFMPEG_FLAGS --prefix=$PREFIX"

  #./configure $FFMPEG_FLAGS --extra-cflags="$CFLAGS $EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS" | tee $PREFIX/configuration.txt
  ./configure $FFMPEG_FLAGS --extra-cflags="$CFLAGS $EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS"
  cp config.* $PREFIX
  [ $PIPESTATUS == 0 ] || exit 1

  make clean
  make -j4 || exit 1
  make install || exit 1

  $AR rcs $PREFIX/libffmpeg.a libavutil/*.o libavcodec/*.o libavformat/*.o libswresample/*.o libswscale/*.o  
  arm-linux-androideabi-strip --strip-unneeded $PREFIX/libffmpeg.a

done
