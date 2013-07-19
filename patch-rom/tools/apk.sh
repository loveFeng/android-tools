#!/bin/bash
cd $1
for apk in `ls`
do
    ~/tools/apktool d  `basename $apk`
done

