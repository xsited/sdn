#!/bin/bash

# VAR="hello"
# if [ -n "$VAR" ]; then
#     echo "VAR is not empty"
# fi
# 
# Similarly, the -z operator checks whether the string is null. ie:
# 
#VAR=""
#if [ -z "$VAR" ]; then
#    echo "VAR is empty"
#fi
#
#if [ $instnum -gt 0 ]; then
#if [ $instnum -lt $MAX ]; then
#fi
#fi

ovspath="/ovs/bin/"
ipaddr="172.16.1.2"
port="16"
speed="10M"

#x=""
echo -n "Switch ip [$ipaddr]: "
read x
if [ -n "$x" ]; then
ipaddr=$x
fi

#echo "IP $ipaddr"

echo -n "Switch port [$port]: "
read x
if [ -n "$x" ]; then
port=$x
fi

#echo "Port $port"

c="N"
echo -n "Reset port only? [N/y]? "
read c

if [ "$c" = "Y" ] || [ "$c" = "y" ]; then

LIMIT=""

else

echo -n "Switch port speed [$speed]: "
read x

if [ -n "$x" ]; then
speed=$x
fi

LIMIT=" options:link_speed=${speed}"
#echo "Limit $LIMIT"

fi
user="root"
#user="mininet"
#ovspath="/usr/bin/"
cmd1="${ovspath}/ovs-vsctl --db=tcp:${ipaddr}:6633 del-port br0 ge-1/1/${port}"
cmd2="${ovspath}/ovs-vsctl --db=tcp:${ipaddr}:6633 add-port br0 ge-1/1/${port} -- set interface ge-1/1/${port} type=pica8 ${LIMIT}"
cmd3="${ovspath}/ovs-vsctl  --db=tcp:${ipaddr}:6633 show"
#echo "ssh ${user}@${ipaddr} ${cmd}"
#ssh ${user}@${ipaddr} ${cmd}


ssh -t -t ${user}@${ipaddr} <<END
$cmd1
$cmd2
$cmd3
/sbin/ifconfig -a
exit
END


# To rate limit vm0 interface tap0 to 1 Mbps, run:

#ovs-vsctl set Interface tap0 ingress_policing_rate=1000
#ovs-vsctl set Interface tap0 ingress_policing_burst=100

# Similarly, to limit vm1 interface tap1 to 10 Mbps, run:

# ovs-vsctl set Interface tap1 ingress_policing_rate=10000
# ovs-vsctl set Interface tap1 ingress_policing_burst=1000

