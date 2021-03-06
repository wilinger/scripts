#!/bin/bash
# Script to switch DNS forwaring between Pihole and ISP on Edgerouter

if [[ ! "$1" =~ ^(show|pihole|isp)$ ]]; then
  echo "Usage: `basename $0` [pihole|isp|show]
  
  Options:
   pihole - switch DNS forwarding to Pihole
   isp - switch DNS forwarding to ISP
   show - show DNS forwarding nameservers
  "
  exit 0
fi

# Set Internet eth port
eth_port=eth9

# Set Pihole server IP
pihole_ip=10.10.50.50

runcfg=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
runop=/opt/vyatta/bin/vyatta-op-cmd-wrapper

pihole() {  
  echo "Switching to Pihole DNS..."
  $runcfg begin
  $runcfg set interfaces ethernet $eth_port dhcp-options name-server no-update
  $runcfg delete system name-server
  $runcfg delete service dns forwarding dhcp $eth_port
  $runcfg set system name-server 127.0.0.1
  $runcfg set service dns forwarding options strict-order
  $runcfg set service dns forwarding name-server $pihole_ip
  $runcfg commit
  $runcfg save
  $runcfg end
  $runop release dhcp interface $eth_port
  $runop renew dhcp interface $eth_port
  /bin/sleep 10
  $runop show dns forwarding nameservers
}

isp() {
  echo "Switching to ISP DNS..."
  $runcfg begin
  $runcfg set service dns forwarding dhcp $eth_port
  $runcfg delete service dns forwarding name-server $pihole_ip
  $runcfg delete system name-server
  $runcfg commit
  $runcfg save
  $runcfg end
  $runop release dhcp interface $eth_port
  $runop renew dhcp interface $eth_port
  /bin/sleep 10
  $runop show dns forwarding nameservers
}

show() {
  $runop show dns forwarding nameservers
}

# check case
case $1 in 
  pihole)
    pihole
    ;;
  isp)
    isp
    ;;
  show)
    show
    ;;
esac

