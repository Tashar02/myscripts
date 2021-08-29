#!bin/bash
#cloning Source, Toolchain and Anykernel3
if [ -d $HOME/kernel ]
then
	echo "Kernel Directory Already Exists"
else
git clone https://github.com/nktn30/velocity $HOME/kernel
fi
if [ -d $HOME/Anykernel ]
then
	echo "Anykernel Directory Already Exists"
else
git clone --depth=1 https://github.com/nktn30/AnyKernel3 $HOME/Anykernel
fi
if [ -d $HOME/toolchains/proton ]
then
	echo "clang Directory Already Exists"
else
git clone --depth=1 https://github.com/nktn30/proton-clang $HOME/toolchains/proton
fi
#Install required Packages
sudo apt install bc libncurses5-dev curl make build-essential zip unzip maven bison
#Starting Compilation
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Navin"
export KBUILD_BUILD_HOST="Navin"
DATE=$(date +%d'-'%m'-'%y'-'%R)
K_DIR="$HOME/kernel"
MPATH="$HOME/toolchains/proton/bin/:$PATH"
cd $HOME/kernel
rm -f out/arch/arm64/boot/Image.gz-dtb
make O=out X00TD_defconfig
PATH="$MPATH" make O=out \
      CROSS_COMPILE=aarch64-linux-gnu- \
      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
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
curl --upload-file $HOME/VELOCITY_V1.0-"$DATE".zip https://transfer.sh/VELOCITY_V1.0-"$DATE".zip
else
	echo "Build Errored!"
fi
