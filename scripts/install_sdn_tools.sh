#!/bin/bash

# 15 JUL 2013  TEK 	First pass adding a guided menu to common SDN tool installation

pkg_purge()
{
sudo apt-get purge thunderbird
sudo apt-get purge pidgin
sudo apt-get purge office
sudo apt-get purge openoffice
sudo apt-get purge libreoffice
sudo apt-get purge libreoffice-base
sudo apt-get purge libreoffice-gnome
sudo apt-get purge libreoffice-base-core
sudo apt-get purge network-manager
sudo apt-get purge libreoffice-draw
sudo apt-get purge libreoffice-impress
}


pkg_add() 
{
# make a single line?
sudo apt-get update -d
sudo apt-get install  -y git
sudo apt-get install  -y openssh-server
sudo apt-get install  -y libssl-dev
sudo apt-get install  -y libpcap-dev
sudo apt-get install  -y xterm
sudo apt-get install  -y iperf
sudo apt-get install  -y netperf
}


pkg_add_kvm() 
{
sudo apt-get install -y kvm qemu-kvm

}


pkg_add_ovs_base() 
{
# install openvswitch for the distro
sudo apt-get install -y openvswitch-data-source bridge-utils
module-assistant auto-install openvswitch-datapath
sudo apt-get install -y openvswitch-switch openvswitch-common openvswitch-controller
}


pkg_add_ovs_mystery() 
{
# override it with 1.9.90-mystery with vxlan
echo "Cloning OVS from GitHub and then compiling the code, may take a few minutes..."
sudo apt-get install -y git python-simplejson python-qt4 python-twisted-conch automake autoconf
apt-get gcc uml-utilities libtool build-essential git pkg-config linux-headers-`uname -r`
git clone https://github.com/mestery/ovs-vxlan.git

cd ovs-vxlan
git checkout vxlan

./boot.sh'
./configure --with-linux=/lib/modules/`uname -r`/build' --prefix=/usr --sysconfdir=/etc --sharedstatedir=/var
make 
make install
mkdir -p /etc/openvswitch
ovsdb-tool create /etc/openvswitch/conf.db vswitchd/vswitch.ovsschema
cp datapath/linux/openvswitch.ko /lib/modules/`uname -r`/kernel/net/openvswitch/
cp datapath/linux/brcompat.ko /lib/modules/`uname -r`/kernel/net/openvswitch/
depmod -a 

modprobe -r openvswitch
modprobe -r brcompat
modprobe openvswitch
modprobe brcompat
/etc/init.d/openvswitch restart

}


pkg_configure_ovs() 
{

# Adding OVS interface script /etc/ovs-ifup
cat << EOF > /etc/ovs-ifup
#!/bin/sh

switch='br-int'
/sbin/ifconfig $1 0.0.0.0 up promisc
ovs-vsctl add-port ${switch} $1
EOF

# Adding OVS interface script /etc/ovs-ifdown

cat << EOF > /etc/ovs-ifdown
#!/bin/sh

switch='br-int'
/sbin/ifconfig $1 0.0.0.0 down
ovs-vsctl del-port ${switch} $1

EOF

# Adding an OpenvSwitch bridged interface br-int
ovs-vsctl add-br br-int
ovs-vsctl add-port br-int eth0
}


pkg_add_floodlight_dev() 
{
sudo apt-get install -y default-jre python-dev curl ant default-jdk
git clone git://github.com/floodlight/floodlight.git
cd floodlight
ant
cd ..
cat << EOF > ./run_floodlight_dev.sh
#!/bin/sh

xterm -e java -jar floodlight/target/floodlight.jar  & 

EOF
chmod 777 ./run_floodlight_dev.sh


}

pkg_add_floodlight() 
{
# Install floodlight
sudo apt-get install -y default-jre python-dev curl
wget http://floodlight.openflowhub.org/files/floodlight.jar

cat << EOF > ./run_floodlight.sh
#!/bin/sh

xterm -e java -jar floodlight.jar  & 

EOF
chmod 777 ./run_floodlight.sh

}


pkg_start_floodlight() 
{
# Floodlight OpenFlow Controller Started in a new Xterm console
xterm -e java -jar floodlight.jar  & 
}


pkg_add_pox() 
{    
# Cloning POX from GitHub 
# Pox requires Python 2.7 to run
git clone http://github.com/noxrepo/pox
cat << EOF > ./run_pox.sh
#!/bin/sh

xterm -e python pox/pox.py  forwarding.l2_learning web.webcore &

EOF
chmod 777 ./run_pox.sh
}



#kvm -m 128 -net nic,macaddr=22:22:22:00:cc:01 -net tap,script=/etc/ovs-ifup,downscript=/etc/ovs-ifdown -hda linux-0.2.img &
#kvm -m 128 -net nic,macaddr=22:22:22:00:cc:02 -net tap,script=/etc/ovs-ifup,downscript=/etc/ovs-ifdown -hda linux-0.2.img &
#kvm -m 128 -net nic,macaddr=22:22:22:00:cc:03 -net tap,script=/etc/ovs-ifup,downscript=/etc/ovs-ifdown -hda linux-0.2.img &



pkg_start_pox() 
{    
# start pox generic 
xterm -e python pox/pox.py  forwarding.l2_learning web.webcore &
# point ovs to of controller
#ovs-vsctl show
}

pkg_add_poxdesk() 
{   
# add pox desk to pox

cd pox/ext/
git clone https://github.com/MurphyMc/poxdesk
cd poxdesk/
wget http://downloads.sourceforge.net/qooxdoo/qooxdoo-2.0.2-sdk.zip
unzip qooxdoo-2.0.2-sdk.zip 
mv qooxdoo-2.0.2-sdk qx
cd poxdesk/
./generate.py 

cat << EOF > ./run_poxdesk.sh
#!/bin/sh

xterm -e python pox/pox.py samples.pretty_log web messenger messenger.log_service messenger.ajax_transport openflow.of_service poxdesk openflow.discovery poxdesk.tinytopo poxdesk.terminal &

EOF
chmod 777 ./run_poxdesk.sh


}


pkg_start_poxdesk() 
{  
# run_pox.sh

xterm -e python pox/pox.py samples.pretty_log web messenger messenger.log_service messenger.ajax_transport openflow.of_service poxdesk openflow.discovery poxdesk.tinytopo poxdesk.terminal &


}
 
pkg_add_ryu()  
{
git clone git://github.com/osrg/ryu.git
cd ryu
sudo apt-get install -y python-setuptools
sudo apt-get install -y python-eventlet python-routes python-webob python-paramiko
sudo python ./setup.py install

cat << EOF > ./run_ryu.sh
#!/bin/sh

PYTHONPATH=./ryu xterm -e ./ryu/bin/ryu-manager ./ryu/ryu/app/simple_switch.py

EOF
chmod 777 ./run_ryu.sh

}

pkg_start_ryu()  
{
PYTHONPATH=./ryu xterm -e ./ryu/bin/ryu-manager ./ryu/ryu/app/simple_switch.py

}


pkg_configure_network()
{
cat << EOF >> /etc/network/interfaces 

auto eth0
iface eth0 inet dhcp

EOF

# clear tap0
ovs-vsctl show
/etc/ovs-ifdown tap0
tunctl -d tap0
}


pkg_add_tcpdump()
{

FILE=./tcpdump-4.3-openflow-decode.patch
if [ -f $FILE ];
then
   echo "Patch $FILE exists."
# add of_print to tcpdump 4.3
wget http://www.tcpdump.org/release/tcpdump-4.3.0.tar.gz
tar xpf tcpdump-4.3.0.tar.gz
wget http://www.openflow.org/downloads/openflow-1.0.0.tar.gz
tar xpf openflow-1.0.0.tar.gz
cd openflow-1.0.0
./configure
make
cd ..
cd tcpdump-4.3.0
patch -p1 < ../tcpdump-4.3-openflow-decode.patch
./configure
make

sudo mv /usr/sbin/tcpdump /usr/sbin/tcpdump.orig
sudo cp tcpdump /usr/sbin

cat << EOF > ./run_tcpdump.sh
#!/bin/sh

xterm -e tcpdump -vv -i br-int &
EOF
chmod 777 ./run_tcpdump.sh

else
   echo "Patch $FILE does  exist."
fi
}


pkg_start_tcpdump()
{

xterm -e tcpdump -vv -i br-int &
}

pkg_configure_bridge_from_wan()
{
strIP=`ifconfig eth0 | awk '/inet addr/ {split ($2,A,":"); print A[2]}'`
if [ ! -z "$strIP" ]; then
   strGW=`route -n | grep 'UG[ \t]' | awk '{print $2}'`
   strNetMask=`ifconfig eth0 | sed -rn '2s/ .*:(.*)$/\1/p'`
   ifconfig br-int $strIP netmask $strNetMask
   route add default gw $strGW br-int
   ifconfig eth0 0
fi 
}

pkg_print_network()
{

echo "Using IP $strIP"

echo "Gateway $strGW"
echo "NetMask $strNetMask"

ifconfig br-int 
ifconfig eth0
ovs-vsctl show

}


pkg_configure_set_contoller()
{
ovs-vsctl set-controller br-int tcp:$strIP:6633
}

pkg_start_vm_qemu()
{
# this could be done more elegantly with libvirtd
for ((i=1; i <= 3; i++ ))
do
   kvm -m 128 \
    -hda debian6_standard.qcow2 \
    -net tap,script=/etc/ovs-ifup,downscript=/etc/ovs-ifdown \
    -net nic,macaddr=22:22:22:00:cc:0$i \
    -k en-us -usb -usbdevice tablet --daemonize
done
}

pkg_add_asus_ath_eth()
{

wget https://www.kernel.org/pub/linux/kernel/projects/backports/2013/03/04/compat-drivers-2013-03-04-u.tar.bz2
./scripts/driver-select alx
tar xvjpf compat-drivers-2013-03-04-u.tar.bz2 
cd compat-drivers-2013-03-04-u/
./scripts/driver-select alx
make  && make install && modprobe alx

}

pkg_add_avior()
{

wget http://openflow.marist.edu/static/download/avior-1.3_linux_x64.jar
cat << EOF > ./run_avior.sh
#!/bin/sh

xterm -e java -jar avior-1.3_linux_x64.jar  & 
EOF
chmod 777 ./run_avior.sh


}

pkg_add_vlc()
{

sudo apt-get install -y vlc vlc-nox libavcodec-extra-53
cat << EOF > ./run_vlc.sh
#!/bin/sh

xterm -e vlc &
EOF
chmod 777 ./run_vlc.sh

}



pkg_add_sdnapp()
{

mkdir sdn-app
cd sdn-app
wget http://webpy.org/static/web.py-0.37.tar.gz
tar xvzf web.py-0.37.tar.gz
ln -s web.py-0.37/web .
sudo apt-get install -y sqlite python-pysqlite2 python-flup python-psycopg2



}



#######################

function pause()
{
   read -p "$*"
}

menu_list()
{
    tput clear
    echo " Task Menu"
    echo " ========="
    echo " 1) Make SDN-OpenFlow-Lab work area (optional) ..."
    echo " 2) Purge some packages and create more space (optional) ..."
    echo " 3) Add ASUS Atheros NIC driver (platform specific) ..."
    echo " 4) Add Linux KVM virtualization to host ..."
    echo " 5) Add Open vSwitch (1.9.90 + VXLAN) to the host system ..."
    echo " 6) Remove Open vSwitch from the host system ..."
    echo " 7) Add Floodlight Controller  ..."
    echo " 8) Add POX Controller  ..."
    echo " 9) Add RYU Controller  ..."
    echo "10) Add POX Desk Controller  ..."
    echo "11) Create br-int and swap with WAN (eth0) configuration (OVS br-int specific) ..."
    echo "12) Show network (OVS br-int specific) ..."
    echo "13) Add tcpdump with Openflow message decoding  ..."
    echo "14) Add required packages  ..."
    echo "15) Add Avior package  ..."
    echo "16) Add VLC package  ..."
    echo "17) Add Floodlight Developer package  ..."
    echo "18) (Q)uit"
    echo -n "Make choice [ENTER]: "


}

MAX=19
SDN_Dir="SDN-OpenFlow-Lab"
[ -d $SDN_Dir ] && cd $SDN_Dir

while :
do
menu_list
read instnum
#if [ $instnum -gt 0 ]; then
#if [ $instnum -lt $MAX ]; then
case "$instnum" in
  1)  
    if [ ! -d $SDN_Dir ]; then
    echo "Make SDN-OpenFlow-Lab work area (optional) ..."
    mkdir -p SDN-OpenFlow-Lab
    cd SDN-OpenFlow-Lab/
    fi
    pwd
    pause 'Press [Enter] key to continue...'
    ;;
  2)  
    echo "Purge some packages and create more space (optional) ..."
    pkg_purge
    pause 'Press [Enter] key to continue...'
    ;;
  3)  
    echo "Add ASUS Atheros NIC driver (platform specific) ..."
    pkg_add_asus_ath_eth
    pause 'Press [Enter] key to continue...'
    ;;
  4) 
    echo "Add Linux KVM virtualization to host ..."
    pkg_add_kvm
    pause 'Press [Enter] key to continue...'
    ;;
  5) 
    echo "Add Open vSwitch to the host system ..."
    pkg_add_ovs_base
    pause 'Press [Enter] key to continue...'
    ;;
  6) 
    echo "Add Open vSwitch (1.9.90 + VXLAN) to the host system ..."
    # add OS base so we can later purge
    pkg_add_ovs_base
    pkg_add_ovs_mystery
    pause 'Press [Enter] key to continue...'
    ;;
  6) 
    echo "Remove Open vSwitch from the host system ..."
    sudo apt-get purge openvswitch
    pause 'Press [Enter] key to continue...'
    ;;
  7) 
    echo "Add Floodlight Controller  ..."
    pkg_add_floodlight
    pause 'Press [Enter] key to continue...'
    ;;
  8) 
    echo "Add POX Controller  ..."
    pkg_add_pox
    pause 'Press [Enter] key to continue...'
    ;;
  9) 
    echo "Add RYU Controller  ..."
    pkg_add_ryu
    pause 'Press [Enter] key to continue...'
    ;;
  10) 
    echo "Add POX Desk Controller  ..."
    pkg_add_poxdesk
    pause 'Press [Enter] key to continue...'
    ;;
  11) 
    echo "XXXXXX  ..."
    pause 'Press [Enter] key to continue...'
    ;;
  12) 
    echo "Show network  ..."
    pkg_print_network
    pause 'Press [Enter] key to continue...'
    ;;
  13) 
    echo "Add tcpdump with Openflow message decoding  ..."
    pkg_add_tcpdump
    pause 'Press [Enter] key to continue...'
    ;;
  14) 
    echo "Add required packages  ..."
    pkg_add
    pause 'Press [Enter] key to continue...'
    ;;
  15) 
    echo "Add Avior package  ..."
    pkg_add_avior
    pause 'Press [Enter] key to continue...'
    ;;
  16) 
    echo "Add VLC package  ..."
    pkg_add_vlc
    pause 'Press [Enter] key to continue...'
    ;;
  17)
    echo "Add Floodlight Development package  ..."
    pkg_add_floodlight_dev
    pause 'Press [Enter] key to continue...'
   ;;
  q| Q | 18) exit
   ;;
  *) echo "Option number $instnum is not valid"
   ;;
esac

#fi
#fi
done

exit

pkg_purge
pkg_add

pkg_add_asus_ath_eth
pkg_add_kvm
pkg_add_ovs_base

pkg_add_ovs_mystery
pkg_configure_ovs
pkg_add_floodlight
pkg_start_floodlight
pkg_add_pox
pkg_start_pox
pkg_add_poxdesk
pkg_start_poxdesk
pkg_add_ryu
pkg_configure_network

pkg_add_tcpdump
pkg_start_tcpdump
pkg_print_network

# Needs work
pkg_configure_set_contoller
pkg_configure_bridge_from_wan
pkg_start_vm_qemu 

#./run_floodlight.sh 


