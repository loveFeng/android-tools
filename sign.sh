#! /bin/sh

file=
apk_cert=

if [ $# -eq 2 ]
then
    file=$2
    apk_cert=$1
else
    file=$1
    apk_cert=testkey
fi

PORT_ROOT=$(cd "$(dirname "$0")"; pwd)

tmp=`date +%N`
echo "$apk_cert $file $PORT_ROOT $tmp"
java -Xmx512m -Xmx1024m -Xmx2048m -jar $PORT_ROOT/signapk.jar -w $PORT_ROOT/build/security/$apk_cert.x509.pem $PORT_ROOT/build/security/$apk_cert.pk8 $file $tmp
mv $tmp $file
