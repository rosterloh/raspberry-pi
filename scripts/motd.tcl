#!/usr/bin/env tclsh
# MOTD script original? / mod mewbies.com
# /etc/motd.tcl
# Setup steps:
# * empty /etc/motd
# * comment "uname -snrvm > /var/run/motd.dynamic" out of /etc/init.d/motd
# * Change from "PrintLastLog yes" to "PrintLastLog no" in /etc/ssh/sshd_config
# * add "/etc/motd.tcl" to /etc/profile

# * Variables
set var(user) $env(USER)
set var(path) $env(PWD)
set var(home) $env(HOME)

# * Check if we're somewhere in /home
#if {![string match -nocase "/home*" $var(path)]} {
if {![string match -nocase "/home*" $var(path)] && ![string match -nocase "/usr/home*" $var(path)] } {
  return 0
}

# * Calculate last login
set lastlog [exec -- lastlog -u $var(user)]
set ll(1)  [lindex $lastlog 7]
set ll(2)  [lindex $lastlog 8]
set ll(3)  [lindex $lastlog 9]
set ll(4)  [lindex $lastlog 10]
set ll(5)  [lindex $lastlog 6]

# * Calculate current system uptime
set uptime    [exec -- /usr/bin/cut -d. -f1 /proc/uptime]
set up(days)  [expr {$uptime/60/60/24}]
set up(hours) [expr {$uptime/60/60%24}]
set up(mins)  [expr {$uptime/60%60}]
set up(secs)  [expr {$uptime%60}]

# * Calculate usage of home directory
set usage [lindex [exec -- /usr/bin/du -ms $var(home)] 0]

# * Calculate SSH logins:
set logins    [lindex [exec -- who -q | cut -c "9-11"] 0]

# * Calculate processes
set psu [lindex [exec -- ps U $var(user) h | wc -l] 0]
set psa [lindex [exec -- ps -A h | wc -l] 0]

# * Calculate current system load
set loadavg     [exec -- /bin/cat /proc/loadavg]
set sysload(1)  [lindex $loadavg 0]
set sysload(5)  [lindex $loadavg 1]
set sysload(15) [lindex $loadavg 2]

# * Calculate Memory
set memory  [exec -- free -m]
set mem(t)  [lindex $memory 7]
set mem(u)  [lindex $memory 8]
set mem(f)  [lindex $memory 9]
set mem(c)  [lindex $memory 16]
set mem(s)  [lindex $memory 19]


# * ascii berry
set head {          .~ .~~~..~.                      _                          _ 
         : .~.'~'.~. :     ___ ___ ___ ___| |_ ___ ___ ___ _ _    ___|_|
        ~ (   ) (   ) ~   |  _| .'|_ -| . | . | -_|  _|  _| | |  | . | |
       ( : '~'.~.'~' : )  |_| |__,|___|  _|___|___|_| |_| |_  |  |  _|_|
        ~ .~ (   ) ~. ~               |_|                 |___|  |_|    
         (  : '~' :  )
          '~ .~~~. ~'
              '~'}
# * ascii leaf
set head2 {
          .~~.   .~~.
         '. \ ' ' / .'}
# * display kernel version
set uname [exec -- /bin/uname -snrvm]
set unameoutput0 [lindex $uname 0]
set unameoutput [lindex $uname 1]
set unameoutput2 [lindex $uname 2]
set unameoutput3 [lindex $uname 3]
set unameoutput4 [lindex $uname 4]
# * display temperature
set temp [exec -- /opt/vc/bin/vcgencmd measure_temp | cut -c "6-9"]
set tempoutput [lindex $temp 0]
# * display GPU version
set gpu [exec -- /opt/vc/bin/vcgencmd version]
set gpuoutput [lindex $gpu 0]
set gpuoutput1 [lindex $gpu 1]
set gpuoutput2 [lindex $gpu 2]
set gpuoutput3 [lindex $gpu 8]
set gpuoutput4 [lindex $gpu 9]

# * Print Results
puts "\033\[01;32m$head2\033\[0m"
puts "\033\[02;31m$head\033\[0m"
puts "   System........: $unameoutput0 $unameoutput $unameoutput2 $unameoutput3 $unameoutput4"
puts "   GPU Version...: $gpuoutput $gpuoutput1 $gpuoutput2, $gpuoutput3 $gpuoutput4"
puts "   Last Login....: $ll(1) $ll(2) $ll(3) $ll(4) from $ll(5)"
puts "   Uptime........: $up(days)days $up(hours)hours $up(mins)minutes $up(secs)seconds"
puts "   Temperature...: $tempoutput C"
puts "   Load..........: $sysload(1) (1minute) $sysload(5) (5minutes) $sysload(15) (15minutes)"
puts "   Memory MB.....: Total: $mem(t)  Used: $mem(u)  Free: $mem(f)  Cached: $mem(c)  Swap: $mem(s)"
puts "   Disk Usage....: You're using ${usage}MB in $var(home)"
puts "   SSH Logins....: Currently $logins user(s) logged in."
puts "   Processes.....: You're running ${psu} which makes a total of ${psa} running"

if {[file exists /etc/changelog]&&[file readable /etc/changelog]} {
  puts " . .. More or less important system informations:\n"
  set fp [open /etc/changelog]
  while {-1!=[gets $fp line]} {
    puts "  ..) $line"
  }
  close $fp
  puts ""
}
