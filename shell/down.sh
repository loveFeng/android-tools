#!/bin/bash
killall wget
ROOT_PATH=$(cd "$(dirname "$0")"; pwd)
source /etc/profile
cd $ROOT_PATH
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


#url.txt content#
#http://kuai.xunlei.com/d/I2BEBgIILABJiMZSb05
#http://kuai.xunlei.com/d/I2BEBgIGLAAtiMZS15d
#http://kuai.xunlei.com/d/I2BEBgICLAADiMZS60b
#http://kuai.xunlei.com/d/I2BEBgL8KwDMh8ZSe95
#http://kuai.xunlei.com/d/I2BEBgofjACah8ZS0db
