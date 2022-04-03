#bin/#!/bin/bash
# SPDX-License-Identifier: GPL-3.0
# Copyright © 2022,
# Author(s): Divyanshu-Modi <divyan.m05@gmail.com>, Tashfin Shakeer Rhythm <tashfinshakeerrhythm@gmail.com>
# Revision: 03-04-2022

# USER
	USER='Tashar'
	HOST='Cirrus'

# SCRIPT CONFIG
	SILENCE='0'
	SDFCF='1'
	BUILD='clean'

# DEVICE CONFIG
	NAME='Mi A2 / 6X'
	DEVICE='wayne'
	DEVICE2=''
	CAM_LIB='3'

# PATH
	KERNEL_DIR=`pwd`
	ZIP_DIR="$KERNEL_DIR/Repack"
	AKSH="$ZIP_DIR/anykernel.sh"
	cd $KERNEL_DIR

# DEFCONFIG
	DFCF="vendor/${DEVICE}-oss-perf_defconfig"
	CONFIG="$KERNEL_DIR/arch/arm64/configs/$DFCF"

# COLORS
	R='\033[1;31m'
	G='\033[1;32m'
	Y='\033[1;33m'
	B='\033[1;34m'
	W='\033[1;37m'

error () {
	echo -e ""
	echo -e "$R Error! $Y$1"
	echo -e ""
	exit 1
}

if [[ "$USER" == "" ]]; then
	clear
	echo -ne "$G \n User not defined! Manual input required :$W "
	read -r USER
fi
if [[ "$HOST" == "" ]]; then
	clear
	echo -ne "$G \n Host not defined! Manual input required :$W "
	read -r HOST
fi
if [[ "$SILENCE" == "1" ]]; then
	FLAG=-s
fi

# Select the compiler
compiler_selection () {
	echo -e "                 $G Compiler Selection $R            "
	echo -e " ╔══════════════════════════════════════════════════╗"
	echo -e " ║$G 1. CLANG                                         $R║"
	echo -e " ║$G 2. GCC                                           $R║"
	echo -e " ║$G e. EXIT                                          $R║"
	echo -e " ╚══════════════════════════════════════════════════╝"
	echo -ne "$G \n Enter your choice or press 'e' for back to shell:$W "

	read -r selector

	if [[ "$selector" == "1" ]]; then
		COMPILER='clang'
		pass
	elif [[ "$selector" == "2" ]]; then
		COMPILER='gcc'
		pass
	elif [[ "$selector" == "e" ]]; then
		clear || exit
	else
		clear
		error 'Compiler not defined'
	fi
}

# Telegram Bot Integration
function post_msg() {
	curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
	-d chat_id="$chat_id" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"
	}

function push() {
	curl -F document=@$1 "https://api.telegram.org/bot$token/sendDocument" \
	-F chat_id="$chat_id" \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=html" \
	-F caption="$2"
	}

# Clone toolchains
#git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 -b gcc-master $KERNEL_DIR/gcc64
git clone --depth=1 https://github.com/mvaisakh/gcc-arm -b gcc-master $KERNEL_DIR/gcc32
git clone --depth=1 https://gitlab.com/dakkshesh07/neutron-clang.git -b Neutron-15 $KERNEL_DIR/clang
git clone --depth=1 https://github.com/Tashar02/AnyKernel3-4.19.git -b main $KERNEL_DIR/Repack
git clone --depth=1 https://github.com/Atom-X-Devs/android_kernel_xiaomi_scarlet.git -b test-QTI-2 $KERNEL_DIR/Kernel

# Flags to be passed to compile
pass() {
	if [[ "$COMPILER" == "clang" ]]; then
		CC='clang'
		HOSTCC="$CC"
		HOSTCXX="$CC++"
		CC_64='aarch64-linux-gnu-'
		C_PATH="$KERNEL_DIR/clang"
	elif [[ "$COMPILER" == "gcc" ]]; then
		HOSTCC='gcc'
		CC_64='aarch64-elf-'
		CC='aarch64-elf-gcc'
		HOSTCXX='aarch64-elf-g++'
		C_PATH="$KERNEL_DIR/gcc64/bin:$KERNEL_DIR/gcc32/"
	else
		clear
		error 'Value not recognized'
	fi
		CC_32="$KERNEL_DIR/gcc32/bin/arm-eabi-"
		CC_COMPAT="$KERNEL_DIR/gcc32/bin/arm-eabi-gcc"
		build
}
export PATH=$C_PATH/bin:$PATH

# Compilation
muke () {
	make O=work $CFLAG ARCH=arm64 $FLAG	     \
			CC=$CC                           \
			LLVM=1                           \
			LLVM_IAS=1                       \
			PYTHON=python3                   \
			KBUILD_BUILD_USER=$USER          \
			KBUILD_BUILD_HOST=$HOST          \
			DTC_EXT=$(which dtc)             \
			AS=llvm-as                       \
			AR=llvm-ar                       \
			NM=llvm-nm                       \
			LD=ld.lld                        \
			STRIP=llvm-strip                 \
			OBJCOPY=llvm-objcopy             \
			OBJDUMP=llvm-objdump             \
			OBJSIZE=llvm-objsize             \
			HOSTLD=ld.lld                    \
			HOSTCC=$HOSTCC                   \
			HOSTCXX=$HOSTCXX                 \
			HOSTAR=llvm-ar                   \
			PATH=$C_PATH/bin:$PATH           \
			CROSS_COMPILE=$CC_64             \
			CC_COMPAT=$CC_COMPAT             \
			CROSS_COMPILE_COMPAT=$CC_32      \
			LD_LIBRARY_PATH=$C_PATH/lib:$LD_LIBRARY_PATH
}

# Cleanup the build environment
build () {
	clear
	if [[ "$BUILD" == "clean" ]]; then
		rm -rf work || mkdir work
	else
		make O=work clean mrproper distclean
	fi
	compile
}

# BUILD-START
compile () {
	CFLAG=$DFCF
	muke

	echo -e "$B"
	echo -e "                Build started                "
	echo -e "$G"

	BUILD_START=$(date +"%s")

	CFLAG=-j$(nproc --all)
	muke

# BUILD-END
	BUILD_END=$(date +"%s")

	echo -e "$B"
	echo -e "                Zipping started                "
	echo -e "$W"
	check
}

# Check for AnyKernel3
check () {
	if [[ -f $KERNEL_DIR/work/arch/arm64/boot/Image.gz-dtb ]]; then
		if [[ -d $ZIP_DIR ]]; then
			zip_ak
		else
			error "Anykernel is not present, cannot zip"
		fi
	else
		push "build.log" "Build Throws Errors"
	fi
}

# Zipping with AnyKernel3
zip_ak () {
	source work/.config

	FDEVICE=${DEVICE^^}
	KNAME=$(echo "$CONFIG_LOCALVERSION" | cut -c 2-)

	if [[ "$CONFIG_LTO_CLANG_THIN" != "y" && "$CONFIG_LTO_CLANG_FULL" == "y" ]]; then
		VARIANT='FULL_LTO'
	elif [[ "$CONFIG_LTO_CLANG_THIN" == "y" && "$CONFIG_LTO_CLANG_FULL" == "y" ]]; then
		VARIANT='THIN_LTO'
	else
		VARIANT='NON_LTO'
	fi

case $CAM_LIB in 
	1)
	   CAM=NEW-CAM
	;;
	2)
	   CAM=OLD-CAM
	;;
	3)
	   CAM=OSS-CAM
	;;
esac

	cp $KERNEL_DIR/work/arch/arm64/boot/Image.gz-dtb $ZIP_DIR/

	sed -i "s/demo1/$DEVICE/g" $AKSH
	if [[ "$DEVICE2" != "" ]]; then
		sed -i "/device.name1/ a device.name2=$DEVICE2" $AKSH
	fi

	cd $ZIP_DIR

	FINAL_ZIP="$KNAME-$CAM-$FDEVICE-$VARIANT-`date +"%H%M"`"
	zip -r9 "$FINAL_ZIP".zip * -x README.md *placeholder zipsigner*
	java -jar zipsigner* "$FINAL_ZIP.zip" "$FINAL_ZIP-signed.zip"
	FINAL_ZIP="$FINAL_ZIP-signed.zip"
	push "$FINAL_ZIP"

	sed -i "s/$DEVICE/demo1/g" $AKSH
	if [[ "$DEVICE2" != "" ]]; then
		sed -i "/device.name2/d" $AKSH
	fi

	cd $KERNEL_DIR
 	post_msg "
 	Compiler: $W$CONFIG_CC_VERSION_TEXT$G
 	Linux Version: $W$KV$G
 	Maintainer: $W$USER$G
 	Device: $W$NAME$G
 	Codename: $W$DEVICE$G
 	Cam-lib: $W$CAM$G
 	Zipname: $W$FINAL_ZIP$G
 	Build Date: $W$(date +"%Y-%m-%d %H:%M")$G
 	Build Duration: $W$(($DIFF / 60)).$(($DIFF % 60)) mins\
 	"

 	push "build.log" "Build Completed Successfully"
	exit 0
}

if [[ "$1" == "" ]]; then
	compiler_selection
else
	COMPILER="$1"
	pass
fi
