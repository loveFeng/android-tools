#! /bin/sh

zip_path=update
TARGET_FILES_ZIP=test.zip
ROOT_PATH=/home/joe/project/TJ47_SVN/trunk/patchrom

file=/home/joe/project/TJ47_SVN/trunk/patchrom/./fasf.xml
type=${file##*.}
echo "type=$type"
exit
echo "$0 正在压缩升级包"
#压缩升级包
cd $zip_path
zip -q -r -y $TARGET_FILES_ZIP *


#签名升级包
echo "$0 正在签名升级包"
tmpzip=`date +%N`
tmpzip=$tmpzip.zip
java -Xmx4096m -jar $ROOT_PATH/tools/signapk.jar -w $ROOT_PATH/build/security/testkey.x509.pem $ROOT_PATH/build/security/testkey.pk8 $TARGET_FILES_ZIP $tmpzip
rm $TARGET_FILES_ZIP
mv $tmpzip ../$TARGET_FILES_ZIP
cd ..
