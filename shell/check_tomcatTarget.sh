#!/bin/bash

target=`ps -ef | grep tomcatTarget | grep -v "grep"`
#echo "target=$target"
if [ -z "$target" ];then
    echo "need start"
    echo "need start target `date`"
    
fi
