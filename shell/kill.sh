#!/bin/bash

proc=$1

function killProc() {
	adb shell kill $2
}

line=`adb shell ps | grep $proc`

killProc $line

#ps -ef | grep $1 | grep -v grep | cut -b 9-15 |xargs kill -9
