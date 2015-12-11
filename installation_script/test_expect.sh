#!/usr/bin/expect -f

spawn ssh surveyor@192.168.0.118
expect "password: "
send "plumpynut\r"

# put the appropriate key string into the .../.ssh/authorized_keys file

expect "$ "
send "exit\r"


