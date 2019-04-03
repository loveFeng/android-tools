#!/bin/bash
patch_path="/source/M802"
source_path="/work/test/gts/0403/V135/sources/mtk6580"

pushd $source_path
pfiles=`find * -name "*.patch"`
popd

cp -rf $source_path/* $patch_path

for f in $pfiles
do
    folder=${f%/*}
    echo "folder=$folder"
    pushd $patch_path/$folder
        echo "git apply $source_path/$f"
        echo
        git apply $source_path/$f
        echo
    popd
    echo "rm -f $patch_path/$f"
    rm -f $patch_path/$f
done
