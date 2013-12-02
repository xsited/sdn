#!/bin/bash

# 02 JUL 2013  TEK 	First pass static flow pusher for cam demo

OPENFLOW_CONTROLLER="172.16.1.101"
SW1_DPID="08:9E:01:93:5E:AD"
SW2_DPID="08:9E:01:93:5D:13"
SW3_DPID="08:9E:01:93:5D:72"
SW4_DPID="08:9E:01:93:5E:49"


#path1
#SW1_PORT_IN="14"
SW1_PORT_IN="13"
SW1_PORT_OUT_PATH1="15"
SW2_PORT_IN="16"
SW2_PORT_OUT="15"
SW4_PORT_IN_PATH1="16"
SW4_PORT_OUT_CAM2="13"
#SW4_PORT_OUT_CAM1="14"

# iperf path
IPERF_SW1_PORT_IN="14"
IPERF_SW1_PORT_OUT="15"
IPERF_SW2_PORT_IN="16"
IPERF_SW2_PORT_OUT="15"
IPERF_SW4_PORT_IN="16"
IPERF_SW4_PORT_OUT="14"

#path2
SW1_PORT_IN="13"
SW1_PORT_OUT_PATH2="16"
SW3_PORT_IN="15"
SW3_PORT_OUT="16"
SW4_PORT_IN_PATH2="15"
SW4_PORT_OUT_CAM2="13"

INTERNET_PORT_OUT="24"

CLIENT_MAC="74:D0:2B:4C:3D:81"
CLIENT_MAC="ca:56:f8:7e:da:72"
CLIENT_MAC="be:92:14:b6:fe:83"
CLIENT_MAC="00:00:00:00:00:02"

if [ 0 == 1 ] ; then
OPENFLOW_CONTROLLER="127.0.0.1"
SW1_DPID="1"
SW2_DPID="2"
SW3_DPID="3"
SW4_DPID="4"

#mininet 1
SW1_PORT_IN="3"
SW1_PORT_OUT_PATH1="1"
SW2_PORT_IN="1"
SW2_PORT_OUT="2"
SW4_PORT_IN_PATH1="1"
SW4_PORT_OUT_CAM1="4"

# iperf path
IPERF_SW1_PORT_IN="3"
IPERF_SW1_PORT_OUT="2"
IPERF_SW2_PORT_IN="2"
IPERF_SW2_PORT_OUT="3"
IPERF_SW4_PORT_IN="2"
IPERF_SW4_PORT_OUT="4"

#mininet 1 - square
SW1_PORT_IN="1"
SW1_PORT_OUT_PATH1="2"
SW2_PORT_IN="2"
SW2_PORT_OUT="3"
SW4_PORT_IN_PATH1="2"
SW4_PORT_OUT_CAM1="1"

#mininet 2
SW1_PORT_OUT_PATH2="2"
SW3_PORT_IN="1"
SW3_PORT_OUT="2"
SW4_PORT_IN_PATH2="2"
SW4_PORT_OUT_CAM2="3"
SW4_PORT_OUT_CAM2="4"

#mininet 2 - square
SW1_PORT_OUT_PATH2="3"
SW3_PORT_IN="2"
SW3_PORT_OUT="3"
SW4_PORT_IN_PATH2="3"
SW4_PORT_OUT_CAM2="1"


fi

# test-case-match-flow-2t
# 2-tuple (source/destinatation? MAC and VLAN), single port out 
# that should cover what would be an equivalent of an 
# L2 switch in the OpenFlow world

# test-case-match-flow-4t
# 4-tuple, single port out
# L3 flow matching options are:
#   proto tcp, dest port 8080, dest ip,  ingress port, source mac, destination mac

PRIORITY=0

check_return_code() {
ret=`echo ${1}  | grep -c pushed`
if [ ${ret} == 1 ] ; then
	echo "OK"
	echo ${1}
else
	#echo "FAIL"
	echo ${1}
fi
}

#	"src-mac":"'${CLIENT_MAC}'", \

sw1_set_client_path1()
{
NAME="match-flow-out-sw1-path1"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW1_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${SW1_PORT_OUT_PATH1}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-out-sw1-path1-reverse"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW1_PORT_OUT_PATH1}'", \
	"active":"true", \
	"actions":"output='${SW1_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi 
}

#	"src-mac":"'${CLIENT_MAC}'", \
sw1_set_client_path2()
{
NAME="match-flow-out-sw1-path2"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW1_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${SW1_PORT_OUT_PATH2}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

NAME="match-flow-out-sw1-path2-reverse"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW1_PORT_OUT_PATH2}'", \
	"active":"true", \
	"actions":"output='${SW1_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi
}

set_path_sw2()
{

#	"src-mac":"'${CLIENT_MAC}'", \
NAME="match-flow-out-sw2"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW2_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW2_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${SW2_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-out-sw2-reverse"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW2_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW2_PORT_OUT}'", \
	"active":"true", \
	"actions":"output='${SW2_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}

#"src-mac":"'${CLIENT_MAC}'", \
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
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW3_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${SW3_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-out-sw3-reverse"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW3_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW3_PORT_OUT}'", \
	"active":"true", \
	"actions":"output='${SW3_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}


#	"src-mac":"'${CLIENT_MAC}'", \
#	"src-mac":"'${CLIENT_MAC}'", \

sw4_set_cam_path1()
{

NAME="match-flow-out-sw4-path1"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW4_PORT_IN_PATH1}'", \
	"active":"true", \
	"actions":"output='${SW4_PORT_OUT_CAM2}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-out-sw4-path1-reverse"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW4_PORT_OUT_CAM2}'", \
	"active":"true", \
	"actions":"output='${SW4_PORT_IN_PATH1}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi
}


sw4_set_cam_path2()
{

NAME="match-flow-out-sw4-path2"
if [ 1 == 1 ] ; then
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW4_PORT_IN_PATH2}'", \
	"active":"true", \
	"actions":"output='${SW4_PORT_OUT_CAM2}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-out-sw4-path2-reverse"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${SW4_PORT_OUT_CAM2}'", \
	"active":"true", \
	"actions":"output='${SW4_PORT_IN_PATH2}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}

MAC3="74:D0:2B:4C:3D:81"
MAC1="74:D0:2B:4C:3E:8A"
set_iperf_path_sw4()
{
NAME="match-flow-iperf-path-sw4"
echo -n "Push ${NAME}  ${SW4_DPID} : ${IPERF_SW4_PORT_IN} >> ${IPERF_SW4_PORT_OUT} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW4_PORT_IN}'", \
	"src-mac":"'${MAC3}'", \
	"dst-mac":"'${MAC1}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW4_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-iperf-path-sw4-reverse"
echo -n "Push ${NAME}  ${SW4_DPID} : ${IPERF_SW4_PORT_OUT} >> ${IPERF_SW4_PORT_IN} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW4_PORT_OUT}'", \
	"src-mac":"'${MAC1}'", \
	"dst-mac":"'${MAC3}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW4_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

}

set_iperf_path_with_macs()
{
if [ 1 == 1 ] ; then
PRIORITY=0
NAME="match-flow-iperf-path-sw1"
echo -n "Push ${NAME} ${SW1_DPID} : ${IPERF_SW1_PORT_IN} >> ${IPERF_SW1_PORT_OUT} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW1_PORT_IN}'", \
	"src-mac":"'${MAC3}'", \
	"dst-mac":"'${MAC1}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW1_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-iperf-path-sw1-reverse"
echo -n "Push ${NAME}  ${SW1_DPID} : ${IPERF_SW1_PORT_OUT} >> ${IPERF_SW1_PORT_IN} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW1_PORT_OUT}'", \
	"src-mac":"'${MAC1}'", \
	"dst-mac":"'${MAC3}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW1_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"



NAME="match-flow-iperf-path-sw2"
echo -n "Push ${NAME}  ${SW2_DPID} : ${IPERF_SW2_PORT_IN} >> ${IPERF_SW2_PORT_OUT} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW2_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW2_PORT_IN}'", \
	"src-mac":"'${MAC3}'", \
	"dst-mac":"'${MAC1}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW2_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-iperf-path-sw2-reverse"
echo -n "Push ${NAME}  ${SW2_DPID} : ${IPERF_SW2_PORT_OUT} >> ${IPERF_SW2_PORT_IN} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW2_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW2_PORT_OUT}'", \
	"src-mac":"'${MAC1}'", \
	"dst-mac":"'${MAC3}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW2_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"


NAME="match-flow-iperf-path-sw4"
echo -n "Push ${NAME}  ${SW4_DPID} : ${IPERF_SW4_PORT_IN} >> ${IPERF_SW4_PORT_OUT} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW4_PORT_IN}'", \
	"src-mac":"'${MAC3}'", \
	"dst-mac":"'${MAC1}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW4_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-iperf-path-sw4-reverse"
echo -n "Push ${NAME}  ${SW4_DPID} : ${IPERF_SW4_PORT_OUT} >> ${IPERF_SW4_PORT_IN} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW4_PORT_OUT}'", \
	"src-mac":"'${MAC1}'", \
	"dst-mac":"'${MAC3}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW4_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

fi

}



set_iperf_path()
{

if [ 1 == 1 ] ; then
PRIORITY=0
NAME="match-flow-iperf-path-sw1"
echo -n "Push ${NAME} ${SW1_DPID} : ${IPERF_SW1_PORT_IN} >> ${IPERF_SW1_PORT_OUT} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW1_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW1_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-iperf-path-sw1-reverse"
echo -n "Push ${NAME}  ${SW1_DPID} : ${IPERF_SW1_PORT_OUT} >> ${IPERF_SW1_PORT_IN} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW1_PORT_OUT}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW1_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-iperf-path-sw2"
echo -n "Push ${NAME}  ${SW2_DPID} : ${IPERF_SW2_PORT_IN} >> ${IPERF_SW2_PORT_OUT} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW2_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW2_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW2_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-iperf-path-sw2-reverse"
echo -n "Push ${NAME}  ${SW2_DPID} : ${IPERF_SW2_PORT_OUT} >> ${IPERF_SW2_PORT_IN} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW2_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW2_PORT_OUT}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW2_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-iperf-path-sw4"
echo -n "Push ${NAME}  ${SW4_DPID} : ${IPERF_SW4_PORT_IN} >> ${IPERF_SW4_PORT_OUT} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW4_PORT_IN}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW4_PORT_OUT}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-iperf-path-sw4-reverse"
echo -n "Push ${NAME}  ${SW4_DPID} : ${IPERF_SW4_PORT_OUT} >> ${IPERF_SW4_PORT_IN} ... "
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"'${PRIORITY}'",  \
	"ingress-port":"'${IPERF_SW4_PORT_OUT}'", \
	"active":"true", \
	"actions":"output='${IPERF_SW4_PORT_IN}'"\
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

fi

}

delete_flowmod()
{

if [ 1 == 1 ] ; then
NAME=$1
echo -n "Delete ${NAME} ..."
ret_code=`curl -s -X DELETE -d \
    '{"name":"'${NAME}'"}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}


delete_path1()
{

delete_flowmod "match-flow-out-sw4-path1"
delete_flowmod "match-flow-out-sw4-path1-reverse"
#delete_flowmod "match-flow-out-sw2-path1"
#delete_flowmod "match-flow-out-sw3-path1-reverse"
delete_flowmod "match-flow-out-sw2"
delete_flowmod "match-flow-out-sw2-reverse"
delete_flowmod "match-flow-out-sw1-path1"
delete_flowmod "match-flow-out-sw1-path1-reverse"

if [ 0 == 1 ] ; then
NAME="match-flow-out-sw4-path1"
echo -n "Delete ${NAME} ..."
ret_code=`curl -s -X DELETE -d \
    '{"name":"'${NAME}'"}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

NAME="match-flow-out-sw4-path1-reverse"
echo -n "Delete ${NAME} ..."
ret_code=`curl -s -X DELETE -d \
    '{"name":"'${NAME}'"}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`

check_return_code "${ret_code}"
NAME="match-flow-out-sw1-path1"
echo -n "Delete ${NAME} ..."
ret_code=`curl -s -X DELETE -d \
    '{"name":"'${NAME}'"}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

NAME="match-flow-out-sw1-path1-reverse"
echo -n "Delete ${NAME} ..."
ret_code=`curl -s -X DELETE -d \
    '{"name":"'${NAME}'"}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

fi

}

delete_path2()
{
delete_flowmod "match-flow-out-sw4-path2"
delete_flowmod "match-flow-out-sw4-path2-reverse"
delete_flowmod "match-flow-out-sw3"
delete_flowmod "match-flow-out-sw3-reverse"
#delete_flowmod "match-flow-out-sw3-path2"
#delete_flowmod "match-flow-out-sw3-path2-reverse"
delete_flowmod "match-flow-out-sw1-path2"
delete_flowmod "match-flow-out-sw1-path2-reverse"

if [ 0 == 1 ] ; then

NAME="match-flow-out-sw4-path2"
echo -n "Delete ${NAME} ..."
ret_code=`curl -s -X DELETE -d \
    '{"name":"'${NAME}'"}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

NAME="match-flow-out-sw4-path2-reverse"
echo -n "Delete ${NAME} ..."
ret_code=`curl -s -X DELETE -d \
    '{"name":"'${NAME}'"}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

NAME="match-flow-out-sw1-path2"
echo -n "Delete ${NAME} ..."
ret_code=`curl -s -X DELETE -d \
    '{"name":"'${NAME}'"}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

NAME="match-flow-out-sw1-path2-reverse"
echo -n "Delete ${NAME} ..."
ret_code=`curl -s -X DELETE -d \
    '{"name":"'${NAME}'"}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

fi

}


set_sw1_route_internet()
{

if [ 1 == 1 ] ; then
NAME="match-flow-out-sw1-internet"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", "priority":"100", \
	"ether-type":"0x0800", \
	"dst-ip":"192.168.200.254", \
	"active":"true", \
	"actions":"output='${INTERNET_PORT_OUT}'"\
	}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
NAME="match-flow-in-sw1-internet"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
	"cookie":"0", "priority":"100", \
	"ingress-port":"'${INTERNET_PORT_OUT}'", \
	"active":"true", \
        "actions":"output=normal" \
	}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}

set_sw1_output_normal()
{

if [ 1 == 1 ] ; then
NAME="match-flow-out-sw1-normal"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
    "switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
    "cookie":"0", \
    "priority":"500", \
    "active":"true", \
    "actions":"output=normal" \
	}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}



set_sw1_output_flood()
{

if [ 1 == 1 ] ; then
NAME="match-flow-out-sw1-flood"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
    "switch": "'${SW1_DPID}'",\
	"name":"'${NAME}'", \
    "cookie":"0", \
    "priority":"600", \
    "active":"true", \
    "actions":"output=flood" \
	}' \
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"
fi

}


examples_for_documentation()
{

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
}

echo ""
echo ""

rewrite_rule_delete()
{
delete_flowmod "match-flow-out-sw4-rewrite"
delete_flowmod "match-flow-out-sw4-rewrite-reverse"
set_iperf_path_sw4
}



REWRITE_IPADDR_OUT="192.168.200.100"
REWRITE_IPADDR_IN="192.168.200.105"
MACW="28:D2:44:12:A2:D9"

rewrite_rule_add()
{
#IPERF_SW4_PORT_IN="16"
#SW4_PORT_OUT_CAM2="13"
    delete_flowmod "match-flow-iperf-path-sw4"
    delete_flowmod "match-flow-iperf-path-sw4-reverse"

        #"actions":"set-dst-ip='${REWRITE_IPADDR_IN}',set-dst-mac='${MACW}',output='${SW4_PORT_OUT_CAM2}'" \
        #"actions":"set-dst-ip='${REWRITE_IPADDR_IN}',output='${SW4_PORT_OUT_CAM2}'" \
NAME="match-flow-out-sw4-rewrite"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'", \
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"1", \
	"src-mac":"'${MAC3}'", \
	"dst-mac":"'${MAC1}'", \
	"ingress-port":"'${IPERF_SW4_PORT_IN}'", \
	"active":"true", 
        "actions":"set-dst-ip='${REWRITE_IPADDR_IN}',set-dst-mac='${MACW}',output='${SW4_PORT_OUT_CAM2}'" \
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

        # "actions":"set-src-ip='${REWRITE_IPADDR_OUT}',output='${IPERF_SW4_PORT_IN}'" \
NAME="match-flow-out-sw4-rewrite-reverse"
echo -n "Push ${NAME} ..."
ret_code=`curl -s -d \
	'{\
	"switch": "'${SW4_DPID}'", \
	"name":"'${NAME}'", \
	"cookie":"0", \
	"priority":"1", \
	"dst-mac":"'${MAC3}'", \
	"src-mac":"'${MACW}'", \
	"ingress-port":"'${SW4_PORT_OUT_CAM2}'", \
	"active":"true", \
        "actions":"set-src-ip='${REWRITE_IPADDR_OUT}',set-src-mac='${MAC1}',output='${IPERF_SW4_PORT_IN}'" \
	}'\
 http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/json`
check_return_code "${ret_code}"

}


firewall_status()
{
echo ""
echo -n "Floodlight Firewall Module is "
status=`curl -s http://${OPENFLOW_CONTROLLER}:8080/wm/firewall/module/status/json | grep firewall | awk '{print $4}'`
#status=${status:1:7}
echo $status | cut -d "\"" -f 1
echo ""
}

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
echo " Flow Menu    "
echo " =========    "
echo " 1) Set Flow Path 1 (Orange) ..."
echo " 2) Set Flow Path 2 (Red) ..."
echo " 3) Set Flow Path 3 with MAC (Yellow) ..."
echo " ========================================"
echo " 4) List Flow Entries ..."
echo " 5) Delete ALL Flow Entries ..."
echo " 6) Delete Flow Path 3 (Yellow) ..."
echo " 7) Firewall Status ..."
echo " 8) Set Flow Path 3 no MAC (Yellow) ..."
echo "" 
echo " 9) Set Switch 1 Output Normal ..."
echo "10) Delete Switch 1 Output Normal ..."
echo "" 
echo "11) Set Switch 1 Output Flood ..."
echo "12) Delete Switch 1 Output Flood ..."
echo "" 
echo "13) Which Path?"
echo "14) Set Internet Path ..."
echo "15) Delete Internet Path ..."
echo "" 
#echo "16) Toggle Path Between 1 and 2 ..."
#echo "18) Delete Switch 2 Path1 Flows ..."
#echo "19) Delete Switch 3 Path2 Flows ..."
#echo "20) Rewrite Path 3 to Path 1 CAM ..."
#echo "21) Delete Rewrite Path 3 to Path 1 CAM ..."
#echo "19) Delete Switch 3 Path2 Flows ..."

echo "30) (Q)uit"
echo -n "Make choice [ENTER]: "


}

#        curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/clear/${SW1_DPID}/json
#        curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/clear/${SW4_DPID}/json
#  echo "Delete All rules ..."
#  curl http://${OPENFLOW_CONTROLLER}:8080/wm/staticflowentrypusher/clear/all/json
  #  delete_flowmod "match-flow-out-sw4-path1"
  #  delete_flowmod "match-flow-out-sw4-path1-reverse"
  #  delete_flowmod "match-flow-out-sw1-path1"
  #  delete_flowmod "match-flow-out-sw1-path1-reverse"

set_path1()
{
    echo "Delete any path 2 rules ..."
    delete_path2
    echo "Set Full Flow Path 1 ..."
    sw1_set_client_path1
    set_path_sw2
    sw4_set_cam_path1
    current_path=1
}

set_path2()
{
    echo "Delete any path 1 rules ..."
    delete_path1
    echo "Set Full Flow Path 2 ..."
    sw1_set_client_path2
    set_path_sw3
    sw4_set_cam_path2
    current_path=2
}

delete_iperf_path()
{
    delete_flowmod "match-flow-iperf-path-sw1"
    delete_flowmod "match-flow-iperf-path-sw2"
    delete_flowmod "match-flow-iperf-path-sw4"
    delete_flowmod "match-flow-iperf-path-sw1-reverse"
    delete_flowmod "match-flow-iperf-path-sw2-reverse"
    delete_flowmod "match-flow-iperf-path-sw4-reverse"
}

# main()
echo ""
echo ""


MAX=11
current_path=0
#set_iperf_path

if [ "$1" == "set_path1" ]; then
    set_path1
    exit
fi
if [ "$1" == "set_path2" ]; then
    set_path2
    exit
fi


clear

while :
do
menu_list
read instnum
case "$instnum" in
  1)  
    set_path1
    ;;
  2)  
    set_path2
    ;;
  16) 
    if [ $current_path -eq 1 ]; then
        set_path2
    else
        set_path1
    fi
    current_path=`expr 3 - $current_path`
    ;;
  4) 
    flow_table_list
    ;;
  5) 
    flow_table_delete
    ;;
  7) 
    firewall_status
    ;;
  6) 
    delete_iperf_path
    ;;
  14) 
    set_sw1_route_internet
    ;;
  9) 
    set_sw1_output_normal
    ;;
  10) 
    delete_flowmod "match-flow-out-sw1-normal"
    ;;
  11) 
    set_sw1_output_flood
    ;;
  12) 
    delete_flowmod "match-flow-out-sw1-flood"
    ;;
  13) 
    if [ 0 == $current_path ] ; then
        echo "Current Path = Unkown"
    else
        echo "Current Path = $current_path"
    fi
    ;;
  15) 
    delete_flowmod "match-flow-out-sw1-internet"
    delete_flowmod "match-flow-in-sw1-internet"
    ;;
  8) 
    set_iperf_path
    ;;
  3) 
    set_iperf_path_with_macs
    ;;
  18) 
    # debug tool
    delete_flowmod "match-flow-out-sw2"
    delete_flowmod "match-flow-out-sw2-reverse"
    ;;
  19)
    # debug tool
    delete_flowmod "match-flow-out-sw3"
    delete_flowmod "match-flow-out-sw3-reverse"
    ;;
  20)
    rewrite_rule_add
    ;;
  21)
    rewrite_rule_delete
    ;;

  q | Q | 30) exit
   ;;
  *) echo "Option number $instnum is not valid"
   ;;
esac

done

