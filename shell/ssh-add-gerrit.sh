#!/usr/bin/expect

set name [lindex $argv 0]

puts stderr "name=$name"
if {$argc != 1} {
exit 1
}

spawn ssh -l svnserver 192.168.1.8
expect "*password:"
send "svnserver\r"
expect "*password:"
send "svnserver\r"
expect "*$"  
send "/home/svnserver/add_gerrit_user.sh $name\r"
expect "*$"
send "exit\r"

spawn ssh -l k3 192.168.1.7
expect "*password:"
send "k3\r"
expect "*$"  
send "/CODE_LIVE/add_gerrit_user.sh $name\r"
expect "*$"
send "exit\r"

exit

proc usage {} {
    puts stderr "usage: $::argv0 username password ipaddress"
    exit 1
}

proc connect {pass} {
   expect {
       "(yes/no)?" {
           send "yesn"
           expect "*password:" {
                send "$passn"
                expect {
                    "*#" {
                        return 0
                    }
                }
           }
       }
       "*password:" {
           send "$passn"
           expect {
               "*#" {
                   return 0
               }
           }
       }
   }
   return 1
}

if {$argc != 3} { usage }

set username [lindex $argv 0]
set password [lindex $argv 1]
set hostip [lindex $argv 2]

spawn ssh ${username}@${hostip}

if {[connect $password]} {
    exit 1
}

send ""
send "exitn"
expect eof


