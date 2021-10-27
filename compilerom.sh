#!/bin/bash
echo "Did You Installed Required Packages and Repo tool?"
echo "1.Yes, I Had Installed"
echo "2.NO, I didn't Installed"
echo "Enter your Option :"
read packages
if [ $packages -eq 2 ]
then
cd
sudo apt-get update -y
sudo apt install -y git git-lfs bc bison ccache clang cmake flex libelf-dev lld ninja-build python3 tmate u-boot-tools zlib1g-dev rclone curl wget build-essential devscripts fakeroot psmisc qemu-kvm unzip zip rsync make default-jdk gnupg flex gperf gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > repo
chmod a+x repo
sudo install repo /usr/local/bin
rm repo
git clone https://github.com/navin136/scripts.git scripts && cd scripts
bash setup/android_build_env.sh
cd
rm -rf scripts
else
git config --global user.name "navin136"
git config --global user.email "nkwhitehat@gmail.com"
git config --global credential.helper store
echo "Which Rom Would You Want To Build?"
echo "1.Evolution-X"
echo "2.Spice OS"
echo "Enter Your Option: "
read option
if [ $option -eq 1 ]
then
export BUILD=evo
fi
if [ $option -eq 2 ]
then
export BUILD=spice
fi
if [ $BUILD = evo ]
then
cd
if [ -d evo ]
then
cd evo
export ROM=$(pwd)
rm -rf $ROM/device/asus/X00TD && git clone https://github.com/navin136/android_device_asus_X00TD -b snow $ROM/device/asus/X00TD && rm -rf $ROM/vendor/asus && git clone https://github.com/navin136/android_vendor_asus_X00TD -b snow $ROM/vendor/asus --depth=1 && rm -rf $ROM/kernel/asus/sdm660 && git clone https://github.com/navin136/android_kernel_asus_X00TD -b snow $ROM/kernel/asus/sdm660 --depth=1
rm -rf $ROM/hardware/qcom-caf/msm8998/audio && git clone https://github.com/navin136/android_hardware_qcom-caf_audio_msm8998 $ROM/hardware/qcom-caf/msm8998/audio && rm -rf $ROM/hardware/qcom-caf/msm8998/display && git clone https://github.com/navin136/android_hardware_qcom-caf_display_msm8998 $ROM/hardware/qcom-caf/msm8998/display
sudo mkdir /mnt/ccache
sudo mount ../.cache /mnt/ccache
export CCACHE_DIR=/mnt/ccache
. b*/e*
lunch evolution_X00TD-user
make evolution -j$(nproc --all) | tee log.txt
else
mkdir evo
cd evo
export ROM=$(pwd)
repo init -u https://github.com/Evolution-X/manifest -b snow --depth=1
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
rm -rf $ROM/device/asus/X00TD && git clone https://github.com/navin136/android_device_asus_X00TD -b snow $ROM/device/asus/X00TD && rm -rf $ROM/vendor/asus && git clone https://github.com/navin136/android_vendor_asus_X00TD -b snow $ROM/vendor/asus --depth=1 && rm -rf $ROM/kernel/asus/sdm660 && git clone https://github.com/navin136/android_kernel_asus_X00TD -b snow $ROM/kernel/asus/sdm660 --depth=1
rm -rf $ROM/hardware/qcom-caf/msm8998/audio && git clone https://github.com/navin136/android_hardware_qcom-caf_audio_msm8998 $ROM/hardware/qcom-caf/msm8998/audio && rm -rf $ROM/hardware/qcom-caf/msm8998/display && git clone https://github.com/navin136/android_hardware_qcom-caf_display_msm8998 $ROM/hardware/qcom-caf/msm8998/display
git clone https://github.com/Navin136/vendor_evolution_build_target_product_security $ROM/vendor/evolution/build/target/product/security
sudo mkdir /mnt/ccache
sudo mount ../.cache /mnt/ccache
export CCACHE_DIR=/mnt/ccache
. b*/e*
lunch evolution_X00TD-user
make evolution -j$(nproc --all) | tee log.txt
fi
fi
if [ $BUILD = spice ]
then
cd
if [ -d spice ]
then
cd spice
export ROM=$(pwd)
rm -rf $ROM/device/asus/X00TD && git clone https://github.com/navin136/android_device_asus_X00TD -b spiceos $ROM/device/asus/X00TD && rm -rf $ROM/vendor/asus && git clone https://github.com/navin136/android_vendor_asus_X00TD -b snow $ROM/vendor/asus --depth=1 && rm -rf $ROM/kernel/asus/sdm660 && git clone https://github.com/navin136/android_kernel_asus_X00TD -b snow $ROM/kernel/asus/sdm660 --depth=1
rm -rf $ROM/hardware/qcom-caf/msm8998/audio && git clone https://github.com/navin136/android_hardware_qcom-caf_audio_msm8998 $ROM/hardware/qcom-caf/msm8998/audio && rm -rf $ROM/hardware/qcom-caf/msm8998/display && git clone https://github.com/navin136/android_hardware_qcom-caf_display_msm8998 $ROM/hardware/qcom-caf/msm8998/display
sudo mkdir /mnt/ccache
sudo mount ../.cache /mnt/ccache
export CCACHE_DIR=/mnt/ccache
. b*/e*
lunch lineage_X00TD-user
make bacon -j$(nproc --all) | tee log.txt
else
mkdir spice
cd spice
export ROM=$(pwd)
repo init -u https://github.com/SpiceOS/android.git -b 11 --depth=1
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
rm -rf $ROM/device/asus/X00TD && git clone https://github.com/navin136/android_device_asus_X00TD -b spiceos $ROM/device/asus/X00TD && rm -rf $ROM/vendor/asus && git clone https://github.com/navin136/android_vendor_asus_X00TD -b snow $ROM/vendor/asus --depth=1 && rm -rf $ROM/kernel/asus/sdm660 && git clone https://github.com/navin136/android_kernel_asus_X00TD -b snow $ROM/kernel/asus/sdm660 --depth=1
rm -rf $ROM/hardware/qcom-caf/msm8998/audio && git clone https://github.com/navin136/android_hardware_qcom-caf_audio_msm8998 $ROM/hardware/qcom-caf/msm8998/audio && rm -rf $ROM/hardware/qcom-caf/msm8998/display && git clone https://github.com/navin136/android_hardware_qcom-caf_display_msm8998 $ROM/hardware/qcom-caf/msm8998/display
sudo mkdir /mnt/ccache
sudo mount ../.cache /mnt/ccache
export CCACHE_DIR=/mnt/ccache
. b*/e*
lunch lineage_X00TD-user
make bacon -j$(nproc --all) | tee log.txt
fi
fi
fi
