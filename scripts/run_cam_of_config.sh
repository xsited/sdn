#!/bin/bash

# 02 JUL 2013  TEK 	First pass static flow pusher for cam demo

OPENFLOW_CONTROLLER="172.16.1.101"
SW1_DPID="08:9E:01:93:5E:AD"
SW2_DPID="08:9E:01:93:5D:13"
SW3_DPID="08:9E:01:93:5D:72"
SW4_DPID="08:9E:01:93:4A:49"

SW1_PORT_IN="13"
SW1_PORT_OUT_PATH1="15"
SW1_PORT_OUT_PATH2="16"
SW2_PORT_IN="16"
SW2_PORT_OUT="15"
SW3_PORT_IN="15"
SW3_PORT_OUT="16"
SW4_PORT_IN_PATH1="16"
SW4_PORT_IN_PATH2="15"
SW4_PORT_OUT-CAM1="14"
SW4_PORT_OUT-CAM2="13"

CLIENT_MAC="74:D0:2B:4C:3D:81"

# test-case-match-flow-2t
# 2-tuple (source/destinatation? MAC and VLAN), single port out 
# that should cover what would be an equivalent of an 
# L2 switch in the OpenFlow world

# test-case-match-flow-4t
# 4-tuple, single port out
# L3 flow matching options are:
#   proto tcp, dest port 8080, dest ip,  ingress port, source mac, destination mac



check_return_code() {
ret=`echo ${1}  | grep -c pushed`
if [ ${ret} == 1 ] ; then
	echo "OK"
else
	echo "FAIL"
	echo ${1}
fi
}

sw1_set_client_path1()
{
NAME="match-flow-2tuple-out-path1"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"1024",  \
	"src-mac":"'${CLIENT_MAC}'", \
	"ingress-port":"'${SW1_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${SW1_PORT_OUT_PATH1}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi 
}

sw1_set_client_path2()
{
NAME="match-flow-2tuple-out-path2"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"2048",  \
	"src-mac":"'${CLIENT_MAC}'", \
	"ingress-port":"'${SW1_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${SW1_PORT_OUT_PATH2}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi
}

set_path_sw2()
{

NAME="match-flow-out-sw2"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW2_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"2048",  \
	"src-mac":"'${CLIENT_MAC}'", \
	"ingress-port":"'${SW2_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${SW2_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}

set_path_sw3()
{

NAME="match-flow-out-sw3"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW3_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"2048",  \
	"src-mac":"'${CLIENT_MAC}'", \
	"ingress-port":"'${SW3_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${SW3_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}


set_path_sw4()
{

NAME="match-flow-out-sw4-path1"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"2048",  \
	"src-mac":"'${CLIENT_MAC}'", \
	"ingress-port":"'${SW4_PORT_IN_PATH1}'", \
	"active":"true", \
	"actions":"output='${SW4_PORT_OUT_CAM1}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

NAME="match-flow-out-sw4-path2"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"2048",  \
	"src-mac":"'${CLIENT_MAC}'", \
	"ingress-port":"'${SW4_PORT_IN_PATH2}'", \
	"active":"true", \
	"actions":"output='${SW4_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}




# json_string=\
#	}'
# echo ${json_string}
#ret_code=`eval "curl -s -d '${json_string}' http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json"`

# out
# output	 <number> all controller local ingress-port normal flood no "drop" option (instead, specify no action to drop packets) 
# enqueue	 <number>:<number>	 First number is port number, second is queue ID  Can be hexadecimal (with leading 0x) or decimal
# strip-vlan	 	 
# set-vlan-id	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# set-vlan-priority	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# set-src-mac	 <mac address>	 xx:xx:xx:xx:xx:xx
# set-dst-mac	 <mac address>	 xx:xx:xx:xx:xx:xx
# set-tos-bits	 <number>	 
# set-src-ip	 <ip address>	 xx.xx.xx.xx
# set-dst-ip	 <ip address>	 xx.xx.xx.xx
# set-src-port	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# set-dst-port	 <number>	 Can be hexadecimal (with leading 0x) or decimal


# in
# ingress-port	 <number>	 switch port on which the packet is received  Can be hexadecimal (with leading 0x) or decimal
# src-mac	 <mac address>	 xx:xx:xx:xx:xx:xx
# dst-mac	 <mac address>	 xx:xx:xx:xx:xx:xx
# vlan-id	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# vlan-priority	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# ether-type	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# tos-bits	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# protocol	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# src-ip	 <ip address>	 xx.xx.xx.xx
# dst-ip	 <ip address>	 xx.xx.xx.xx
# src-port	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# dst-port	 <number>	 Can be hexadecimal (with leading 0x) or decimal
# "dst-mac":"dd:d2:32:00:ec:07", "src-mac":"00:21:cc:18:12:af", "vlan-id":"0x2", "ingress-port":"'${PORT_OUT}'", "vlan-priority":"0x01", "ether-type":"0x0800", "tos-bits":"0x01", "protocol":"0x01", "src-ip":"1.1.1.1", "dst-ip":"2.2.2.2", "src-port":"8888", "dst-port": "8888",

if [ 1 == 0 ] ; then
echo -n "Push test-case-match-flow-8t ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SWITCH_DPID}'",\
	"name":"test-case-match-flow-8t",\
	"cookie":"0", "priority":"1000", \
	"dst-mac":"dd:d2:32:00:ec:07", \
	"src-mac":"00:21:cc:18:12:af", \
	"vlan-id":"0x2", \
	"ingress-port":"'${PORT_IN}'", \
	"ether-type":"0x0800", \
	"src-ip":"2.1.1.1", \
	"dst-ip":"3.2.2.2", \
	"src-port":"8888", \
	"dst-port":"8888", \
	"active":"true", \
	"actions":"output='${PORT_OUT}'"\
	}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

if [ 1 == 0 ] ; then
# if one or the other or both of these is added for matching the rule is pushed
	# "tos-bits":"0x00", \
	# "protocol":"0x00", \
# echo "${ret_code}" returns {"status" : "Entry pushed"} but there is no rule on the switch
# is it floodlight or the switch? 
# is there another sequence of attributes that can make 12-tuple?

echo -n "Push test-5.2-flow-12t-x ... "
ret_code=`curl -s -d \
        '{\
        "switch": "'${SWITCH_DPID}'", \
        "name":"test-5.2-flow-12t-x", \
        "cookie":"0", \
        "priority":"1", \
        "dst-mac":"00:00:00:00:ec:07", \
        "src-mac":"00:00:00:00:12:af", \
        "ingress-port":"'${PORT_IN}'", \
        "vlan-id":"0x2", \
        "vlan-priority":"0x01", \
        "ether-type":"0x0800", \
        "tos-bits":"0xC0", \
        "protocol":"0x01", \
        "src-ip":"1.1.1.1", \
        "dst-ip":"2.2.2.2", \
        "src-port":"8888", \
        "dst-port":"8888", \
        "active":"true",
        "actions":"output='${PORT_OUT}'"\
        }'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"



echo -n "Push test-case-match-f1ow-12tx ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SWITCH_DPID}'", \
	"name":"test-case-match-flow-12tx", \
	"cookie":"0", \
	"priority":"7777", \
	"dst-mac":"00:00:00:11:ec:07", \
	"src-mac":"00:22:00:00:12:af", \
	"ingress-port":"'${PORT_IN}'", \
	"ether-type":"0x0800", \
	"vlan-priority":"0x00", \
	"vlan-id":"-1", \
	"tos-bits":"0xC0", \
	"protocol":"17", \
	"src-ip":"1.1.1.1", \
	"dst-ip":"2.2.2.2", \
	"src-port":"8888", \
	"dst-port":"8888", \
	"active":"true", 
	"actions":"output='${PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
# echo "${ret_code}"
fi 

echo ""
echo ""





flow_table_delete()
{

echo -n "Delete all flow table entries [y/N]?"
read c
if [  "x$c" != "x" ]; then
if [ "$c" = "Y" ] || [ "$c" = "y" ]; then
	curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/clear/all/json
fi
fi

}

flow_table_list()
{
echo "List flow table ..."
echo ""
echo ""

# get flow table
if [ 1 == 1 ] ; then
curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/list/${SW1_DPID}/json
curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/list/${SW2_DPID}/json
curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/list/${SW3_DPID}/json
curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/list/${SW4_DPID}/json
echo ""
fi
}


menu_list()
{
echo "1) Set Static Flow Entries ..."
echo "2) Set Flow Path 1 Entries ..."
echo "3) Set Flow Path 2 Entries ..."
echo "4) List Flow Entries ..."
echo "5) Delete Flow Entries ..."
echo "6) Quit"
echo -n "Make choice [ENTER]: "


}

MAX=7

while :
do
menu_list
read instnum
if [ $instnum -gt 0 ]; then
if [ $instnum -lt $MAX ]; then
case "$instnum" in
  1)  
    echo "Set Static Flow Entries ..."
    set_path_sw2
    set_path_sw3
    set_path_sw4
    ;;
  2)  
    echo "Set Flow Path 1 Entries ..."
    curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/clear/${SW1_DPID}/json
    sw1_set_client_path1
    ;;
  3)  
    echo "Set Flow Path 2 Entries ..."
    curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/clear/${SW1_DPID}/json
    sw1_set_client_path2
    ;;
  4) 
    flow_table_list
    ;;
  5) 
    flow_table_delete
    ;;
  6) exit
   ;;
  *) echo "Option number $instnum is not valid"
   ;;
esac

fi
fi
done

