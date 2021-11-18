#!bin/bash

# Install Required Packages
sudo apt install make bison bc libncurses5-dev tmate git python3-pip curl build-essential zip unzip -y

#Working Directory
WORK_DIR=$(pwd)

# Telegram Chat Id
ID="-1001509079419"

# Bot Token
bottoken=$token

# Functions
msg() {
	curl -X POST "https://api.telegram.org/bot$bottoken/sendMessage" -d chat_id="$ID" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"
}
file() {
	MD5=$(md5sum "$1" | cut -d' ' -f1)
	curl --progress-bar -F document=@"$1" "https://api.telegram.org/bot$bottoken/sendDocument" \
	-F chat_id="$ID"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$2 | <b>MD5 Checksum : </b><code>$MD5</code>"
}

#cloning
if [ -d $WORK_DIR/Anykernel ]
then
echo "Anykernel Directory Already Exists"
else
git clone --depth=1 https://github.com/navin136/AnyKernel3 $WORK_DIR/Anykernel
fi
if [ -d $WORK_DIR/kernel ]
then
echo "kernel dir exists"
else
git clone --depth=1 https://github.com/navin136/android_kernel_asus_X00TD $WORK_DIR/kernel
fi
if [ -d $WORK_DIR/toolchains/gcc64 ] && [ -d $WORK_DIR/toolchains/gcc32 ]
then
echo "gcc dir exists"
else
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android12-release $WORK_DIR/toolchains/gcc64
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android12-release $WORK_DIR/toolchains/gcc32
fi
if [ -d $WORK_DIR/toolchains/clang ]
then
echo "clang dir exists"
else
cd $WORK_DIR/toolchains
mkdir clang
cd clang
wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android12-release/clang-r416183b1.tar.gz
tar -xvzf clang-r416183b1.tar.gz
fi

#Starting Compilation
msg "<b>Build Started</b>"
BUILD_START=$(date +"%s")
cd $WORK_DIR/kernel
export ARCH=arm64
export SUBARCH=arm64
DATE=$(date +%d'-'%m'-'%y'-'%R)
K_DIR="$WORK_DIR/kernel"
export PATH="$WORK_DIR/toolchains/gcc64/bin/:$WORK_DIR/toolchains/gcc32/bin/:$WORK_DIR/toolchains/clang/bin/:$PATH"
cd $WORK_DIR/kernel
make clean && make mrproper
rm -f out/arch/arm64/boot/Image.gz-dtb
make O=out X00TD_defconfig
make -j$(nproc --all) O=out \
      CLANG_TRIPLE=aarch64-linux-gnu- \
      CROSS_COMPILE=aarch64-linux-android- \
      CROSS_COMPILE_ARM32=arm-linux-androideabi- \
      CC=clang

#Zipping Into Flashable Zip
if [ -f out/arch/arm64/boot/Image.gz-dtb ]
then
cp out/arch/arm64/boot/Image.gz-dtb $WORK_DIR/Anykernel
cd $WORK_DIR/Anykernel
zip -r9 VELOCITY-$DATE.zip * -x .git README.md */placeholder
cp $WORK_DIR/Anykernel/VELOCITY-$DATE.zip $WORK_DIR/
rm $WORK_DIR/Anykernel/Image.gz-dtb
rm $WORK_DIR/Anykernel/VELOCITY-$DATE.zip
BUILD_END=$(date +"%s")
DIFF=$((BUILD_END - BUILD_START))

#Upload Kernel

file "$WORK_DIR/VELOCITY-$DATE.zip" "Build took : $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)"

else
msg "<b>Build Errored!</b>"
fi
