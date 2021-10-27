#!bin/bash
sudo apt install make bison bc libncurses5-dev git tmate python3-pip curl build-essential zip unzip
pip install telegram-upload
if [ -d $HOME/Anykernel ]
then
	echo "Anykernel Directory Already Exists"
else
git clone --depth=1 https://github.com/nktn30/AnyKernel3 $HOME/Anykernel
fi
if [ -d $HOME/kernel ]
then
echo "kernel dir exists"
else
git clone --depth=1 https://github.com/nktn30/velocity $HOME/kernel
fi
if [ -d $HOME/toolchains/gcc64 ] && [ -d $HOME/toolchains/gcc32 ]
then
echo "gcc dir exists"
else
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android11-release $HOME/toolchains/gcc64
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android11-release $HOME/toolchains/gcc32
fi
if [ -d $HOME/toolchains/clang ]
then
echo "clang dir exists"
else
cd $HOME/toolchains
mkdir clang
cd clang
wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android11-release/clang-r383902b.tar.gz
tar -xvzf clang-r383902b.tar.gz
fi
cd $HOME/kernel
#Starting Compilation
export ARCH=arm64
export SUBARCH=arm64
DATE=$(date +%d'-'%m'-'%y'-'%R)
K_DIR="$HOME/kernel"
export PATH="$HOME/toolchains/gcc64/bin/:$HOME/toolchains/gcc32/bin/:$HOME/toolchains/clang/bin/:$PATH"
cd $HOME/kernel
rm -f out/arch/arm64/boot/Image.gz-dtb
make O=out X00TD_defconfig
make -j$(nproc --all) O=out \
      CLANG_TRIPLE=aarch64-linux-gnu- \
      CROSS_COMPILE=aarch64-linux-android- \
      CROSS_COMPILE_ARM32=arm-linux-androideabi- \
      CC=clang
if [ -f out/arch/arm64/boot/Image.gz-dtb ]
then
cp out/arch/arm64/boot/Image.gz-dtb $HOME/Anykernel
cd $HOME/Anykernel
zip -r9 VELOCITY_V1.0-"$DATE".zip * -x .git README.md */placeholder
cp $HOME/Anykernel/VELOCITY_V1.0-"$DATE".zip $HOME/
rm $HOME/Anykernel/Image.gz-dtb
rm $HOME/Anykernel/VELOCITY_V1.0-"$DATE".zip
#Upload Kernel
telegram-upload $HOME/VELOCITY_V1.0-"$DATE".zip
else
	echo "Build Errored!"
fi
