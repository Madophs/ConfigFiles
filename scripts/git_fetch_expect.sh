#!/usr/bin/expect -f

set timeout 5

set token [lindex $argv 0]

spawn git fetch

expect "Username for 'https://github.com':"
send -- "madophs\n"

expect "Password for 'https://madophs@github.com':"
send -- "$token\n"

expect eof

send_user "\nDeveloped by Jehú Jair Ruiz Villegas\n"
