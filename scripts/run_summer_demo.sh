#!/bin/bash

# mininet default
# sudo mn --topo single,3 --mac --switch ovsk --controller remote

# mininet on networkx and graphviz
# sudo mn --custom mn_nx_topos.py --topo cycle,n=4 --mac --switch ovsk --controller remote
# sudo mn --custom mn_nx_topos.py --topo balanced_tree,r=3,h=2 --mac --switch ovsk --controller remote
# sudo mn --custom mn_nx_topos.py --topo erdos_renyi,n=7,p=0.6 --mac --switch ovsk --controller remote

# summer demo current topology

echo "Stop All Previous Controller Instances ..."
sudo killall java
sudo killall xterm
sudo killall chrome
echo "Waiting for Everything to Stop ..."
sleep 15

echo -n "Start standard Floodlight with L2 learning [y/N]?"
read c
if [  "x$c" != "x" ]; then
if [ "$c" = "Y" ] || [ "$c" = "y" ]; then
# run floodlight with l2 switch module
echo "Start Floodlight Standard ..."
sudo xterm -e java -jar floodlight.jar  & 
else
# run floodlight without l2 switch module
echo "Start Floodlight Developer ..."
sudo xterm -e java -jar floodlight/target/floodlight.jar  & 
fi
fi
sleep 2
echo "Start Avior ..."
sudo xterm -e java -jar avior-1.3_linux_x64.jar  & 
echo "Waiting for Everything Start ..."
sleep 15
echo "Start Chrome ..."
/opt/google/chrome/google-chrome &
sleep 2
echo "Start SDN App Menu ..."
sudo xterm -e ./run_sdnapp_menu.sh &

#sudo mn --custom mn_nx_topos.py --topo square --mac --switch ovsk --controller remote

#sudo killall xterm


