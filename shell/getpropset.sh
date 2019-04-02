#!/bin/bash
grep "\[PropSet\]" logs -rn > propset.txt
rm -f prop.txt
while read line
do
    pro=${line##*"Eric set"}
    #echo "pro=$pro"
    pro=${pro%%=*}
    echo "$pro" >> prop.txt
done < propset.txt

cat prop.txt | sort | uniq > find-prop.txt

