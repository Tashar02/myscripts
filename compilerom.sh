#!/bin/bash
sudo apt-get update -y
sudo apt install -y git bc bison ccache clang cmake flex libelf-dev lld ninja-build python3 tmate u-boot-tools zlib1g-dev rclone curl wget build-essential devscripts fakeroot psmisc qemu-kvm unzip zip rsync make default-jdk gnupg flex gperf gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo
sudo install repo /usr/local/bin
rm repo
git clone https://github.com/nktn30/scripts.git scripts && cd scripts
bash setup/android_build_env.sh
rm -rf ../scripts
git config --global user.name "nktn30"
git config --global user.email "nkwhitehat@gmail.com"
git config --global credential.helper store
echo "Which Rom Would You Want To Build?"
echo "1.Evolution-X"
echo "2.Spice OS"
echo "Enter Your Option: "
read option
if [ $option -eq 1 ]; then
export BUILD=evo
fi
if [ $option -eq 2 ]; then
export BUILD=spice
fi
if [ $BUILD = evo ]; then
cd
mkdir evo && cd evo
export ROM=$(pwd)
repo init -u https://github.com/Evolution-X/manifest -b elle --depth=1
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
rm -rf $ROM/device/asus/X00TD && git clone https://github.com/nktn30/device_asus_X00TD -b eleven $ROM/device/asus/X00TD && rm -rf $ROM/device/asus/sdm660-common && git clone https://github.com/nktn30/device_asus_sdm660-common -b eleven $ROM/device/asus/sdm660-common && rm -rf $ROM/vendor/asus && git clone https://github.com/nktn30/vendor_asus -b eleven $ROM/vendor/asus --depth=1 && rm -rf $ROM/kernel/asus/sdm660 && git clone https://github.com/nktn30/velocity -b eleven $ROM/kernel/asus/sdm660 --depth=1
fi
if [ $BUILD = spice ]; then
cd
mkdir spice && cd spice
export ROM=$(pwd)
repo init -u https://github.com/SpiceOS/android.git -b 11 --depth=1
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
rm -rf $ROM/device/asus/X00TD && git clone https://github.com/nktn30/device_asus_X00TD -b spiceos $ROM/device/asus/X00TD && rm -rf $ROM/device/asus/sdm660-common && git clone https://github.com/nktn30/device_asus_sdm660-common -b eleven $ROM/device/asus/sdm660-common && rm -rf $ROM/vendor/asus && git clone https://github.com/nktn30/vendor_asus -b eleven $ROM/vendor/asus --depth=1 && rm -rf $ROM/kernel/asus/sdm660 && git clone https://github.com/nktn30/velocity -b eleven $ROM/kernel/asus/sdm660 --depth=1
else
echo "Please Choose a Correct option"
fi
