#!/bin/sh

git clean -dxf
git reset --hard HEAD

DATA_DIR="battalion.data"
mkdir $DATA_DIR
touch $DATA_DIR/battalion.sho
touch battalion_hiscore
cp -r DATA $DATA_DIR/
cp -r MUSIC $DATA_DIR/
cp -r SOUNDS $DATA_DIR/
cp -r TEXTURES $DATA_DIR/

make


BATTALIONSCOREDIR="$(dirname "$0")"
export BATTALIONSCOREDIR

# Set AddressSanitizer suppression file
export LSAN_OPTIONS="suppressions=$(pwd)/battalion.supp:print_suppressions=1"

./battalion
