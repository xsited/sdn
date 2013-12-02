
__author__ = 'keecode'
import httplib
import json

class StaticFlowPusher(object):

    def __init__(self, server):
        self.server = server

    def get(self, data):
        ret = self.rest_call({}, 'GET')
        return json.loads(ret[2])

    def set(self, data):
        ret = self.rest_call(data, 'POST')
        return ret[0] == 200

    def remove(self, objtype, data):
        ret = self.rest_call(data, 'DELETE')
        return ret[0] == 200

    def rest_call(self, data, action):
        path = '/wm/staticflowentrypusher/json'
        headers = {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            }
        body = json.dumps(data)
        conn = httplib.HTTPConnection(self.server, 8080)
        conn.request(action, path, body, headers)
        response = conn.getresponse()
        ret = (response.status, response.reason, response.read())
        print ret
        conn.close()
        return ret


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

PRIORITY=0

flow1 = {
    'switch':"00:00:00:00:00:00:00:01",
    "name":"flow-mod-1",
    "cookie":"0",
    "priority":"32768",
    "ingress-port":"1",
    "active":"true"
}


NAME="match-flow-out-sw1-path1"
match_flow_out_sw1_path1 = {
	'switch': "'${SW1_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW1_PORT_IN}'", 
	"active":"true", 
	"actions":"output='${SW1_PORT_OUT_PATH1}'"
}

NAME="match-flow-out-sw1-path1-reverse"
match_flow_out_sw1_path1_reverse = {
	"switch": "'${SW1_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW1_PORT_OUT_PATH1}'", 
	"active":"true", 
	"actions":"output='${SW1_PORT_IN}'"
}

NAME="match-flow-out-sw1-path2"
match_flow_out_sw1_path2={
	"switch": "'${SW1_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW1_PORT_IN}'", 
	"active":"true", 
	"actions":"output='${SW1_PORT_OUT_PATH2}'"
}

NAME="match-flow-out-sw1-path2-reverse"
match_flow_out_sw1_path2_reverse={
	"switch": "'${SW1_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW1_PORT_OUT_PATH2}'", 
	"active":"true", 
	"actions":"output='${SW1_PORT_IN}'"
}

NAME="match-flow-out-sw2"
match_flow_out_sw2 ={
	"switch": "'${SW2_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW2_PORT_IN}'", 
	"active":"true", 
	"actions":"output='${SW2_PORT_OUT}'"
	}
NAME="match-flow-out-sw2-reverse"
match_flow_out_sw2_reverse={
	"switch": "'${SW2_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW2_PORT_OUT}'", 
	"active":"true", 
	"actions":"output='${SW2_PORT_IN}'"
}



NAME="match-flow-out-sw3"
match_flow_out_sw3={
	"switch": "'${SW3_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW3_PORT_IN}'", 
	"active":"true", 
	"actions":"output='${SW3_PORT_OUT}'"
}

NAME="match-flow-out-sw3-reverse"
match_flow_out_sw3_reverse={
	"switch": "'${SW3_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW3_PORT_OUT}'", 
	"active":"true", 
	"actions":"output='${SW3_PORT_IN}'"
}


NAME="match-flow-out-sw4-path1"
match_flow_out_sw4_path1={
	"switch": "'${SW4_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW4_PORT_IN_PATH1}'", 
	"active":"true", 
	"actions":"output='${SW4_PORT_OUT_CAM2}'"
}
NAME="match-flow-out-sw4-path1-reverse"
match_flow_out_sw4_path1_reverse={
	"switch": "'${SW4_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW4_PORT_OUT_CAM2}'", 
	"active":"true", 
	"actions":"output='${SW4_PORT_IN_PATH1}'"
}



NAME="match-flow-out-sw4-path2"
match_flow_out_sw4_path2={
	"switch": "'${SW4_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW4_PORT_IN_PATH2}'", 
	"active":"true", 
	"actions":"output='${SW4_PORT_OUT_CAM2}'"
}

NAME="match-flow-out-sw4-path2-reverse"
match_flow_out_sw4_path2_reverse={
	"switch": "'${SW4_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${SW4_PORT_OUT_CAM2}'", 
	"active":"true", 
	"actions":"output='${SW4_PORT_IN_PATH2}'"
}

MAC3="74:D0:2B:4C:3D:81"
MAC1="74:D0:2B:4C:3E:8A"

NAME="match-flow-iperf-path-sw4"
match_flow_iperf_path_sw4={
	"switch": "'${SW4_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${IPERF_SW4_PORT_IN}'", 
	"src-mac":"'${MAC3}'", 
	"dst-mac":"'${MAC1}'", 
	"active":"true", 
	"actions":"output='${IPERF_SW4_PORT_OUT}'"
}
NAME="match-flow-iperf-path-sw4-reverse"
match_flow_iperf_path_sw4_reverse={
	"switch": "'${SW4_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${IPERF_SW4_PORT_OUT}'", 
	"src-mac":"'${MAC1}'", 
	"dst-mac":"'${MAC3}'", 
	"active":"true", 
	"actions":"output='${IPERF_SW4_PORT_IN}'"
}

NAME="match-flow-iperf-path-sw1"
match_flow_iperf_path_sw1={
	"switch": "'${SW1_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${IPERF_SW1_PORT_IN}'", 
	"src-mac":"'${MAC3}'", 
	"dst-mac":"'${MAC1}'", 
	"active":"true", 
	"actions":"output='${IPERF_SW1_PORT_OUT}'"
}
NAME="match-flow-iperf-path-sw1-reverse"
match_flow_iperf_path_sw1_reverse={
	"switch": "'${SW1_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${IPERF_SW1_PORT_OUT}'", 
	"src-mac":"'${MAC1}'", 
	"dst-mac":"'${MAC3}'", 
	"active":"true", 
	"actions":"output='${IPERF_SW1_PORT_IN}'"

}


NAME="match-flow-iperf-path-sw2"
match_flow_iperf_path_sw2={
	"switch": "'${SW2_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${IPERF_SW2_PORT_IN}'", 
	"src-mac":"'${MAC3}'", 
	"dst-mac":"'${MAC1}'", 
	"active":"true", 
	"actions":"output='${IPERF_SW2_PORT_OUT}'"
}
NAME="match-flow-iperf-path-sw2-reverse"
match_flow_iperf_path_sw2_reverse={
	"switch": "'${SW2_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${IPERF_SW2_PORT_OUT}'", 
	"src-mac":"'${MAC1}'", 
	"dst-mac":"'${MAC3}'", 
	"active":"true", 
	"actions":"output='${IPERF_SW2_PORT_IN}'"
}

NAME="match-flow-iperf-path-sw4"
match_flow_iperf_path_sw4={
	"switch": "'${SW4_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${IPERF_SW4_PORT_IN}'", 
	"src-mac":"'${MAC3}'", 
	"dst-mac":"'${MAC1}'", 
	"active":"true", 
	"actions":"output='${IPERF_SW4_PORT_OUT}'"
}


NAME="match-flow-iperf-path-sw4-reverse"
match_flow_iperf_path_sw4_reverse={
	"switch": "'${SW4_DPID}'",
	"name":"'${NAME}'", 
	"cookie":"0", 
	"priority":"'${PRIORITY}'",  
	"ingress-port":"'${IPERF_SW4_PORT_OUT}'", 
	"src-mac":"'${MAC1}'", 
	"dst-mac":"'${MAC3}'", 
	"active":"true", 
	"actions":"output='${IPERF_SW4_PORT_IN}'"
}


#class FlowPaths(object):

#    def __init__(self):
#        self=0;

def delete_path2():
        pusher.remove( obj, json.dumps({"name": "match-flow-out-sw1-path2"}))
        pusher.remove( obj, json.dumps({"name": "match-flow-out-sw1-path2-reverse"}))
        pusher.remove( obj, json.dumps({"name": "match-flow-out-sw3"})) 
        pusher.remove( obj, json.dumps({"name": "match-flow-out-sw3-reverse"})) 
        pusher.remove( obj, json.dumps({"name": "match-flow-out-sw4-path2"}))
        pusher.remove( obj, json.dumps({"name": "match-flow-out-sw4-path2-reverse"}))

def delete_path1():
    pusher.remove( obj, json.dumps({"name": "match-flow-out-sw1-path1"}))
    pusher.remove( obj, json.dumps({"name": "pusher.remove(match-flow-out-sw1-path1-reverse"}))
    pusher.remove( obj, json.dumps({"name": "pusher.remove(match-flow-out-sw2"})) 
    pusher.remove( obj, json.dumps({"name": "pusher.remove(match-flow-out-sw2-reverse"})) 
    pusher.remove( obj, json.dumps({"name": "pusher.remove(match-flow-out-sw4-path1"}))



def set_path1():
    print "Delete any path 2 rules ..."
    delete_path2
    print "Set Full Flow Path 1 ..."
    pusher.set(match-flow-out-sw1-path1)
    pusher.set(match-flow-out-sw1-path1-reverse)
    pusher.set(match-flow-out-sw2) 
    pusher.set(match-flow-out-sw2-reverse) 
    pusher.set(match-flow-out-sw4-path1)
    pusher.set(match-flow-out-sw4-path1-reverse)
    current_path=1




def set_path2():
    print "Delete any path 1 rules ..."
    delete_path1
    print "Set Full Flow Path 2 ..."
    pusher.set(match-flow-out-sw1-path2)
    pusher.set(match-flow-out-sw1-path2-reverse)
    pusher.set(match-flow-out-sw3) 
    pusher.set(match-flow-out-sw3-reverse) 
    pusher.set(match-flow-out-sw4-path2)
    pusher.set(match-flow-out-sw4-path2-reverse)
    current_path=2


def set_path3():
    print "Set full flow path 3 rules ..."

def set_path3_with_macs():
    pusher.set(match-flow-iperf-path-sw1)
    pusher.set(match-flow-iperf-path-sw1-reverse)
    pusher.set(match-flow-iperf-path-sw2)
    pusher.set(match-flow-iperf-path-sw2-reverse)
    pusher.set(match-flow-iperf-path-sw4)
    pusher.set(match-flow-iperf-path-sw4-reverse)

    
def delete_path3():
    pusher.remove( obj, json.dumps({"name": "match-flow-iperf-path-sw1"}))
    pusher.remove( obj, json.dumps({"name": "match-flow-iperf-path-sw2"}))
    pusher.remove( obj, json.dumps({"name": "match-flow-iperf-path-sw3"}))
    pusher.remove( obj, json.dumps({"name": "match-flow-iperf-path-sw1-reverse"}))
    pusher.remove( obj, json.dumps({"name": "match-flow-iperf-path-sw2-reverse"}))
    pusher.remove( obj, json.dumps({"name": "match-flow-iperf-path-sw4-reverse"}))

#    pusher.remove( "match-flow-iperf-path-sw1" )
#    pusher.remove( "match-flow-iperf-path-sw2" )
#    pusher.remove( "match-flow-iperf-path-sw4" )
#    pusher.remove( "match-flow-iperf-path-sw1-reverse" )
#    pusher.remove( "match-flow-iperf-path-sw2-reverse" )
#    pusher.remove( "match-flow-iperf-path-sw4-reverse" )

    path3_enabled=False



pusher = StaticFlowPusher('127.0.0.1')
pusher.set(flow1)
pusher.remove("", flow1)
