#!/bin/bash

PRJ_DIR=`pwd`
ROM_C=$PRJ_DIR/rom-c
OUT_DIR=$PRJ_DIR/out
OTA_FILES_ZIP=$OUT_DIR/fullota.zip
TOOL_DIR=$PORT_ROOT/tools

function cp_rom_scatter(){
    txts="scatter.txt
    SEC_VER.txt
    type.txt"
    files=""
    for txt in $txts
    do
        if [ -f $ROM_C/$txt ]
        then
            files=$files" "$ROM_C/$txt
        fi
    done
    zip -jr $OTA_FILES_ZIP $files
}

function sign_ota_zip(){
    tmp=`date +%N`
    apk_cert=testkey
    echo "$apk_cert $OTA_FILES_ZIP  $tmp"
    java -Xmx512m -Xmx1024m -Xmx2048m -jar $TOOL_DIR/signapk.jar -w $PORT_ROOT/build/security/$apk_cert.x509.pem $PORT_ROOT/build/security/$apk_cert.pk8 $OTA_FILES_ZIP $tmp
    mv $tmp $OTA_FILES_ZIP
}

function cp_ota_zip(){
    TARGET_FILES_ZIP=`date +%Y%m%d`
    cp $OTA_FILES_ZIP fullota_$TARGET_FILES_ZIP.zip
}

cp_rom_scatter
sign_ota_zip
cp_ota_zip



