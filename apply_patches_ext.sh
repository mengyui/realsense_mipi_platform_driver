#!/bin/bash
# Jetson Linux
# JP 6.0 DP https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v2.0/sources/public_sources.tbz2
# JP 6.0 https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.0/sources/public_sources.tbz2
# JP 6.1 https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.0/sources/public_sources.tbz2
# JP 6.2 https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.3/sources/public_sources.tbz2

set -e

if [[ $# < 1 ]]; then
    echo "apply_patches_ext.sh [--one-cam | --dual-cam] source_dir [JetPack_version]"
    exit 1
fi

# Default to single camera DT for JetPack 5.0.2
# single - jp5 [default] single cam GMSL board
# dual - dual cam GMSL board SC20220126
JP5_D4XX_DTSI="tegra194-camera-d4xx-single.dtsi"
if [[ "$1" == "--one-cam" ]]; then
    JP5_D4XX_DTSI="tegra194-camera-d4xx-single.dtsi"
    shift
fi
if [[ "$1" == "--dual-cam" ]]; then
    JP5_D4XX_DTSI="tegra194-camera-d4xx-dual.dtsi"
    shift
fi

DEVDIR=$(cd `dirname $0` && pwd)

. $DEVDIR/scripts/setup-common "$2"

cd "$DEVDIR"

# set JP4 devicetree
if [[ "$JETPACK_VERSION" == "4.6.1" ]]; then
    JP5_D4XX_DTSI="tegra194-camera-d4xx.dtsi"
fi

if [[ $JETPACK_VERSION == 4* ]]; then
    D4XX_SRC_DST=kernel/nvidia
elif [[ $JETPACK_VERSION == 5* ]]; then
    D4XX_SRC_DST=kernel/nvidia
elif [[ $JETPACK_VERSION == 6* ]]; then
    D4XX_SRC_DST=nvidia-oot
else
    D4XX_SRC_DST=nvidia-oot
fi

# NVIDIA SDK Manager's JetPack 4.6.1 source_sync.sh doesn't set the right folder name, it mismatches with the direct tar
# package source code. Correct the folder name.
if [ -d $1/hardware/nvidia/platform/t19x/galen-industrial-dts ]; then
    mv $1/hardware/nvidia/platform/t19x/galen-industrial-dts $1/hardware/nvidia/platform/t19x/galen-industrial
fi

apply_external_patches() {
    cat ${PWD}/$2/$JETPACK_VERSION/* | patch -p1 --directory=${PWD}/$1/$2/
}

apply_external_patches $1 $D4XX_SRC_DST
if [ -d ${KERNEL_DIR}/${JETPACK_VERSION} ]; then
    apply_external_patches $1 $KERNEL_DIR
fi

if [[ $JETPACK_VERSION == 4* ]]; then
    apply_external_patches $1 hardware/nvidia/platform/t19x/galen/kernel-dts
    apply_external_patches $1 hardware/nvidia/platform/t23x/concord/kernel-dts
    apply_external_patches $1 hardware/nvidia/platform/t23x/p3768/kernel-dts
elif [[ $JETPACK_VERSION == 5* ]]; then
    apply_external_patches $1 hardware/nvidia/platform/t19x/galen/kernel-dts
    apply_external_patches $1 hardware/nvidia/platform/t23x/concord/kernel-dts
    apply_external_patches $1 hardware/nvidia/platform/t23x/p3768/kernel-dts
elif [[ $JETPACK_VERSION == 6* ]]; then
    apply_external_patches $1 hardware/nvidia/t23x/nv-public
else
    aapply_external_patches $1 hardware/nvidia/t23x/nv-public
fi

# For a common driver for JP4 + JP5 we override the i2c driver and ignore the previous that was created from patches
cp $DEVDIR/kernel/realsense/d4xx.c $DEVDIR/$1/${D4XX_SRC_DST}/drivers/media/i2c/
if [[ $JETPACK_VERSION == 6* ]]; then
    # jp6 overlay
    cp $DEVDIR/hardware/realsense/tegra234-camera-d4xx-overlay.dts $DEVDIR/$1/hardware/nvidia/t23x/nv-public/overlay/
    cp $DEVDIR/hardware/realsense/tegra234-camera-d4xx-overlay-dual.dts $DEVDIR/$1/hardware/nvidia/t23x/nv-public/overlay/
    cp $DEVDIR/hardware/realsense/tegra234-p3737-camera-d4xx-overlay-fg96-8ch-dual.dts $DEVDIR/$1/hardware/nvidia/t23x/nv-public/overlay/
    cp $DEVDIR/hardware/realsense/tegra234-p3737-camera-d4xx-overlay-fg96-8ch-single.dts $DEVDIR/$1/hardware/nvidia/t23x/nv-public/overlay/
    cp $DEVDIR/hardware/realsense/tegra234-p3768-camera-d4xx-overlay-fg96-2ch-dual.dts $DEVDIR/$1/hardware/nvidia/t23x/nv-public/overlay/
    cp $DEVDIR/hardware/realsense/tegra234-p3768-camera-d4xx-overlay-fg96-2ch-single.dts $DEVDIR/$1/hardware/nvidia/t23x/nv-public/overlay/
else
    cp $DEVDIR/hardware/realsense/$JP5_D4XX_DTSI $DEVDIR/$1/hardware/nvidia/platform/t19x/galen/kernel-dts/common/tegra194-camera-d4xx.dtsi

    cp $DEVDIR/hardware/realsense/tegra194-camera-d4xx-single.dtsi $DEVDIR/$1/hardware/nvidia/platform/t19x/galen/kernel-dts/common/tegra194-camera-d4xx-single.dtsi
    cp $DEVDIR/hardware/realsense/tegra194-camera-d4xx-dual.dtsi $DEVDIR/$1/hardware/nvidia/platform/t19x/galen/kernel-dts/common/tegra194-camera-d4xx-dual.dtsi
    cp $DEVDIR/hardware/realsense/tegra194-p2822-camera-d4xx-fg96-8ch-single.dtsi $DEVDIR/$1/hardware/nvidia/platform/t19x/galen/kernel-dts/common/tegra194-p2822-camera-d4xx-fg96-8ch-single.dtsi
    cp $DEVDIR/hardware/realsense/tegra194-p2822-camera-d4xx-fg96-8ch-dual.dtsi $DEVDIR/$1/hardware/nvidia/platform/t19x/galen/kernel-dts/common/tegra194-p2822-camera-d4xx-fg96-8ch-dual.dtsi
    cp $DEVDIR/hardware/realsense/tegra234-p3737-camera-d4xx-fg96-8ch-single.dtsi $DEVDIR/$1/hardware/nvidia/platform/t23x/concord/kernel-dts/cvb/tegra234-p3737-camera-d4xx-fg96-8ch-single.dtsi
    cp $DEVDIR/hardware/realsense/tegra234-p3737-camera-d4xx-fg96-8ch-dual.dtsi $DEVDIR/$1/hardware/nvidia/platform/t23x/concord/kernel-dts/cvb/tegra234-p3737-camera-d4xx-fg96-8ch-dual.dtsi
    cp $DEVDIR/hardware/realsense/tegra234-p3768-camera-d4xx-fg96-2ch-single.dtsi $DEVDIR/$1/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb/tegra234-p3768-camera-d4xx-fg96-2ch-single.dtsi
    cp $DEVDIR/hardware/realsense/tegra234-p3768-camera-d4xx-fg96-2ch-dual-depth-ir.dtsi $DEVDIR/$1/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb/tegra234-p3768-camera-d4xx-fg96-2ch-dual-depth-ir.dtsi
    cp $DEVDIR/hardware/realsense/tegra234-p3768-camera-d4xx-fg96-2ch-dual-depth-color.dtsi $DEVDIR/$1/hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb/tegra234-p3768-camera-d4xx-fg96-2ch-dual-depth-color.dtsi
    echo
    echo "!!!!!!!!"
    echo "Please EDIT the following file(s) to enable your selected deserializer board."
    echo "  hardware/nvidia/platform/t19x/galen/kernel-dts/tegra194-p2888-0001-p2822-0000.dts"
    echo "  hardware/nvidia/platform/t23x/concord/kernel-dts/tegra234-p3701-0000-p3737-0000.dts"
    echo "  hardware/nvidia/platform/t23x/p3768/kernel-dts/cvb/tegra234-p3768-0000-a0.dtsi"
fi
