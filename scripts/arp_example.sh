# Switch 1
curl -d '{"switch": "00:00:00:00:00:00:00:01", "name":"flow-mod-1", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.10", "active":"true", "actions":"output=2"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:01", "name":"flow-mod-2", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.8", "active":"true", "actions":"output=3"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:01", "name":"flow-mod-1-arp-req", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.10", "actions":"output=2"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:01", "name":"flow-mod-1-arp-resp", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.8", "actions":"output=3"}' http://localhost:8080/wm/staticflowentrypusher/json

# Switch 2
#curl -d '{"switch": "00:00:00:00:00:00:00:02", "name":"flow-mod-2-arp", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "actions":"output=flood"}' http://localhost:8080/wm/staticflowentrypusher/json


# Switch 3
curl -d '{"switch": "00:00:00:00:00:00:00:03", "name":"flow-mod-3", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.10", "active":"true", "actions":"output=3"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:03", "name":"flow-mod-4", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.8","active":"true", "actions":"output=1"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:03", "name":"flow-mod-3-arp-req", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.8", "actions":"output=1"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:03", "name":"flow-mod-3-arp-resp", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.10", "actions":"output=3"}' http://localhost:8080/wm/staticflowentrypusher/json

# Switch 4
#curl -d '{"switch": "00:00:00:00:00:00:00:04", "name":"flow-mod-4-arp", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "actions":"output=flood"}' http://localhost:8080/wm/staticflowentrypusher/json


# Switch 5
curl -d '{"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.10", "active":"true", "actions":"output=2"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-6", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.11", "active":"true", "actions":"output=2"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-7", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.9", "active":"true", "actions":"output=3"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-8", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.8", "active":"true", "actions":"output=1"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5-arp-1", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.8", "actions":"output=1"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5-arp-2", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.9", "actions":"output=3"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5-arp-3", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.10", "actions":"output=2"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:05", "name":"flow-mod-5-arp-4", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.11", "actions":"output=2"}' http://localhost:8080/wm/staticflowentrypusher/json


# Switch 6
#curl -d '{"switch": "00:00:00:00:00:00:00:06", "name":"flow-mod-6-arp", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "actions":"output=flood"}' http://localhost:8080/wm/staticflowentrypusher/json



# Switch 7
curl -d '{"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-9", "cookie":"0", "priority":"0", "dest-ip":"10.0.0.8", "ether-type":"0x0800", "active":"true", "actions":"output=1"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-10", "cookie":"0", "priority":"0", "dest-ip":"10.0.0.9", "ether-type":"0x0800", "active":"true", "actions":"output=1"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-11", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.10", "active":"true", "actions":"output=3"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-12", "cookie":"0", "priority":"0", "ether-type":"0x0800", "dest-ip":"10.0.0.11", "active":"true", "actions":"output=4"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-7-arp-1", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.8", "actions":"output=1"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-7-arp-2", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.9", "actions":"output=1"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-7-arp-3", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.10", "actions":"output=3"}' http://localhost:8080/wm/staticflowentrypusher/json

curl -d '{"switch": "00:00:00:00:00:00:00:07", "name":"flow-mod-7-arp-4", "cookie":"0", "priority":"0", "ether-type":"0x0806", "active":"true", "dest-ip":"10.0.0.11", "actions":"output=4"}' http://localhost:8080/wm/staticflowentrypusher/json
