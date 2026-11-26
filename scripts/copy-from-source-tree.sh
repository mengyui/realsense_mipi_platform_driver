#! /usr/bin/env bash

# usage: copy-from-source-tree.sh path-to-patched-src

# check the args
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 path-to-patched-src"
    exit 1
fi

ROOT_DIR=$(dirname $(dirname $(realpath $0)))
SRC_DIR=$(realpath $1)

echo "Copying files from $SRC_DIR to $ROOT_DIR"

cp ${SRC_DIR}/nvidia-oot/include/media/max9295.h ${ROOT_DIR}/src/rs_max9295.h
cp ${SRC_DIR}/nvidia-oot/drivers/media/i2c/max9295.c ${ROOT_DIR}/src/rs_max9295.c

cp ${SRC_DIR}/nvidia-oot/include/media/max96717.h ${ROOT_DIR}/src/rs_max96717.h
cp ${SRC_DIR}/nvidia-oot/drivers/media/i2c/max96717.c ${ROOT_DIR}/src/rs_max96717.c

cp ${SRC_DIR}/nvidia-oot/include/media/max9296.h ${ROOT_DIR}/src/rs_max9296.h
cp ${SRC_DIR}/nvidia-oot/drivers/media/i2c/max9296.c ${ROOT_DIR}/src/rs_max9296.c

cp ${SRC_DIR}/nvidia-oot/include/media/max96712.h ${ROOT_DIR}/src/rs_max96712.h
cp ${SRC_DIR}/nvidia-oot/drivers/media/i2c/max96712.c ${ROOT_DIR}/src/rs_max96712.c

cp ${SRC_DIR}/nvidia-oot/include/media/max96724.h ${ROOT_DIR}/src/rs_max96724.h
cp ${SRC_DIR}/nvidia-oot/drivers/media/i2c/max96724.c ${ROOT_DIR}/src/rs_max96724.c

cp ${SRC_DIR}/nvidia-oot/drivers/media/i2c/d4xx.h ${ROOT_DIR}/src/
cp ${SRC_DIR}/nvidia-oot/drivers/media/i2c/d4xx_desc.c ${ROOT_DIR}/src/
cp ${SRC_DIR}/nvidia-oot/drivers/media/i2c/d4xx_desc.h ${ROOT_DIR}/src/
cp ${SRC_DIR}/nvidia-oot/drivers/media/i2c/d4xx_main.c ${ROOT_DIR}/src/

pushd ${SRC_DIR}/nvidia-oot/
git add drivers/media/i2c/max9295.c
git add drivers/media/i2c/max9296.c
git add drivers/media/i2c/max96712.c
git add drivers/media/i2c/max96717.c
git add drivers/media/i2c/max96724.c
git add include/media/max9295.h
git add include/media/max9296.h
git add include/media/max96712.h
git add include/media/max96717.h
git add include/media/max96724.h
git add drivers/media/i2c/d4xx.h
git add drivers/media/i2c/d4xx_desc.c
git add drivers/media/i2c/d4xx_desc.h
git add drivers/media/i2c/d4xx_main.c

git diff >${ROOT_DIR}/patches/nvidia-oot.patch

git restore --staged .
popd

pushd ${SRC_DIR}/kernel/kernel-noble-src
git diff >${ROOT_DIR}/patches/kernel-noble.patch
popd

echo "Done"
