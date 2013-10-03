#!/usr/bin/perl -w

#
#  install 
#  sudo perl -MCPAN -e shell 
#  cpan> install JSON::RPC
#  cpan> install JSON::RPC::Server::Daemon
#  cpan> install COPS::Client
#  cpan> install threads
#
#  see documentation at:
#  http://search.cpan.org/~dmaki/JSON-RPC-1.03/lib/JSON/RPC/Legacy.pm
#  http://search.cpan.org/~shamrock/COPS-Client-0.05/lib/COPS/Client.pm
#
#  pcmm app with restful json api server with could be called remotely
#  and a text menu to operate some  basic services

# TODO  
# - How to get the menu input and json server handler on a thread or non-blocking
# - How to implement the the service flow modify classifier
# - Catch and set the returned sf1_gate_id and sf2_gate_id from add
# - Review the parameters used when add_sf1 and add_sf2
#
#  20130902 		Init					TEK
#  20130903 		Add a menu 				TEK
#  20130911 		Change SF to BE and rewrite toggle 	TEK
#
#


use strict;
use COPS::Client;
use JSON::RPC;
# Daemon version
use JSON::RPC::Server::Daemon;

#---------------------------------------
my $be1_traffic_rate=2500000;
my $be2_traffic_rate=500000;
my $be1_sourceport = 8081;
my $be2_sourceport = 1369;
my $cmts_ip = "10.32.4.3";
my $subscriber = "10.32.104.2";
my $destip = "10.32.4.208";
my $sourceip = "10.32.154.2";
my $sourceport = "8081";
my $radius = "192.168.50.2";
my $global_debug = 0;  # 0 = off 1-10 = verbose
my $be2_class_priority = 69;
my $be1_class_priority = 69;
#---------------------------------------
my $sf1_grant_size=1000;
my $sf1_grants_per_interval=3;
my $sf1_grant_interval=8000;
my $sf2_grant_size=500;
my $sf2_grants_per_interval=1;
my $sf2_grant_interval=7000;
my $protocol_id=0;
my $cops_client;
my $connected = 0;
my $sf1_gate_id = 0;
my $sf2_gate_id = 0;
my $command_set = 0;
# Authorization life timer
my $gate_T1 = 200;
# Authorization renew timer
my $gate_T2 = 300;
# Reservation life timer
#my $gate_T3 = 60;
my $gate_T3 = 0;
# Reservation renew timer
#my $gate_T4 = 30;
my $gate_T4 = 0;
my $server;
my $toggle = 1;



my $menu1 = [
         "Main Menu",
         [ "Add Service Flow 1",    \&add_be1 ],
         [ "Add Service Flow 2",    \&add_be2 ],
         [ "Remove Service Flow 1", \&rem_sf1 ],
         [ "Remove Service Flow 2", \&rem_sf2 ],
         [ "Toggle Classifier (flip class)", \&toggle_classifier ],
         [ "Toggle Classifier (sf del/add)", \&toggle_classifier2 ],
         [ "Toggle Classifier (raise/lower be2 priority)", \&toggle_classifier3 ],
         [ "Print Stuff", \&print_stuff ], 
         [ "Quit", \&quit ], 
     ];
         #[ "Add UGS Service Flow 1",    \&add_sf1 ],
         #[ "Add UGS Service Flow 2",    \&add_sf2 ],
         #[ "Modify Service Flow 1", \&mod_sf1 ],
         #[ "Modify Service Flow 2", \&mod_sf2 ],
         #[ "Two Service Flow Adds on a Single Open", \&add_sf1_2 ], 
         #[ "Add BE Service Flow 1",    \&add_be1 ],
         #[ "Add BE Service Flow 2",    \&add_be2 ],

sub print_stuff {
    print "Service Flow 1 Gate ID: ", $sf1_gate_id,  " \n" ;
    print "Service Flow 2 Gate ID: ", $sf2_gate_id,  " \n" ;
    print "Toggle value: ", $toggle, " \n" ;
    print "CMTS IP: ",  $cmts_ip, " \n" ;
    print "Subscriber IP (CM): ", $subscriber," \n" ;
    print "DestIP: ", $destip, " \n" ;
    print "Source IP: ", $sourceip, " \n" ;
    print "Source Port: ", $sourceport, " \n" ;
    print "Radius IP: ", $radius, " \n" ;
    print "BE1 Traffic Rate : ", $be1_traffic_rate, " \n" ;
    print "BE2 Traffic Rate : ", $be2_traffic_rate, " \n" ;
    #print "SF1 Grant Size: ", $sf1_grant_size, " \n" ;
    #print "SF1 Grants Per Interval: ", $sf1_grants_per_interval, " \n" ;
    #print "SF1 Grant Interval: ", $sf1_grant_interval, " \n" ;
    #print "SF2 Grant Size: ", $sf2_grant_size, " \n" ;
    #print "SF2 Grants Per Interval: ", $sf2_grants_per_interval, " \n" ;
    #print "SF2 Grant Interval: ", $sf2_grant_interval, " \n" ;
    print "Protocol ID: ", $protocol_id, " \n" ;
    print "COPS Client: ", $cops_client, " \n" ;
    print "Connected: ", $connected, " \n" ;
    print "Global Debug: ", $global_debug, " \n" ;

}


sub pcmm_open {

    my ( $debug ) = shift;
    $cops_client = new COPS::Client (
                        [
                        VendorID => 'COPS Client',
                        ServerIP => $cmts_ip,
                        ServerPort => '3918',
                        Timeout => 2,
                        DEBUG => $debug,
			DataHandler => \&display_data
                        ]
                        );
   if ( $cops_client->connect() ) {
	$connected = 1;
   } else {
        print "Error connecting to the PCMM server \n" ;
   }

}

sub pcmm_close {
   $cops_client->disconnect();
   $connected = 0;
}

sub set_sf1_gate_id
{
    my ( $self ) = shift;
    my ( $data ) = shift;
    $sf1_gate_id = ${$data}{'GateId_GateIdentifier'}
}

sub set_sf2_gate_id
{
    my ( $self ) = shift;
    my ( $data ) = shift;
    $sf2_gate_id = ${$data}{'GateId_GateIdentifier'}
}



sub display_data
{
    my ( $self ) = shift;
    my ( $data ) = shift;

    print "Report Information Received.\n\n";
    foreach my $name ( sort { $a cmp $b } keys %{$data} )
    {
        print "Name  is '$name' value is '${$data}{$name}'\n";
    }
    if ($command_set) {
    if (!$sf1_gate_id ) { 
	$sf1_gate_id = ${$data}{'GateId_GateIdentifier'} 
    } else {
        if (!$sf2_gate_id ) { $sf2_gate_id = ${$data}{'GateId_GateIdentifier'} }
    }
    }
}

sub add_sf1_2 { 
    print "Add service flow 1\n" ;
    pcmm_open(10);
    if ($connected) {
	$cops_client->set_command("set");
	$cops_client->subscriber_set("ipv4", $subscriber);

	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);

	$cops_client->envelope_add (
			[
			Envelope_Type		=> "authorize,reserve,commit",
			Service_Type		=> 'Unsolicited Grant Service',

			'Envelope_authorize_Request Transmission Policy' => 0x037F,
			'Envelope_authorize_Unsolicited Grant Size' => 300,
			'Envelope_authorize_Grants Per Interval' => 1,
			'Envelope_authorize_Nominal Grant Interval' => 20000,
			'Envelope_authorize_Tolerated Grant Jitter' => 800,
			'Envelope_authorize_Required Attribute Mask' => 0,
			'Envelope_authorize_Forbidden Attribute Mask' => 0,

			'Envelope_reserve_Request Transmission Policy' => 0x037F,
			'Envelope_reserve_Unsolicited Grant Size' => 300,
			'Envelope_reserve_Grants Per Interval' => 1,
			'Envelope_reserve_Nominal Grant Interval' => 20000,
			'Envelope_reserve_Tolerated Grant Jitter' => 800,
			'Envelope_reserve_Required Attribute Mask' => 0,
			'Envelope_reserve_Forbidden Attribute Mask' => 0,

			'Envelope_commit_Request Transmission Policy' => 0x037F,
			'Envelope_commit_Unsolicited Grant Size' => 300,
			'Envelope_commit_Grants Per Interval' => 1,
			'Envelope_commit_Nominal Grant Interval' => 20000,
			'Envelope_commit_Tolerated Grant Jitter' => 800,
			'Envelope_commit_Required Attribute Mask' => 0,
			'Envelope_commit_Forbidden Attribute Mask' => 0,

			]
			);

    	$cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => 6,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => 8081, 
        		EClassifier_SourcePortEnd => 8081, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 1,
        		EClassifier_Priority => 64,
        		EClassifier_State => 1,
        		EClassifier_Action => 0,
        		]
        		);
			# some bug when adding these
        		# EClassifier_SourceMask => "255.255.255.255",
        		# EClassifier_DestinaionMask => "255.255.255.255",


        $cops_client->{_GLOBAL}{'DataHandler'} = \&set_sf1_gate_id;
	$cops_client->check_data_available();
        print "GateID = ", $sf1_gate_id, "\n";
        $cops_client->{_GLOBAL}{'DataHandler'} = \&data_display;

        $cops_client->{_GLOBAL}{'message_opcode'}='OPN';
	$cops_client->set_command("set");
	$cops_client->subscriber_set("ipv4", $subscriber);

	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);


	$cops_client->envelope_add (
			[
			Envelope_Type		=> "authorize,reserve,commit",
			Service_Type		=> 'Unsolicited Grant Service',

			'Envelope_authorize_Request Transmission Policy' => 0x037F,
			'Envelope_authorize_Unsolicited Grant Size' => 500,
			'Envelope_authorize_Grants Per Interval' => 1,
			'Envelope_authorize_Nominal Grant Interval' => 7000,
			'Envelope_authorize_Tolerated Grant Jitter' => 800,
			'Envelope_authorize_Required Attribute Mask' => 0,
			'Envelope_authorize_Forbidden Attribute Mask' => 0,

			'Envelope_reserve_Request Transmission Policy' => 0x037F,
			'Envelope_reserve_Unsolicited Grant Size' => 500,
			'Envelope_reserve_Grants Per Interval' => 1,
			'Envelope_reserve_Nominal Grant Interval' => 7000,
			'Envelope_reserve_Tolerated Grant Jitter' => 800,
			'Envelope_reserve_Required Attribute Mask' => 0,
			'Envelope_reserve_Forbidden Attribute Mask' => 0,

			'Envelope_commit_Request Transmission Policy' => 0x037F,
			'Envelope_commit_Unsolicited Grant Size' => 500,
			'Envelope_commit_Grants Per Interval' => 1,
			'Envelope_commit_Nominal Grant Interval' => 7000,
			'Envelope_commit_Tolerated Grant Jitter' => 800,
			'Envelope_commit_Required Attribute Mask' => 0,
			'Envelope_commit_Forbidden Attribute Mask' => 0,

			]
			);

    	$cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => 17,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => 0, 
        		EClassifier_SourcePortEnd => 0, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 2,
        		EClassifier_Priority => 64,
        		EClassifier_State => 1,
        		EClassifier_Action => 0,
        		]
        		);
        		# EClassifier_SourceMask => "255.255.255.255",
        		# EClassifier_DestinaionMask => "255.255.255.255",


        $cops_client->{_GLOBAL}{'DataHandler'} = \&set_sf2_gate_id;
	$cops_client->check_data_available();
        print "GateID = ", $sf2_gate_id, "\n";
        $cops_client->{_GLOBAL}{'DataHandler'} = \&data_display;
	

    } else {
        print "Error not connected to the PCMM server \n" ;
    }
}


sub add_be1 { 
    print "Add service flow 1\n" ;
    pcmm_open($global_debug);
    if ($connected) {
	$cops_client->set_command("set");
	$cops_client->subscriber_set("ipv4", $subscriber);


	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);


       $cops_client->envelope_add (
                        [
                        Envelope_Type           => "authorize,reserve,commit",
                        Service_Type            => 'Best Effort Service',

                        'Envelope_authorize_Traffic Priority'   => 0,
                        'Envelope_authorize_Request Transmission Policy' => 0x0,
                        'Envelope_authorize_Maximum Sustained Traffic Rate' => $be1_traffic_rate,
                        'Envelope_authorize_Maximum Traffic Burst' => 3044,
                        'Envelope_authorize_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_authorize_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

                        'Envelope_reserve_Traffic Priority' => 0,
                        'Envelope_reserve_Request Transmission Policy' => 0x0,
                        'Envelope_reserve_Maximum Sustained Traffic Rate' => $be1_traffic_rate,
                        'Envelope_reserve_Maximum Traffic Burst' => 3044,
                        'Envelope_reserve_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_reserve_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

                        'Envelope_commit_Traffic Priority' => 0,
                        'Envelope_commit_Request Transmission Policy' => 0x0,
                        'Envelope_commit_Maximum Sustained Traffic Rate' => $be1_traffic_rate,
                        'Envelope_commit_Maximum Traffic Burst' => 3044,
                        'Envelope_commit_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_commit_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,
                        ]
                        );

    	$cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => $protocol_id,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => $be1_sourceport, 
        		EClassifier_SourcePortEnd => $be1_sourceport, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 1,
        		EClassifier_Priority => $be1_class_priority,
        		EClassifier_State => 1,
        		EClassifier_Action => 0,
        		]
        		);


        #$command_set = 1;
	#$cops_client->check_data_available();
        #$command_set = 0;
        #print "BE1 GateID = ", $sf1_gate_id, "\n";
        # $cops_client->{_GLOBAL}{'DataHandler'} = \&data_display;
        $cops_client->{_GLOBAL}{'DataHandler'} = \&set_sf1_gate_id;
	$cops_client->check_data_available();
        print "SF1 GateID = ", $sf1_gate_id, "\n";
        $cops_client->{_GLOBAL}{'DataHandler'} = \&data_display;
	

    } else {
        print "Error not connected to the PCMM server \n" ;
    }

}


sub add_be2 { 
    print "Add service flow 2\n" ;
    pcmm_open($global_debug);
    if ($connected) {
	$cops_client->set_command("set");
	$cops_client->subscriber_set("ipv4", $subscriber);


	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);


       $cops_client->envelope_add (
                        [
                        Envelope_Type           => "authorize,reserve,commit",
                        Service_Type            => 'Best Effort Service',

                        'Envelope_authorize_Traffic Priority'   => 0,
                        'Envelope_authorize_Request Transmission Policy' => 0x0,
                        'Envelope_authorize_Maximum Sustained Traffic Rate' => $be2_traffic_rate,
                        'Envelope_authorize_Maximum Traffic Burst' => 3044,
                        'Envelope_authorize_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_authorize_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

                        'Envelope_reserve_Traffic Priority' => 0,
                        'Envelope_reserve_Request Transmission Policy' => 0x0,
                        'Envelope_reserve_Maximum Sustained Traffic Rate' => $be2_traffic_rate,
                        'Envelope_reserve_Maximum Traffic Burst' => 3044,
                        'Envelope_reserve_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_reserve_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

                        'Envelope_commit_Traffic Priority' => 0,
                        'Envelope_commit_Request Transmission Policy' => 0x0,
                        'Envelope_commit_Maximum Sustained Traffic Rate' => $be2_traffic_rate,
                        'Envelope_commit_Maximum Traffic Burst' => 3044,
                        'Envelope_commit_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_commit_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,
                        ]
                        );

    	$cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => $protocol_id,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => $be2_sourceport, 
        		EClassifier_SourcePortEnd => $be2_sourceport, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 2,
        		EClassifier_Priority => $be2_class_priority,
        		EClassifier_State => 1,
        		EClassifier_Action => 0,
        		]
        		);


        #$command_set = 1;
	#$cops_client->check_data_available();
        #$command_set = 0;
        #print "BE2 GateID = ", $sf2_gate_id, "\n";
        # $cops_client->{_GLOBAL}{'DataHandler'} = \&data_display;
	
        $cops_client->{_GLOBAL}{'DataHandler'} = \&set_sf2_gate_id;
	$cops_client->check_data_available();
        print "SF2 GateID = ", $sf2_gate_id, "\n";
        $cops_client->{_GLOBAL}{'DataHandler'} = \&data_display;

    } else {
        print "Error not connected to the PCMM server \n" ;
    }

}



sub add_sf1 { 
    print "Add service flow 1\n" ;
    pcmm_open($global_debug);
    if ($connected) {
	$cops_client->set_command("set");
	$cops_client->subscriber_set("ipv4", $subscriber);


	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);


	$cops_client->envelope_add (
			[
			Envelope_Type		=> "authorize,reserve,commit",
			Service_Type		=> 'Unsolicited Grant Service',

			'Envelope_authorize_Request Transmission Policy' => 0x037F,
			'Envelope_authorize_Unsolicited Grant Size' => $sf1_grant_size,
			'Envelope_authorize_Grants Per Interval' => $sf1_grants_per_interval,
			'Envelope_authorize_Nominal Grant Interval' => $sf1_grant_interval,
			'Envelope_authorize_Tolerated Grant Jitter' => 800,
			'Envelope_authorize_Required Attribute Mask' => 0,
			'Envelope_authorize_Forbidden Attribute Mask' => 0,

			'Envelope_reserve_Request Transmission Policy' => 0x037F,
			'Envelope_reserve_Unsolicited Grant Size' => $sf1_grant_size,
			'Envelope_reserve_Grants Per Interval' => $sf1_grants_per_interval,
			'Envelope_reserve_Nominal Grant Interval' => $sf1_grant_interval,
			'Envelope_reserve_Tolerated Grant Jitter' => 800,
			'Envelope_reserve_Required Attribute Mask' => 0,
			'Envelope_reserve_Forbidden Attribute Mask' => 0,

			'Envelope_commit_Request Transmission Policy' => 0x037F,
			'Envelope_commit_Unsolicited Grant Size' => $sf1_grant_size,
			'Envelope_commit_Grants Per Interval' => $sf1_grants_per_interval,
			'Envelope_commit_Nominal Grant Interval' => $sf1_grant_interval,
			'Envelope_commit_Tolerated Grant Jitter' => 800,
			'Envelope_commit_Required Attribute Mask' => 0,
			'Envelope_commit_Forbidden Attribute Mask' => 0,

			]
			);

    	$cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => $protocol_id,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => 8081, 
        		EClassifier_SourcePortEnd => 8081, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 1,
        		EClassifier_Priority => 64,
        		EClassifier_State => 1,
        		EClassifier_Action => 0,
        		]
        		);


        #$command_set = 1;
	#$cops_client->check_data_available();
        #$command_set = 0;
        #print "SF1 GateID = ", $sf1_gate_id, "\n";
        $cops_client->{_GLOBAL}{'DataHandler'} = \&set_sf1_gate_id;
	$cops_client->check_data_available();
        print "SF1 GateID = ", $sf1_gate_id, "\n";
        $cops_client->{_GLOBAL}{'DataHandler'} = \&data_display;
	

    } else {
        print "Error not connected to the PCMM server \n" ;
    }

}

sub add_sf2 { 
    print "Add service flow 2\n" ;
    pcmm_open($global_debug);
    if ($connected) {
	$cops_client->set_command("set");
	$cops_client->subscriber_set("ipv4", $subscriber);

	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);


	$cops_client->envelope_add (
			[
			Envelope_Type		=> "authorize,reserve,commit",
			Service_Type		=> 'Unsolicited Grant Service',

			'Envelope_authorize_Request Transmission Policy' => 0x037F,
			'Envelope_authorize_Unsolicited Grant Size' => $sf2_grant_size,
			'Envelope_authorize_Grants Per Interval' => $sf2_grants_per_interval,
			'Envelope_authorize_Nominal Grant Interval' => $sf2_grant_interval,
			'Envelope_authorize_Tolerated Grant Jitter' => 800,
			'Envelope_authorize_Required Attribute Mask' => 0,
			'Envelope_authorize_Forbidden Attribute Mask' => 0,

			'Envelope_reserve_Request Transmission Policy' => 0x037F,
			'Envelope_reserve_Unsolicited Grant Size' => $sf2_grant_size,
			'Envelope_reserve_Grants Per Interval' => $sf2_grants_per_interval,
			'Envelope_reserve_Nominal Grant Interval' => $sf2_grant_interval,
			'Envelope_reserve_Tolerated Grant Jitter' => 800,
			'Envelope_reserve_Required Attribute Mask' => 0,
			'Envelope_reserve_Forbidden Attribute Mask' => 0,

			'Envelope_commit_Request Transmission Policy' => 0x037F,
			'Envelope_commit_Unsolicited Grant Size' => $sf2_grant_size,
			'Envelope_commit_Grants Per Interval' => $sf2_grants_per_interval,
			'Envelope_commit_Nominal Grant Interval' => $sf2_grant_interval,
			'Envelope_commit_Tolerated Grant Jitter' => 800,
			'Envelope_commit_Required Attribute Mask' => 0,
			'Envelope_commit_Forbidden Attribute Mask' => 0,

			]
			);

    	$cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => $protocol_id,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => 0, 
        		EClassifier_SourcePortEnd => 0, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 2,
        		EClassifier_Priority => 64,
        		EClassifier_State => 1,
        		EClassifier_Action => 0,
        		]
        		);


        #$command_set = 1;
	#$cops_client->check_data_available();
        #$command_set = 0;
        # print "SF2 GateID = ", $sf2_gate_id, "\n";
        $cops_client->{_GLOBAL}{'DataHandler'} = \&set_sf2_gate_id;
	$cops_client->check_data_available();
        print "SF2 GateID = ", $sf2_gate_id, "\n";
        $cops_client->{_GLOBAL}{'DataHandler'} = \&data_display;


    } else {
        print "Error not connected to the PCMM server \n" ;
    }

}

# we can modify both SFs or flip the EClassifier_State.
# in either case both sf1 and sf2 need to be modified for a single toggle afaik.

sub mod_be1 { 
    my ( $on ) = shift;
    my $xport;
    if ( $on) {
       $xport = $sourceport; 
    } else {
       $xport = 1369; 
    }
    print "Modify service flow 1 $sf1_gate_id\n";
    pcmm_open($global_debug);
    if ($connected) {
        $cops_client->set_command("set");
        $cops_client->set_gate_id($sf1_gate_id);
        $cops_client->subscriber_set("ipv4",$subscriber);
	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);

       $cops_client->envelope_add (
                        [
                        Envelope_Type           => "authorize,reserve,commit",
                        Service_Type            => 'Best Effort Service',

                        'Envelope_authorize_Traffic Priority'   => 0,
                        'Envelope_authorize_Request Transmission Policy' => 0x0,
                        'Envelope_authorize_Maximum Sustained Traffic Rate' => $be1_traffic_rate,
                        'Envelope_authorize_Maximum Traffic Burst' => 3044,
                        'Envelope_authorize_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_authorize_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

                        'Envelope_reserve_Traffic Priority' => 0,
                        'Envelope_reserve_Request Transmission Policy' => 0x0,
                        'Envelope_reserve_Maximum Sustained Traffic Rate' => $be1_traffic_rate,
                        'Envelope_reserve_Maximum Traffic Burst' => 3044,
                        'Envelope_reserve_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_reserve_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

                        'Envelope_commit_Traffic Priority' => 0,
                        'Envelope_commit_Request Transmission Policy' => 0x0,
                        'Envelope_commit_Maximum Sustained Traffic Rate' => $be1_traffic_rate,
                        'Envelope_commit_Maximum Traffic Burst' => 3044,
                        'Envelope_commit_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_reserve_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

			]
			);

# EClassifier_ClassifierID
#        EClassifier_State            - This determines if this classifier is
#                                       Inactive or Active, values 0 and 1
#                                       respectively.
#
#        EClassifier_Action           - This has 4 possible values
#
#                                       0 - Means Add - This is the default if not
#                                                       specified.
#                                       1 - Replace
#                                       2 - Delete
#                                       3 - No Change
        $cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => $protocol_id,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => $xport, 
        		EClassifier_SourcePortEnd => $xport, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 1,
        		EClassifier_Priority => $be1_class_priority,
        		EClassifier_State => 1,
        		EClassifier_Action => 1,
        		]
        		);
       $cops_client->check_data_available();
   } else {
        print "Error not connected to the PCMM server \n" ;
   }

}

sub mod_be2 { 
    my ( $on ) = shift;
    my $xport;
    if ( $on) {
       $xport = $sourceport; 
    } else {
       $xport = 1369; 
    }
    print "Modify service flow 2 $sf2_gate_id\n";
    pcmm_open($global_debug);
    if ($connected) {
        $cops_client->set_command("set");
        $cops_client->set_gate_id($sf2_gate_id);
        $cops_client->subscriber_set("ipv4",$subscriber);
	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);

       $cops_client->envelope_add (
                        [
                        Envelope_Type           => "authorize,reserve,commit",
                        Service_Type            => 'Best Effort Service',

                        'Envelope_authorize_Traffic Priority'   => 0,
                        'Envelope_authorize_Request Transmission Policy' => 0x0,
                        'Envelope_authorize_Maximum Sustained Traffic Rate' => $be2_traffic_rate,
                        'Envelope_authorize_Maximum Traffic Burst' => 3044,
                        'Envelope_authorize_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_authorize_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

                        'Envelope_reserve_Traffic Priority' => 0,
                        'Envelope_reserve_Request Transmission Policy' => 0x0,
                        'Envelope_reserve_Maximum Sustained Traffic Rate' => $be2_traffic_rate,
                        'Envelope_reserve_Maximum Traffic Burst' => 3044,
                        'Envelope_reserve_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_reserve_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

                        'Envelope_commit_Traffic Priority' => 0,
                        'Envelope_commit_Request Transmission Policy' => 0x0,
                        'Envelope_commit_Maximum Sustained Traffic Rate' => $be2_traffic_rate,
                        'Envelope_commit_Maximum Traffic Burst' => 3044,
                        'Envelope_commit_Minimum Reserved Traffic Rate' => 0,
                        'Envelope_reserve_Assumed Minimum Reserved Traffic Rate Packet Size' => 0,

			]
			);

        $cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => $protocol_id,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => $xport, 
        		EClassifier_SourcePortEnd => $xport, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 2,
        		EClassifier_Priority => $be2_class_priority,
        		EClassifier_State => 1,
        		EClassifier_Action => 1,
        		]
        		);
       $cops_client->check_data_available();
    } else {
        print "Error not connected to the PCMM server \n" ;
    }
}

sub mod_sf1 { 
    my ( $on ) = shift;
    my $xport;
    if ( $on) {
       $xport = $sourceport; 
    } else {
       $xport = 1369; 
    }
    print "Modify service flow 1\n" ;
    pcmm_open($global_debug);
    if ($connected) {
        $cops_client->set_command("set");
        $cops_client->set_gate_id($sf1_gate_id);
        $cops_client->subscriber_set("ipv4",$subscriber);
	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);

	$cops_client->envelope_add (
			[
			Envelope_Type		=> "authorize,reserve,commit",
			Service_Type		=> 'Unsolicited Grant Service',

			'Envelope_authorize_Request Transmission Policy' => 0x037F,
			'Envelope_authorize_Unsolicited Grant Size' => $sf1_grant_size,
			'Envelope_authorize_Grants Per Interval' => $sf1_grants_per_interval,
			'Envelope_authorize_Nominal Grant Interval' => $sf1_grant_interval,
			'Envelope_authorize_Tolerated Grant Jitter' => 800,
			'Envelope_authorize_Required Attribute Mask' => 0,
			'Envelope_authorize_Forbidden Attribute Mask' => 0,

			'Envelope_reserve_Request Transmission Policy' => 0x037F,
			'Envelope_reserve_Unsolicited Grant Size' => $sf1_grant_size,
			'Envelope_reserve_Grants Per Interval' => $sf1_grants_per_interval,
			'Envelope_reserve_Nominal Grant Interval' => $sf1_grant_interval,
			'Envelope_reserve_Tolerated Grant Jitter' => 800,
			'Envelope_reserve_Required Attribute Mask' => 0,
			'Envelope_reserve_Forbidden Attribute Mask' => 0,

			'Envelope_commit_Request Transmission Policy' => 0x037F,
			'Envelope_commit_Unsolicited Grant Size' => $sf1_grant_size,
			'Envelope_commit_Grants Per Interval' => $sf1_grants_per_interval,
			'Envelope_commit_Nominal Grant Interval' => $sf1_grant_interval,
			'Envelope_commit_Tolerated Grant Jitter' => 800,
			'Envelope_commit_Required Attribute Mask' => 0,
			'Envelope_commit_Forbidden Attribute Mask' => 0,

			]
			);

# EClassifier_ClassifierID
#        EClassifier_State            - This determines if this classifier is
#                                       Inactive or Active, values 0 and 1
#                                       respectively.
#
#        EClassifier_Action           - This has 4 possible values
#
#                                       0 - Means Add - This is the default if not
#                                                       specified.
#                                       1 - Replace
#                                       2 - Delete
#                                       3 - No Change
        $cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => $protocol_id,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => $xport, 
        		EClassifier_SourcePortEnd => $xport, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 1,
        		EClassifier_Priority => 64,
        		EClassifier_State => 1,
        		EClassifier_Action => 1,
        		]
        		);
       $cops_client->check_data_available();
   } else {
        print "Error not connected to the PCMM server \n" ;
   }

}

sub mod_sf2 { 
    my ( $on ) = shift;
    my $xport;
    if ( $on) {
       $xport = $sourceport; 
    } else {
       $xport = 1369; 
    }
    print "Modify service flow 2\n" ;
    pcmm_open($global_debug);
    if ($connected) {
        $cops_client->set_command("set");
        $cops_client->set_gate_id($sf2_gate_id);
        $cops_client->subscriber_set("ipv4",$subscriber);
	$cops_client->gate_specification_add(
			[
			Direction	=> 'Upstream',
			DSCPToSMark	=> 0,
			Priority	=> 0,
			PreEmption	=> 0,

			Gate_Flags	=> 0,
	                Gate_TOSField	=> 0,
			Gate_TOSMask	=> 0,
			Gate_Class	=> 0,
			Gate_T1		=> $gate_T1,
			Gate_T2		=> $gate_T2,
			Gate_T3		=> $gate_T3,
			Gate_T4		=> $gate_T4
			]
			);
	$cops_client->envelope_add (
			[
			Envelope_Type		=> "authorize,reserve,commit",
			Service_Type		=> 'Unsolicited Grant Service',

			'Envelope_authorize_Request Transmission Policy' => 0x037F,
			'Envelope_authorize_Unsolicited Grant Size' => $sf2_grant_size,
			'Envelope_authorize_Grants Per Interval' => $sf2_grants_per_interval,
			'Envelope_authorize_Nominal Grant Interval' => $sf2_grant_interval,
			'Envelope_authorize_Tolerated Grant Jitter' => 800,
			'Envelope_authorize_Required Attribute Mask' => 0,
			'Envelope_authorize_Forbidden Attribute Mask' => 0,

			'Envelope_reserve_Request Transmission Policy' => 0x037F,
			'Envelope_reserve_Unsolicited Grant Size' => $sf2_grant_size,
			'Envelope_reserve_Grants Per Interval' => $sf2_grants_per_interval,
			'Envelope_reserve_Nominal Grant Interval' => $sf2_grant_interval,
			'Envelope_reserve_Tolerated Grant Jitter' => 800,
			'Envelope_reserve_Required Attribute Mask' => 0,
			'Envelope_reserve_Forbidden Attribute Mask' => 0,

			'Envelope_commit_Request Transmission Policy' => 0x037F,
			'Envelope_commit_Unsolicited Grant Size' => $sf2_grant_size,
			'Envelope_commit_Grants Per Interval' => $sf2_grants_per_interval,
			'Envelope_commit_Nominal Grant Interval' => $sf2_grant_interval,
			'Envelope_commit_Tolerated Grant Jitter' => 800,
			'Envelope_commit_Required Attribute Mask' => 0,
			'Envelope_commit_Forbidden Attribute Mask' => 0,

			]
			);
        $cops_client->classifier_add(
        		[
        		Classifier_Type         => 'Extended',
        		EClassifier_IPProtocolId => $protocol_id,
        		EClassifier_TOSField => 0,
        		EClassifier_TOSMask => 0,
        		EClassifier_SourceIP => $sourceip,
        		EClassifier_DestinationIP => $destip, 
        		EClassifier_SourcePortStart => $xport, 
        		EClassifier_SourcePortEnd => $xport, 
        		EClassifier_DestinationPortStart => 0,
        		EClassifier_DestinationPortEnd => 0,
        		EClassifier_ClassifierID => 2,
        		EClassifier_Priority => 64,
        		EClassifier_State => 1,
        		EClassifier_Action => 1,
        		]
        		);
       $cops_client->check_data_available();
    } else {
        print "Error not connected to the PCMM server \n" ;
    }
}

sub rem_sf1 { 
    print "Remove service flow 1 gate id $sf1_gate_id\n" ;
    #pcmm_open($global_debug);
    pcmm_open(0);
    if (($connected==1) && ($sf1_gate_id != 0)) {
    $cops_client->set_command("delete");
    $cops_client->set_gate_id($sf1_gate_id);
    $cops_client->subscriber_set("ipv4",$subscriber);
    $cops_client->check_data_available();
    $sf1_gate_id = 0; 
    } else {
        print "Error not connected to the PCMM server or invalid GateID\n" ;
    }
}

sub rem_sf2 { 
    print "Remove service flow 2 gate id $sf2_gate_id\n" ;
    #pcmm_open($global_debug);
    pcmm_open(0);
    if (($connected==1) && ($sf2_gate_id != 0)) {
    $cops_client->set_command("delete");
    $cops_client->set_gate_id($sf2_gate_id);
    $cops_client->subscriber_set("ipv4",$subscriber);
    $cops_client->check_data_available();
    $sf2_gate_id = 0; 
    } else {
        print "Error not connected to the PCMM server or invalid GateID\n" ;
    }
}

sub toggle_classifier {
    use feature qw(switch);
    $toggle = 3 - $toggle;
    print "Toggle service flow service classifier to ", $toggle ;
    print "\n";
    if ($sf2_gate_id == 0) {
	add_be2; 
    }
    given($toggle) {
       when(1) { 
	  mod_be2(0); 
          mod_be1(1); 
       }
       when(2) { 
	  mod_be1(0); 
          mod_be2(1); 
       }
       default { print 'Invalid Toggle' }
    }
}

sub toggle_classifier2 {
    use feature qw(switch);
    $toggle = 3 - $toggle;
    print "Toggle service flow service classifier to ", $toggle ;
    print "\n";
    given($toggle) {
       when(1) { 
	  rem_sf2; 
	  add_be1; 
       }
       when(2) { 
	  rem_sf1; 
	  $be2_sourceport = 8081;
	  add_be2; 
	  $be2_sourceport = 1369;
       }
       default { print 'Invalid Toggle' }
    }
}

sub debug_mod_be1 {
    if ($sf1_gate_id == 0) {
	$be1_sourceport = 8081;
	add_be1; 
    }
    $be1_class_priority = 32;
    mod_be1(1); 
    $be1_class_priority = 64;
}

sub toggle_classifier3 {
    use feature qw(switch);
    $toggle = 3 - $toggle;
    print "Toggle service flow service classifier to ", $toggle ;
    print "\n";
    if ($sf2_gate_id == 0) {
        $be2_sourceport = 8081;
	add_be2; 
        $be2_sourceport = 1369;
    }
    given($toggle) {
       when(1) { 
	  # Range 64-128
          #$be2_class_priority = 32;
          $be2_class_priority = 65;
       }
       when(2) { 
    	  $be2_class_priority = 128;
       }
       default { print 'Invalid Toggle' }
    }
    mod_be2(1); 
}


sub quit { 
   print "QUIT!\n" ;
   #print_stuff;
   rem_sf1;
   #print_stuff;
   rem_sf2;
   pcmm_close;
   exit;
}

sub menu {
    my $m = shift;
    my $choice;
    while (1) {
        print "$m->[0]:\n";
        print map { "\t$_. $m->[$_][0]\n" } (1..$#$m);
        print "> ";
        chomp ($choice = <>);
        last if ( ($choice > 0) && ($choice <= $#$m ));
        print "You chose '$choice'.  That is not a valid option.\n\n";
    }
    &{$m->[$choice][1]};
}





use base qw(JSON::RPC::Procedure);  # for Public and Private attributes

sub api_add_sf1 : Public() {
    my ($s, $obj) = @_;
    return ;
}


#print "JSON::RPC::Server::Daemon->new\n";
$server = JSON::RPC::Server::Daemon->new(LocalPort => 9999);
#print "server->dispatch\n";
$server -> dispatch({'/test' => 'myApp'});
#print "server->handle\n";
#$server -> handle();
#print "pcmm_open\n";
pcmm_open;

while (1) {
   menu($menu1);
   # need to check some where else
   #$cops_client->check_data_available();
}
