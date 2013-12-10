#!/usr/bin/env python

__author__ = 'xisted'
import httplib
import json
import base64
import string

toggle = 1
toggle_pcmm = 1
# consider refectoring with request http://docs.python-requests.org/en/latest/index.html

class Error:
    # indicates an HTTP error
    def __init__(self, url, errcode, errmsg, headers):
        self.url = url
        self.errcode = errcode
        self.errmsg = errmsg
        self.headers = headers
    def __repr__(self):
        return (
            "<Error for %s: %s %s>" %
            (self.url, self.errcode, self.errmsg)
            )


class RestfulAPI(object):
    def __init__(self, server):
        self.server = server
        self.path = '/wm/staticflowentrypusher/json'
        self.auth = ''
        self.port = '8080'


    def set_path(self, path):
	#print path
        self.path = path

    def use_creds(self):
    	u = self.auth is not None and len(self.auth) > 0
#    	p = self.password is not None and len(self.password) > 0
        return u

    def credentials(self, username, password):
        self.auth = base64.encodestring('%s:%s' % (username, password)).replace('\n', '')

    def get(self, data=''):
        ret = self.rest_call({}, 'GET')
        #return json.loads(ret[2])
        return ret

    def set(self, data):
        #ret = self.rest_call(data, 'PUT')
        ret = self.rest_call2(data, 'PUT')
	print ret[0], ret[1]
        # return ret[0] == 200
        return ret

    def post(self, data):
        ret = self.rest_call(data, 'PUT')
        #ret = self.rest_call2(data, 'POST')
	print ret[0], ret[1]
	return ret

    def put(self, data):
        ret = self.rest_call(data, 'PUT')
        return ret
        #return ret[0] == 200


    def remove(self, objtype, data):
        ret = self.rest_call(data, 'DELETE')
        #return ret[0] == 200
        return ret

    def show(self, data):
	print ""
	print json.dumps(data, indent=4, sort_keys=True)
#       print 'DATA:', repr(data)
#
#	print ""
#       data_string = json.dumps(data)
#       print 'JSON:', data_string
#
#	print ""
#       data_string = json.dumps(data)
#       print 'ENCODED:', data_string
#
#	print ""
#       decoded = json.loads(data_string)
#       print 'DECODED:', decoded


    def rest_call2(self, data, action):

        #conn = httplib.HTTPConnection(self.server, self.port)
        conn = httplib.HTTP(self.server, self.port)
        conn.putrequest(action, self.path)
	conn.putheader("Host", self.server+':'+self.port)
 	conn.putheader("User-Agent", "Python HTTP Auth")
        conn.putheader('Content-type', 'application/json')
        body = json.dumps(data)
	#conn.putheader("Content-length", "%d" % len(data))
	conn.putheader("Content-length", "%d" % len(body))
        if self.use_creds():
        #    print "using creds"
            conn.putheader("Authorization", "Basic %s" % self.auth)
        conn.endheaders()
	
        conn.send(body)
	errcode, errmsg, headers = conn.getreply()
	ret = (errcode, errmsg, headers)

        #if errcode != 201:
        #   raise Error(self.path, errcode, errmsg, headers)

        # get response
        #response = conn.getresponse()
	#headers = response.read()
        #ret = (response.status, response.reason, headers)
        #if response.status != 200:
        #    raise Error(self.path, response.status, response.reason, headers)
	return ret


    def rest_call(self, data, action):
        body = json.dumps(data)
	if self.use_creds():
	#    print "using creds"
            headers = {
                'Content-type': 'application/json',
                'Accept': 'application/json',
		'Content-length': "%d" % len(body),
	        'Authorization': "Basic %s" % self.auth,
                }
        else:
            headers = {
                'Content-type': 'application/json',
                'Accept': 'application/json',
		'Content-length': "%d" % len(body),
                }
		
        conn = httplib.HTTPConnection(self.server, self.port)
        conn.request(action, self.path, body, headers)
        response = conn.getresponse()
	data = response.read()
        ret = (response.status, response.reason, data)
        #print "status %d %s" % (response.status,response.reason)
        conn.close()
        return ret


class Menu(object):
    def __init__(self):
        pass


    def print_menu(self):
        print (30 * '-')
        print ("   MENU               ")
        print (30 * '-')
        print ("1.  Add Flow 1        ")
        print ("2.  Add Flow 2        ")
        print ("3.  Add Several Flows ")
        print ("4.  Remove Flow 1     ")
        print ("5.  Remove Flow 2     ")
        print ("6.  Remove All Flows  ")
        print ("7.  Toggle Flow       ")
        print ("8.  List Flow Stats   ")
        print ("9.  List Topology     ")
        print ("10. List Flows        ")
        print ("11. List Ports        ")
        print ("12. Add PCMM Flow 1   ")
        print ("13. Remove PCMM Flow 1")
        print ("14. Add PCMM Flow 2   ")
        print ("15. Remove PCMM Flow 2")
        print ("16. Toggle PCCM Flows")
        print ("q. Quit               ")
#        print (30 * '-')


    def no_such_action(self):
        print "Invalid option!"

    def run(self):
        actions = {
	"1": flow_add_1, 
	"2": flow_add_2, 
	"3": flow_add_several, 
	"4": flow_remove_1,
	"5": flow_remove_2,
	"6": flow_remove_all,
	"7": flow_toggle,
	"8": flow_list_stats,
	"9": topology_list,
	"10":flow_list,
	"11":port_list,
	"12":flow_add_pc_1,
	"13":flow_remove_pc_1,
	"14":flow_add_pc_2,
	"15":flow_remove_pc_2,
	"16":flow_toggle_pcmm,
	"q": exit_app,
        }
        while True:
            self.print_menu()
            selection = raw_input("Enter selection: ")
            if "quit" == selection:
                return
            toDo = actions.get(selection, self.no_such_action)
            toDo()


class ODL(object):
    def __init__(self):
        pass

    def topology(self):
        ws.set_path('/controller/nb/v2/topology/default')
        content = ws.get()
        j=json.loads(content[2])
        ws.show(j)

    def statistics_ports(self):
        ws.set_path('/controller/nb/v2/statistics/default/port')
        content = ws.get()
        allPortStats = json.loads(content[2])
	# ws.show(allPortStats)
        portStats = allPortStats['portStatistics']
	# XXX - Array traversal missing last element?
        for po in portStats:
	    print "\nSwitch ID : " + po['node']['id'] +  " Type: " +  po['node']['type']
            for so in po['portStatistic']:
	       # ws.show( so )
	       nc = so['nodeConnector']
               print "\nPort : " + nc['id'] + " Type: " +  nc['type'] 
	       print "Connector Node : " + nc['node']['id'] +  " Type : " +  nc['node']['type']
               print "    Received Bytes  :        ", so['receiveBytes']
               print "    Received Packets:        ", so['receivePackets']
               print "    Received Drops:          ", so['receiveDrops']
               print "    Received Errors:         ", so['receiveErrors']
               print "    Received Frame Errors:   ", so['receiveFrameError']
               print "    Received Over Run Error: ", so['receiveOverRunError']
               print "    Received CRC Errors:     ", so['receiveCrcError']
               print "    Transmitted Packets:     ", so['transmitBytes']
               print "    Transmitted Errors:      ", so['transmitErrors']
               print "    Transmitted Drops:       ", so['transmitDrops']
               print "    Collision Count:         ", so['collisionCount']


    # adopted from fredhsu @ http://fredhsu.wordpress.com/2013/04/25/getting-started-with-opendaylight-and-python/
    def statistics_flows(self):
        ws.set_path('/controller/nb/v2/statistics/default/flow')
        content = ws.get()
        allFlowStats = json.loads(content[2])

        flowStats = allFlowStats['flowStatistics']
	# These JSON dumps were handy when trying to parse the responses 
        #print json.dumps(flowStats[0]['flowStat'][1], indent = 2)
	#print json.dumps(flowStats[4], indent = 2)
        for fs in flowStats:
            print "\nSwitch ID : " + fs['node']['id']
	    print '{0:8} {1:8} {2:5} {3:15}'.format('Count', 'Action', 'Port', 'DestIP')
	    if not 'flowStatistic' in fs.values(): 
		print '              none'
		continue
	    for aFlow in fs['flowStatistic']:
		#print "*", aFlow, "*", " ", len(aFlow), " ", not aFlow
	        count = aFlow['packetCount']
	        actions = aFlow['flow']['actions'] 
	        actionType = ''
	        actionPort = ''
	        #print actions
	        if(type(actions) == type(list())):
		    actionType = actions[1]['type']
		    actionPort = actions[1]['port']['id']
		else:
	    	    actionType = actions['type']
		    actionPort = actions['port']['id']
		dst = aFlow['flow']['match']['matchField'][0]['value']
		print '{0:8} {1:8} {2:5} {3:15}'.format(count, actionType, actionPort, dst)

    def flowprogrammer_list(self):
        ws.set_path('/controller/nb/v2/flowprogrammer/default')
        content = ws.get()
        j=json.loads(content[2])
        ws.show(j)
        #ws.show(content[2])
	return(j)


    def flowprogrammer_add(self, flow):
        # http://localhost:8080/controller/nb/v2/flowprogrammer/default/node/OF/00:00:00:00:00:00:00:01/staticFlow/flow1
        ws.set_path('/controller/nb/v2/flowprogrammer/default/node/' + flow['node']['type'] + '/' + flow['node']['id'] + '/staticFlow/' + flow['name'] )
        ws.show(flow)
        content = ws.set(flow)
        #print content
	flowadd_response_codes = {
	201:"Flow Config processed successfully",
	400:"Failed to create Static Flow entry due to invalid flow configuration",
	401:"User not authorized to perform this operation",
	404:"The Container Name or nodeId is not found",
	406:"Cannot operate on Default Container when other Containers are active",
	409:"Failed to create Static Flow entry due to Conflicting Name or configuration",
	500:"Failed to create Static Flow entry. Failure Reason included in HTTP Error response",
	503:"One or more of Controller services are unavailable",
	} 
	msg=flowadd_response_codes.get(content[0])
	print content[0], content[1], msg

    def flowprogrammer_remove(self, flow):
        ws.set_path('/controller/nb/v2/flowprogrammer/default/node/' + flow['node']['type'] + '/' + flow['node']['id'] + '/staticFlow/' + flow['name'] )
        content = ws.remove("", flow)

	flowdelete_reponse_codes = {
	204:"Flow Config deleted successfully",
	401:"User not authorized to perform this operation",
	404:"The Container Name or Node-id or Flow Name passed is not found",
	406:"Failed to delete Flow config due to invalid operation. Failure details included in HTTP Error response",
	500:"Failed to delete Flow config. Failure Reason included in HTTP Error response",
	503:"One or more of Controller service is unavailable",
	}
	msg=flowdelete_reponse_codes.get(content[0])
	print content[0], content[1], msg

    def flowprogrammer_remove_all(self):
	allFlowConfigs = self.flowprogrammer_list()
        flowConfigs = allFlowConfigs['flowConfig']
	# These JSON dumps were handy when trying to parse the responses 
        #print json.dumps(flowStats[0]['flowStat'][1], indent = 2)
	#print json.dumps(flowStats[4], indent = 2)
        for fl in flowConfigs:
	    print "Removing ", fl['name']
    	    self.flowprogrammer_remove(fl)
		

# XXX - do not use underscores and dashes in flow names.
# XXX - ingress ports that possibly don't exist ? throw configuration errors

flow1 = {
        "actions": [
            "OUTPUT=2"
        ],         
        "installInHw":"false",
        "name":"flow1",
        "node":
        {
            "id":"00:00:00:00:00:00:00:02",
            "type":"OF"
        }, 
        "priority":"500",
        "etherType":"0x800",
        "nwSrc":"10.0.0.7",
        "tpSrc":"8081",
        "nwDst":"10.0.0.3", 

}

flow2 = {
        "actions": [
            "OUTPUT=2"
        ],         
        "installInHw":"false",
        "name":"flow2",
        "node":
	{
	    "id":"00:00:00:00:00:00:00:01",
	    "type":"OF"
        },
        "priority":"500",
        "etherType":"0x800",
        "nwSrc":"10.0.0.1",
        "tpSrc":"1369",
        "nwDst":"10.0.0.3", 
}


flow3 = {
     "actions": [
        "OUTPUT=3"
     ], 
     "etherType": "0x800", 
     "installInHw": "true", 
     "name": "flow2", 
     "node": {
           "id": "00:00:00:00:00:00:00:01", 
           "type": "OF"
     }, 
     "nwDst": "10.0.0.2", 
     "nwSrc": "10.0.0.1", 
     "priority": "500", 
     "protocol": "6"
} 


flow5={
     "actions": [
          "OUTPUT=2"
     ], 
     "etherType": "0x800", 
     "installInHw": "false", 
     "name": "flow5", 
     "node": {
         "id": "00:00:00:00:00:00:00:01", 
          "type": "OF"
      }, 
     "nwSrc": "10.0.0.10", 
     "priority": "500"
}

flow4={
   "actions": [
       "OUTPUT=2"
   ], 
   "etherType": "0x800", 
   "installInHw": "true", 
   "name": "flow4", 
   "node": {
           "id": "00:00:00:00:00:00:00:01", 
           "type": "OF"
    }, 
    "nwSrc": "10.0.0.1", 
    "priority": "500", 
    "vlanId": "1", 
    "vlanPriority": "1"
}

''' Demo Kit  Layout

flow_pcmm_1 = {
     "actions": [
        "FLOOD"
     ], 
     "etherType": "0x800", 
     "installInHw": "true", 
     "name": "flowpcmmHighBW", 
     "node": {
           "id": "51966", 
           "type": "PC"
     }, 
     "tpDst":"8081",
     "nwDst": "10.32.4.208", 
     "nwSrc": "10.32.154.2", 
     "priority": "100", 
} 

flow_pcmm_2 = {
     "actions": [
        "FLOOD"
     ], 
     "etherType": "0x800", 
     "installInHw": "true", 
     "name": "flowpcmmLowBW", 
     "node": {
           "id": "51966", 
           "type": "PC"
     }, 
     "tpDst":"8081",
     "nwDst": "10.32.4.208", 
     "nwSrc": "10.32.154.2", 
     "priority": "64", 
} 
'''


''' LAB Workbench Layout 
'''

flow_pcmm_1 = {
     "actions": [
        "FLOOD"
     ], 
     "etherType": "0x800", 
     "installInHw": "true", 
     "name": "flowpcmmHighBW", 
     "node": {
           "id": "51966", 
           "type": "PC"
     }, 
     "tpDst":"8081",
     "nwDst": "10.32.0.228", 
     "nwSrc": "10.32.215.113", 
     "priority": "100", 
} 

flow_pcmm_2 = {
     "actions": [
        "FLOOD"
     ], 
     "etherType": "0x800", 
     "installInHw": "true", 
     "name": "flowpcmmLowBW", 
     "node": {
           "id": "51966", 
           "type": "PC"
     }, 
     "tpDst":"8081",
     "nwDst": "10.32.0.228", 
     "nwSrc": "10.32.215.113", 
     "priority": "64", 
} 


def flow_add_pc_1():
    print "Test PCMM Flow 1     "
    odl.flowprogrammer_add(flow_pcmm_1)

def flow_remove_pc_1():
    print "Remove PCMM Flow 1  "
    odl.flowprogrammer_remove(flow_pcmm_1)


def flow_add_pc_2():
    print "Test PCMM Flow 2     "
    odl.flowprogrammer_add(flow_pcmm_2)

def flow_remove_pc_2():
    print "Remove PCMM Flow 2  "
    odl.flowprogrammer_remove(flow_pcmm_2)

def flow_toggle_pcmm():
    print "Toggle Flow    "
    global toggle_pcmm
    toggle_pcmm = 3 - toggle_pcmm
    if toggle_pcmm == 1:
	flow_remove_pc_2()
	flow_add_pc_1()
    else:
	flow_remove_pc_1()
	flow_add_pc_2()

def flow_add_1():
    print "Add Flow 1     "
    odl.flowprogrammer_add(flow1)


def flow_add_2():
    print "Add Flow 2     "
    odl.flowprogrammer_add(flow2)

def flow_add_several():
    print "Add Flow Several     "
    odl.flowprogrammer_add(flow1)
    odl.flowprogrammer_add(flow2)
    odl.flowprogrammer_add(flow3)
    odl.flowprogrammer_add(flow4)
    odl.flowprogrammer_add(flow5)


def flow_toggle():
    print "Toggle Flow    "
    global toggle
    toggle = 3 - toggle
    if toggle == 1:
	flow_remove_2()
	flow_add_1()
    else:
	flow_remove_1()
	flow_add_2()


def flow_remove_1():
    print "Remove Flow 1  "
    odl.flowprogrammer_remove(flow1)

def flow_remove_2():
    print "Remove Flow 2  "
    odl.flowprogrammer_remove(flow2)

def flow_remove_all():
    print "Remove All Flows "
    odl.flowprogrammer_remove_all()

def flow_list_stats():
    print "List Flow Stats"
    odl.statistics_flows()

def topology_list():
    print "List Topology  "
    odl.topology()

def flow_list():
    print "List Flows  "
    odl.flowprogrammer_list()

def port_list():
    print "List Ports Stats  "
    odl.statistics_ports()


def exit_app():
    print "Quit           "
    exit(0)

if __name__ == "__main__":
    ws = RestfulAPI('127.0.0.1')
    #ws = RestfulAPI('192.168.56.10')
    ws.credentials('admin', 'admin')
    odl = ODL()
    menu=Menu()
    menu.run()
    exit(0)



