#!/bin/bash

apkfile=$1
package=""
activity=""


function getname() {
    name=$@

    name=${name##*name=\'}

    name=${name%%\'*}

}

./aapt d badging $apkfile > get_launcher_tmp.txt

tmp=`grep "package" get_launcher_tmp.txt -n`
getname $tmp
package=$name
#echo "package=$package"

tmp=`grep "launchable-activity" get_launcher_tmp.txt -n`
getname $tmp
activity=$name
#echo "activity=$activity"

echo "adb start -n $package/$activity"
