#!/bin/bash

i=1
while read line
do
	if [ "$line" != "" ]
	then
		echo "wget --save-cookies=cookie$i --keep-session-cookies -O $i.html $line"
		wget --save-cookies=cookie$i --keep-session-cookies -O $i.html $line
		url=`grep "file_url=" $i.html -rn`
		#echo $url
		url=${url##*file_url=\"}
		#echo $url
		url=${url%%\"*}
		#echo $url
		echo "wget -b -c -t 0 -o download$i.log -O name$i.rar --load-cookies=cookie$i --keep-session-cookies $url"
		wget -b -c -t 0 -o download$i.log -O name$i.rar --load-cookies=cookie$i --keep-session-cookies $url
		let i++
	fi
done < url.txt

