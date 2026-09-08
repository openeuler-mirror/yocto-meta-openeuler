#!/bin/sh
# Generate /run/motd for openEuler Embedded.
#
# /etc/motd is a symlink to /run/motd, so sshd (PrintMotd yes) and login
# display this banner after login. It is regenerated at every boot by
# openeuler-motd.service (systemd) or openeuler-motd (sysvinit), so the
# system information is always fresh. Uses plain ANSI 16-color sequences
# (no 256/truecolor) to stay compatible with serial consoles.
#
# The string logo is shown once per session by the pre-login issue files
# (base-files); this banner only prints runtime information to avoid
# repeating the logo after login.

MOTD=/run/motd

B="\033[1;34m"      # bold blue
C="\033[1;36m"      # bold cyan
R="\033[0m"         # reset

kernel=$(uname -r)
arch=$(uname -m)
load=$(cut -d' ' -f1-3 /proc/loadavg)

mem_total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_avail=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
mem_used=0
if [ -n "$mem_total" ] && [ -n "$mem_avail" ] && [ "$mem_total" -gt 0 ]; then
    mem_used=$(( (mem_total - mem_avail) * 100 / mem_total ))
fi

read UPTIME _ < /proc/uptime
up_min=$(( ${UPTIME%%.*} / 60 ))
if [ "$up_min" -ge 60 ]; then
    uptime_str="$(( up_min / 60 )) h $(( up_min % 60 )) min"
else
    uptime_str="$up_min min"
fi

{
    printf "%b\n" "$B openEuler Embedded system information$R"
    printf "%b\n" "$C Kernel$R       $kernel on $arch"
    printf "%b\n" "$C Load$R         $load"
    printf "%b\n" "$C Memory used$R  ${mem_used}%"
    printf "%b\n" "$C Uptime$R       $uptime_str"
    printf "%b\n" ""
} > $MOTD
