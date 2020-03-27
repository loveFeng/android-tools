#!/bin/bash

ipsuf="192.168.1."
for i in {128..138}
do
    ip=${ipsuf}$i
    echo "ip=$ip" 
    pcount=`ping -c 3 $ip`
    #echo "pcount=$pcount" //64 bytes from 192.168.1.128: icmp_seq=1 ttl=62 time=2.77 ms
    if [[ $pcount =~ .*ttl=.* ]] && [[ $pcount =~ .*time=.* ]]; then
        echo "$ip exist"
    else
        echo "$ip not exist"
    fi
done
