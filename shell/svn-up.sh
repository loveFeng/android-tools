#!/bin/bash

echo "********************sync start*************************"

while(:)
do
echo "********************sync"

 svnsync sync file:///f:/svn-cp/TK75_V40

 if [ $? != 0 ]

 then

 echo "********************sync error"

 svn propdel svn:sync-lock --revprop -r0 file:///f:/svn-cp/TK75_V40
 fi
 sleep 60

done

echo "********************sync finish"

t