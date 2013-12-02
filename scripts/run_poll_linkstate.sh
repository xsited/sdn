#!/bin/bash

port_state=99999

get_switchport()
{
count=0
#echo "Get switch $1 port $2" 
#sleep 2

for j in `curl -s http://localhost:8080/wm/core/controller/switches/json | python jsongrep.py . dpid` ; do
#    echo "Switch: $j"
    sw=`echo $j |  sed "s/'//g" | sed "s/u//g"`
#    echo "Looking at switch *$sw* and *$1*" 
#sleep 2
    if [ "$sw" == "$1" ]; then
#    echo "Found switch *$sw* and *$1*" 
#sleep 2
#        echo "Indexing switch $sw port $2 index $count" 
	# get_linkstate $count $2
	#status=$?
	status=`get_linkstate $count $2`
	echo $status
	return 
    fi
    count=`expr $count + 1`
done
}

# dpid=`curl -s http://localhost:8080/wm/core/controller/switches/json | python jsongrep.py 2 dpid | sed "s/'//g" | sed "s/u//g"`

get_linkstate()
{
#echo "Switch index $1 port $2"
count=0
for i in `curl -s http://localhost:8080/wm/core/controller/switches/json | python jsongrep.py $1 ports . portNumber`; do 
#    echo "For i=$i"
    if [ $i == $2 ]; then 
#	echo "Switch index $1 found $2 port $i at index $count"
        port_state=`curl -s http://localhost:8080/wm/core/controller/switches/json | python jsongrep.py $1 ports $count state`;
        echo $port_state 
	# port_state=$?
	return 
    fi 
    count=`expr $count + 1`
done
}

# a mininet version
SW1_DPID="00:00:00:00:00:00:00:01"
SW1_PORT="65534"
SW1_PORT="2"
SW2_DPID="00:00:00:00:00:00:00:04"
SW2_PORT="2"

# summer demo version
SW1_DPID="00:00:08:9e:01:93:5e:ad"
SW2_DPID="00:00:08:9e:01:93:5d:13"
SW1_PORT=15
SW2_PORT=16

# alternate setup version
SW1_DPID="00:00:08:9e:01:a8:01:66"
SW2_DPID="00:00:08:9e:01:a8:00:99"
SW1_PORT=15
SW2_PORT=16


# `curl -s http://localhost:8080/wm/core/controller/switches/json | python jsongrep.py 1 ports . portNumber`
flipped=0
while [ 1 ]; do
    #sw1port15=`get_switchport "00:00:00:00:00:00:00:01" 65534`
    #echo "Switch $SW1_DPID Port $SW1_PORT"
    sw1port15=`get_switchport $SW1_DPID $SW1_PORT`
    #sw1port15=$?
    echo "sw1 port15 link state=$sw1port15"
    #echo "return1 = $port_state"
    #get_switchport "00:00:00:00:00:00:00:04" 3
    sw2port16=`get_switchport $SW2_DPID $SW2_PORT`
    #sw2port16=$?
    echo "sw2 port16 link state=$sw2port16"
    #echo "return0 = $sw2port16"
    #echo "return1 = $port_state"
#    sleep 5
#done
#while [ 1 ]; do
    if [ $flipped == 0 ]; then
    echo "Flipped=$flipped"
    if [ $sw1port15 == 1 ]; then
	echo "SW1 Port 15 LinkDown on path 1.  Change to path 2."
	./run_sdnapp_menu.sh "set_path2"
	flipped=1
        sleep 5
    else
    if [ $sw2port16 == 1 ]; then
	echo "SW2 Port 16 LinkDown on path 1.  Change to path 2."
	./run_sdnapp_menu.sh "set_path2"
	flipped=1
        sleep 5
    fi
    fi
    else
    #fi
    #if [ $flipped == 1 ]; then
    echo "Flipped=$flipped"
    if [ $sw1port15 == 0 ]; then
	echo "SW 1 LinkUp on path 1. Change to path 1."
	./run_sdnapp_menu.sh "set_path1"
        flipped=0
        sleep 5
    else
    if [ $sw2port16 == 0 ]; then
	echo "SW 2 LinkUp on path 1. Change to path 1."
	./run_sdnapp_menu.sh "set_path1"
        flipped=0
        sleep 5
    fi
    fi
    fi
    sleep 2
done
