#!/bin/sh

ulimit -n 1048576
 
#For XorPlus or Openflow boot menu
export boot_menu_dir="/pica/config"
export boot_menu_file="/pica/config/boot.lst"
if [ -f ${boot_menu_file} ]; then
    . ${boot_menu_file}
else
    mkdir -p ${boot_menu_dir}
    touch ${boot_menu_file}
    echo "#!/bin/sh" >> ${boot_menu_file}
    echo "####1  XorPlus, 2 Open vSwitch, 3 Linux Shell" >> ${boot_menu_file}
    echo "choice=1" >> ${boot_menu_file} 
	echo "####manual or auto running, used by Open vSwitch" >> ${boot_menu_file}
	echo "manual_start=" >> ${boot_menu_file}
	echo "####switch static ip, used by Open vSwitch" >> ${boot_menu_file}
    echo "switch_ovs_ip=" >> ${boot_menu_file}
    echo "####switch gateway ip, used by Open vSwitch" >> ${boot_menu_file}
    echo "gateway_ovs_ip=" >> ${boot_menu_file}	
	echo "####switch database file, used by Open vSwitch" >> ${boot_menu_file}
    echo "ovs_database=" >> ${boot_menu_file}
	echo "####server IP, used by Open vSwitch" >> ${boot_menu_file}
	echo "ovs_server=" >> ${boot_menu_file}
	echo "####server port, used by Open vSwitch" >> ${boot_menu_file}
	echo "ovs_server_port=" >> ${boot_menu_file}

fi

#TODO: check if ipv4/ipv6 format
is_v4_ipnet ()
{
    dot=`echo $1 | awk -F '[.|/]' '{print NF-1}'`
    if [ $dot -ne 4 ]; then
        return 1
    fi

    #verify the IP
    count=0
    for var in `echo $1 | awk -F '[.|/]' '{print $1, $2, $3, $4}'`
    do
        echo $var | grep "^[0-9]*$" &>/dev/null
        if [ $? -ne 0 ]; then
            return 1
        fi

        if [ $var -ge 0 -a $var -le 255 ] ; then
            count=`expr $count + 1`
            continue
        else
            return 1
        fi
    done

    #verify the netmask
	netmask=`echo $1 | awk -F '/' '{print $2}'`
    echo $netmask | grep "^[0-9]*$" &>/dev/null
    if [ $? -ne 0 ]; then
        return 1
    fi

    if [ $netmask -ge 0 -a $netmask -le 32 ] ; then
        count=`expr $count + 1`
    else
        return 1
    fi

    if [ $count -eq 5 ]; then
        return 0
    else
        return 1
    fi
}

is_v4_ip ()
{
    dot=`echo $1 | awk -F '.' '{print NF-1}'`
    if [ $dot -ne 3 ]; then
        return 1
    fi

    count=0
    for var in `echo $1 | awk -F. '{print $1, $2, $3, $4}'`
    do
        echo $var | grep "^[0-9]*$" &>/dev/null
        if [ $? -ne 0 ]; then
            return 1
        fi

        if [ $var -ge 0 -a $var -le 255 ] ; then
            count=`expr $count + 1`
            continue
        else
            return 1
        fi
    done

    if [ $count -eq 4 ]; then
        return 0
    else
        return 1
    fi
}


is_dpid ()
{
	if [ $1 == "NULL" ]; then
		return 0
	fi
	
	num=`echo $1 | awk '{print length($1)}'`
	if [ $num -ne 12 ]; then
		return 1
	fi

	hexMode=`echo $1 |grep '[a-fA-F0-9]\{12\}'`
	if [ -z $hexMode ]; then
		return 1
	fi
}


# clear screen
# clear 

echo "System initiating...Please wait..."

echo "    Please choose which to start: Pica8 XorPlus, OpenFlow, or System shell:"
echo "        (Will choose default entry if no input in 10 seconds.)"

if [ ! -z ${choice} ]; then
    if [ ${choice} = 1 ]; then
        echo "        [1]  Pica8 XorPlus   * default"
    else
        echo "        [1]  Pica8 XorPlus"
    fi
else
    echo "        [1]  Pica8 XorPlus   * default"
fi


if [ ! -z ${choice} ]; then
    if [ ${choice} = 2 ]; then
        echo "        [2]  Open vSwitch   * default"
    else
        echo "        [2]  Open vSwitch"
    fi
else
    echo "        [2]  Open vSwitch"
fi


if [ ! -z ${choice} ]; then
    if [ ${choice} = 3 ]; then
        echo "        [3]  System shell   * default"
    else
        echo "        [3]  System shell"
    fi
else 
    echo "        [3]  System shell"
fi

echo "        [4]  Boot menu editor"

#Don't provide exit now.
#[Q]uit

while true; do
    if [ -z ${choice} ]; then
        choice=1
    fi
    read -t 10 -p "Enter your choice (1,2,3,4):" choice

    case $choice in
    1|p|P)
        echo 
        echo "Pica8 XorPlus L2/L3 switch system is selected."
        cat /proc/net/dev | grep eth0 >> /dev/null 
        if [ $? -eq 0 ]
        then
            ifconfig eth0 up
        fi
        cat /proc/net/dev | grep eth1 >> /dev/null 

        if [ $? -eq 0 ]
        then
            ifconfig eth1 up
        fi
        picash_tty.sh
        ;;
        
    2|v|V)
        echo 
        echo "Open vSwitch is selected."
        echo ""
        echo "  Note: Defaultly, the OVS server is runned with static local management IP and port 6633. "
        echo "        The default way of vswitch connecting to server is PTCP."
        echo "        If you do not want default configuration, choose manual start!"
        echo
        
        #disabe tacacs, in case some body use XorPlus and enable tacacs, the config is on CF card
        /pica/bin/shell/tacacs_disable.sh true
        
        #enalbe sshd service
        /usr/sbin/sshd
        #enable telnetd service
        sed -i "s/disable.*/disable = no/" /etc/xinetd.d/telnet
        pid=`pidof xinetd`
        [ $pid ] && kill -9 $pid
        xinetd -pidfile /tmp/run/xinetd.pid -stayalive

		##decide to how to start the OVS
		if [ -z ${manual_start} ]; then
			read -p "Do you want start the OVS by manual? (yes/no) " manual_start 
			if [ -z ${manual_start} ] ; then
				manual_start=no 
			fi
		fi
		
		if [ ${manual_start} = "yes" ]; then
			echo "You need start the OVS by manual!"
			echo
			exit 0
		fi

		##set IP of management 
		echo


        while true; do
            if [ -z ${switch_ovs_ip}  ]; then
                echo -n "Please set a static IP and netmask for the switch (e.g. 128.0.0.10/24) : "
                read switch_ovs_ip
            else
                echo "Static IP for the switch is: ${switch_ovs_ip}"
            fi
            is_v4_ipnet ${switch_ovs_ip}
            case $? in
                0)
                    break
                    ;;
                1)
                    switch_ovs_ip=""
                    echo "Your input IP/Net is invalid, please input again."
                    ;;
            esac
        done

			switch_ovs_ip_add=`echo $switch_ovs_ip | awk -F '/' '{print $1}'`
			switch_ovs_ip_net=`echo $switch_ovs_ip | awk -F '/' '{print $2}'`
			
            #calcult the mask
			part_1=`expr $switch_ovs_ip_net / 8`
			if [ "$part_1" -eq 0 ] ; then
				part_2=`expr $switch_ovs_ip_net % 8`
				x=$part_2
				y=`expr 8 - $x`
				let z=2**$y
				i=`expr 256 - $z`
				switch_ovs_ip_netmask="$i.0.0.0"
			fi		  
			if [ "$part_1" -eq 1 ] ; then
				part_2=`expr $switch_ovs_ip_net % 8`
				x=$part_2
				y=`expr 8 - $x`
				let z=2**$y
				i=`expr 256 - $z`
				switch_ovs_ip_netmask="255.$i.0.0"
			fi
			if [ "$part_1" -eq 2 ] ; then
				part_2=`expr $switch_ovs_ip_net % 8`
				x=$part_2
				y=`expr 8 - $x`
				let z=2**$y
				i=`expr 256 - $z`
				switch_ovs_ip_netmask="255.255.$i.0"
			fi
			if [ "$part_1" -eq 3 ] ; then
				part_2=`expr $switch_ovs_ip_net % 8`
				x=$part_2
				y=`expr 8 - $x`
				let z=2**$y
				i=`expr 256 - $z`
				switch_ovs_ip_netmask="255.255.255.$i"
			fi
			if [ "$part_1" -eq 4 ] ; then
				switch_ovs_ip_netmask="255.255.255.255"
			fi
			


		##set gateway of OVS
		echo

        while true; do
            if [ -z ${gateway_ovs_ip} ]; then
                read -p "Please set the gateway IP (e.g 172.168.1.2):" gateway_ovs_ip
            else
                echo "Gateway is: ${gateway_ovs_ip} "
            fi
            is_v4_ip ${gateway_ovs_ip}
            case $? in
                0)
                    break
                    ;;
                1)
                    gateway_ovs_ip=""
                    echo "Your input gateway is invalid, please input again."
                    ;;
            esac
        done


		##create the database of OVS server
		echo 
		
		if [ -z ${ovs_database} ]; then
			read -p "Specify the file name of database for server, if not exist, it will be created: " ovs_database
		else
			echo "The database is ${ovs_database}."
		fi
		if [ -z ${ovs_database} ] ; then
			echo "Choose the default database file /ovs/ovs-vswitchd.conf.db!"
			ovs_database="ovs-vswitchd.conf.db"
		fi
		
		if [ -f /ovs/$ovs_database ]; then
			echo "System have found the database file!"
			echo 
		else
			echo "Have not found the database file, creating it ......"
			ovsdb-tool create /ovs/$ovs_database /ovs/bin/vswitch.ovsschema
			sleep 5
			echo "Done!"
			echo
		fi

		##configure the IP and gateway
		ifconfig eth0 $switch_ovs_ip_add netmask $switch_ovs_ip_netmask up
		echo "Waitting for eth0 up ......"
		sleep 20
		echo "Done!"
		echo ""
		echo "Adding the gateway ......"
		route add default gw $gateway_ovs_ip
		sleep 2

		##Start the OVS server daemon
		echo "Run the ovsdb-server with $switch_ovs_ip_add and port 6633 with ptcp ......"
		ovsdb-server /ovs/$ovs_database --remote=ptcp:6633:$switch_ovs_ip_add &
		echo "Waitting for ovsdb-server ......"
		sleep 5
		echo "Done!"
		echo

		##Start the OVS vswitch
		echo "Run the ovs-vswitchd with $switch_ovs_ip_add and port 6633 with ptcp ......"
		ovs-vswitchd tcp:$switch_ovs_ip_add:6633 --pidfile=ovs-vswitchd.pid --overwrite-pidfile > /dev/null 2>/dev/null &
		echo "Waitting for ovs-vswitchd ......"
		sleep 25
		echo "Done!"
		echo 
		echo "Startup finished!"
		echo
		hostname -F /etc/hostname
        export PS1="`whoami`@`hostname`#"
		sleep 2
		sh
		;;
        
    3|s|S)
        ash
        ;;
	
    4|b|B)
        boot_menu_editor.sh
        ;;
	
    q|Q)
        #Don't provide exit now.
        #exit
        ;;
    esac 
done

# $Id$ 

