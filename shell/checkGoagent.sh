#!/bin/sh

#description:check goagent
#processname:checkgoagent

process_num=`ps |grep "proxy.py" |grep -v "grep" |wc -l`
#process_num=`ps -A |grep "sshd" |grep -v "grep" |wc -l`

if [ $process_num -ge 1 ]; then
	echo "no need restart goagent at "`date`.
else
     /work/jiangzongwen/goagent
fi
