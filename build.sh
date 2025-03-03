#!/usr/bin/env bash
#
# Copyright (C) 2023 Edwiin Kusuma Jaya (ryuzenn)
#
# Simple Local Kernel Build Script
#
# Configured for Redmi Note 8 / ginkgo custom kernel source
#
# Setup build env with akhilnarang/scripts repo
#
# Use this script on root of kernel directory

SECONDS=0 # builtin bash timer
DIR=`readlink -f .`
LOCAL_DIR=`readlink -f ${DIR}/..`
ZIPNAME="RyzenKernel-Peridot-$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M").zip"
TC_DIR="${LOCAL_DIR}/toolchain"
LINKER="lld"
MAKE="./makeparallel"
CLANG_DIR="${TC_DIR}/clang-rastamod"
GCC_64_DIR="${LOCAL_DIR}/toolchain/aarch64-linux-android-4.9"
GCC_32_DIR="${LOCAL_DIR}/toolchain/arm-linux-androideabi-4.9"
AK3_DIR="${LOCAL_DIR}/AnyKernel3"
DEFCONFIG=peridot_defconfig

export PATH="$CLANG_DIR/bin:$PATH"
export KBUILD_BUILD_USER="EdwiinKJ"
export KBUILD_BUILD_HOST="RastaMod69"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_COMPILER_STRING="$($CLANG_DIR/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"


if ! [ -d "${CLANG_DIR}" ]; then
echo "Clang not found! Cloning to ${TC_DIR}..."
if ! git clone --depth=1 -b clang-20.0 https://gitlab.com/kutemeikito/rastamod69-clang ${CLANG_DIR}; then
echo "Cloning failed! Aborting..."
exit 1
fi
fi

if ! [ -d "${GCC_64_DIR}" ]; then
echo "gcc not found! Cloning to ${GCC_64_DIR}..."
if ! git clone --depth=1 -b lineage-19.1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git ${GCC_64_DIR}; then
echo "Cloning failed! Aborting..."
exit 1
fi
fi

if ! [ -d "${GCC_32_DIR}" ]; then
echo "gcc_32 not found! Cloning to ${GCC_32_DIR}..."
if ! git clone --depth=1 -b lineage-19.1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9.git ${GCC_32_DIR}; then
echo "Cloning failed! Aborting..."
exit 1
fi
fi

echo -e "\nStarting compilation...\n"
make $DEFCONFIG O=out CC=clang
make -j$(nproc --all) O=out \
                      CC=clang \
                      ARCH=arm64 \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      NM=llvm-nm \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip

if [ -f "out/arch/arm64/boot/Image.gz" ]; then
echo -e "\nKernel compiled succesfully! Zipping up...\n"
if [ -d "$AK3_DIR" ]; then
cp -r $AK3_DIR AnyKernel3
elif ! git clone -q -b peridot https://github.com/kutemeikito/AnyKernel3; then
echo -e "\nAnyKernel3 repo not found locally and cloning failed! Aborting..."
exit 1
fi
cp out/arch/arm64/boot/Image.gz AnyKernel3
rm -f *zip
cd AnyKernel3
git checkout peridot &> /dev/null
zip -r9 "../$ZIPNAME" * -x '*.git*' README.md *placeholder
cd ..
rm -rf AnyKernel3
rm -rf out/arch/arm64/boot
echo -e "======================================="
echo -e "░█▀▀█ █──█ ▀▀█ █▀▀ █▀▀▄ "
echo -e "░█▄▄▀ █▄▄█ ▄▀─ █▀▀ █──█ "
echo -e "░█─░█ ▄▄▄█ ▀▀▀ ▀▀▀ ▀──▀ "
echo -e " "
echo -e "░█─▄▀ █▀▀ █▀▀█ █▀▀▄ █▀▀ █── "
echo -e "░█▀▄─ █▀▀ █▄▄▀ █──█ █▀▀ █── "
echo -e "░█─░█ ▀▀▀ ▀─▀▀ ▀──▀ ▀▀▀ ▀▀▀ "
echo -e "======================================="
echo -e "Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
echo "Zip: $ZIPNAME"
else
echo -e "\nCompilation failed!"
exit 1
fi
echo "Move Zip into Home Directory"
mv *.zip ${LOCAL_DIR}
echo -e "======================================="