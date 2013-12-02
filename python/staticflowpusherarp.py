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

pusher = StaticFlowPusher('127.0.0.1')

arp_flow1 = {
    'switch':"00:00:00:00:00:00:00:05",
    "name":"src-dst-ether-tap",
    "priority":"32768",
    "active":"true",
    "ether-type":"0x800",
    "ingress-port":"65534",
    "actions":"output=10"
    }
    
arp_flow2 = {
    'switch':"00:00:00:00:00:00:00:05",
    "name":"dst-src-ether-tap",
    "priority":"32768",
    "active":"true",
    "ether-type":"0x800",
    "ingress-port":"10",
    "actions":"output=65534"
    }

arp_flow3 = {
    'switch':"00:00:00:00:00:00:00:05",
    "name":"src-dst-arp-tap",
    "priority":"32768",
    "active":"true",
    "ether-type":"0x806",
    "ingress-port":"65534",
    "actions":"output=10"
    }
    
arp_flow4 = {
    'switch':"00:00:00:00:00:00:00:05",
    "name":"dst-src-arp-tap",
    "priority":"32768",
    "active":"true",
    "ether-type":"0x806",
    "ingress-port":"10",
    "actions":"output=65534"
    }
    
arp_flow5 = {
    'switch':"00:00:00:00:00:00:00:04",
    "name":"src-dst-ether-eth",
    "priority":"32768",
    "active":"true",
    "ether-type":"0x800",
    "ingress-port":"13",
    "actions":"output=1"
    }
    
arp_flow6 = {
    'switch':"00:00:00:00:00:00:00:04",
    "name":"dst-src-ether-eth",
    "priority":"32768",
    "active":"true",
    "ether-type":"0x800",
    "ingress-port":"1",
    "actions":"output=13"
    }

arp_flow7 = {
    'switch':"00:00:00:00:00:00:00:04",
    "name":"src-dst-arp-eth",
    "priority":"32768",
    "active":"true",
    "ether-type":"0x806",
    "ingress-port":"13",
    "actions":"output=1"
    }
    
arp_flow8 = {
    'switch':"00:00:00:00:00:00:00:04",
    "name":"dst-src-arp-eth",
    "priority":"32768",
    "active":"true",
    "ether-type":"0x806",
    "ingress-port":"1",
    "actions":"output=13"
    }        
"""
pusher.set(flow1)
pusher.set(flow2)
pusher.set(flow3)
pusher.set(flow4)
pusher.set(flow5)
pusher.set(flow6)
pusher.set(flow7)
pusher.set(flow8)
"""



# Switch 1
arp_sw1_flow_mod_1 = {"switch": "00:00:00:00:00:00:00:01", "name":"flow-mod-1", "cookie":"0", "priority":"0", 
"ether-type":"0x0800", "dest-ip":"10.0.0.10", "active":"true", "actions":"output=2"}

arp_sw1_flow_mod_2= {"switch": "00:00:00:00:00:00:00:01", "name":"flow-mod-2", "cookie":"0", "priority":"0", "ether-type":"0x0800", 
"dest-ip":"10.0.0.8", "active":"true", "actions":"output=3"}

arp_sw1_flow_mod_1_arp_req= {"switch": "00:00:00:00:00:00:00:01", "name":"flow-mod-1-arp-req", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.10", "actions":"output=2"}

arp_sw1_flow_mod_1_arp_resp= {"switch": "00:00:00:00:00:00:00:01", "name":"flow-mod-1-arp-resp", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.8", "actions":"output=3"}

# Switch 2
arp_sw2_flow_mod_2_arp= {"switch": "00:00:00:00:00:00:00:02", "name":"flow-mod-2-arp", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "actions":"output=flood"}

# Switch 3
arp_sw3_flow_mod_3= {"switch": "00:00:00:00:00:00:00:03", "name":"flow-mod-3", "cookie":"0", "priority":"0", 
"ether-type":"0x0800", "dest-ip":"10.0.0.10", "active":"true", "actions":"output=3"}

arp_sw3_flow_mod_4= {"switch": "00:00:00:00:00:00:00:03", "name":"flow-mod-4", "cookie":"0", "priority":"0", 
"ether-type":"0x0800", "dest-ip":"10.0.0.8","active":"true", "actions":"output=1"}

arp_sw3_flow_mod_3_arp_req= {"switch": "00:00:00:00:00:00:00:03", "name":"flow-mod-3-arp-req", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.8", "actions":"output=1"}

arp_sw3_flow_mod_3_arp_resp= {"switch": "00:00:00:00:00:00:00:03", "name":"flow-mod-3-arp-resp", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.10", "actions":"output=3"}

# Switch 4
arp_sw4_flow_mod_4_arp= {"switch": "00:00:00:00:00:00:00:04", "name":"flow-mod-4-arp", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "actions":"output=flood"}


# Switch 5
arp_sw5_flow_mod_5= {"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5", "cookie":"0", "priority":"0", 
"ether-type":"0x0800", "dest-ip":"10.0.0.10", "active":"true", "actions":"output=2"}

arp_sw5_flow_mod_6= {"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-6", "cookie":"0", "priority":"0", 
"ether-type":"0x0800", "dest-ip":"10.0.0.11", "active":"true", "actions":"output=2"}

arp_sw5_flow_mod_7= {"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-7", "cookie":"0", "priority":"0", 
"ether-type":"0x0800", "dest-ip":"10.0.0.9", "active":"true", "actions":"output=3"}

arp_sw5_flow_mod_8= {"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-8", "cookie":"0", "priority":"0", 
"ether-type":"0x0800", "dest-ip":"10.0.0.8", "active":"true", "actions":"output=1"}

arp_sw5_flow_mod_5_arp_1= {"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5-arp-1", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.8", "actions":"output=1"}

arp_sw5_flow_mod_5_arp_2= {"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5-arp-2", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.9", "actions":"output=3"}

arp_sw5_flow_mod_5_arp_3= {"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5-arp-3", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.10", "actions":"output=2"}

arp_sw5_flow_mod_5_arp_4= {"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5-arp-4", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.11", "actions":"output=2"}


# Switch 6
arp_sw6_flow_mod_6_arp= {"switch": "00:00:00:00:00:00:00:06", "name":"flow-mod-6-arp", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "actions":"output=flood"}


# Switch 7
arp_sw7_flow_mod_9= {"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-9", "cookie":"0", "priority":"0", "dest-ip":"10.0.0.8", 
"ether-type":"0x0800", "active":"true", "actions":"output=1"}

arp_sw7_flow_mod_10= {"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-10", "cookie":"0", "priority":"0", "dest-ip":"10.0.0.9", 
"ether-type":"0x0800", "active":"true", "actions":"output=1"}

arp_sw7_flow_mod_11= {"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-11", "cookie":"0", "priority":"0", 
"ether-type":"0x0800", "dest-ip":"10.0.0.10", "active":"true", "actions":"output=3"}

arp_sw7_flow_mod_12= {"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-12", "cookie":"0", "priority":"0", 
"ether-type":"0x0800", "dest-ip":"10.0.0.11", "active":"true", "actions":"output=4"}

arp_sw7_flow_mod_7_arp_1= {"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-7-arp-1", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.8", "actions":"output=1"}

arp_sw7_flow_mod_7_arp_2= {"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-7-arp-2", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.9", "actions":"output=1"}

arp_sw7_flow_mod_7_arp_3= {"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-7-arp-3", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.10", "actions":"output=3"}

arp_sw7_flow_mod_7_arp_4= {"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-7-arp-4", "cookie":"0", "priority":"0", 
"ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.11", "actions":"output=4"}

print "Switch 1"
pusher.set(arp_sw1_flow_mod_1)
pusher.set(arp_sw1_flow_mod_2)
pusher.set(arp_sw1_flow_mod_1_arp_req)
pusher.set(arp_sw1_flow_mod_1_arp_resp)
print "Switch 2"
#pusher.set(arp_sw2_flow_mod_2_arp)
print "Switch 3"
pusher.set(arp_sw3_flow_mod_3)
pusher.set(arp_sw3_flow_mod_4)
pusher.set(arp_sw3_flow_mod_3_arp_req)
pusher.set(arp_sw3_flow_mod_3_arp_resp)
print "Switch 4"
#pusher.set(arp_sw4_flow_mod_4_arp)
print "Switch 5"
pusher.set(arp_sw5_flow_mod_5)
pusher.set(arp_sw5_flow_mod_6)
pusher.set(arp_sw5_flow_mod_7)
pusher.set(arp_sw5_flow_mod_8)
pusher.set(arp_sw5_flow_mod_5_arp_1)
pusher.set(arp_sw5_flow_mod_5_arp_2)
pusher.set(arp_sw5_flow_mod_5_arp_3)
pusher.set(arp_sw5_flow_mod_5_arp_4)
print "Switch 6"
#pusher.set(arp_sw6_flow_mod_6_arp)
print "Switch 7"
pusher.set(arp_sw7_flow_mod_9)
pusher.set(arp_sw7_flow_mod_10)
pusher.set(arp_sw7_flow_mod_11)
pusher.set(arp_sw7_flow_mod_12)
pusher.set(arp_sw7_flow_mod_7_arp_1)
pusher.set(arp_sw7_flow_mod_7_arp_2)
pusher.set(arp_sw7_flow_mod_7_arp_3)
pusher.set(arp_sw7_flow_mod_7_arp_4)


