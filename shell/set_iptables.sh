#!/system/bin/sh

# enable ip forward
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -v -n -L INPUT

#显示规则
#iptables -t filter -L INPUT

#删除 INPUT所有规则
iptables -F INPUT

#set default drop 设置默认input所有不通过
iptables -P INPUT DROP

#LOG 输出 7为 debug级别
iptables -A OUTPUT -p tcp -j LOG --log-level 7 --log-prefix '[IPTABLES-FORWARD]'
#允许回环地址
iptables -A INPUT -i lo -j ACCEPT
#允许目的地址是192.168.43.0～255的地址通过
iptables -A INPUT -d 192.168.43.0/24 -j ACCEPT
#允许udp 53 通过 域名解析 来自远程DNS服务器53端口的数据包进站通过
iptables -A INPUT -p udp -m udp --sport 53 -j ACCEPT
#进入本地服务器53端口的数据包进站通过
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT 
#允许 DHCP 服务器端 端口 67
iptables -A INPUT -p udp -m udp --sport 68 -j ACCEPT
#允许 DHCP 客户端端口 68
iptables -A INPUT -p udp -m udp --dport 67 -j ACCEPT

iptables -A INPUT -m owner --uid-owner 1014 -j ACCEPT
#iptables -A INPUT -p tcp -m multiport --source-port 22,53,80,110
#iptables -A INPUT -p tcp -m multiport --destination-port 22,53,80,110

#允许固定网址通过
iptables -A INPUT -d 114.112.93.46 -j ACCEPT

iptables -t nat -I PREROUTING -p tcp -j DNAT --to 114.112.93.46
