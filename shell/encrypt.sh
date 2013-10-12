#!/bin/bash
   
echo "********************build start*************************"
for params
do
  case $params in
    "new")
    ./makeMtk i5 new
    echo "********************./makeMtk i5 new"
    ;;
    "r")
    ./makeMtk i5 r
    echo "********************./makeMtk i5 r"
    ;;
  esac
done
./makeMtk i5 mm prebuilt/3rd_party_apk_odex
echo "********************./makeMtk i5 mm prebuilt/3rd_party_apk_odex"
./makeMtk i5 mm prebuilt/3rd_party_jar_odex
echo "********************./makeMtk i5 mm prebuilt/3rd_party_jar_odex"

./makeMtk i5 systemimage
echo "********************./makeMtk i5 systemimage"
echo "********************build end***************************"
