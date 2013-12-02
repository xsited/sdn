#!/bin/bash


# summer demo current topology

# run floodlight without l2 switch module
echo "Start Floodlight Developer ..."
sudo xterm -e java -jar floodlight/target/floodlight.jar  & 
echo "Start SDN App Menu ..."
sleep 2
sudo xterm -e ./run_sdnapp_menu.sh &
sleep 15
echo "Start Chrome ..."
/opt/google/chrome/google-chrome &
sleep 15
echo "Start Avior ..."
sudo xterm -e java -jar avior-1.3_linux_x64.jar  & 

