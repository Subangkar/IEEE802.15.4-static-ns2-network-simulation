# $nNodes $nFlows $pcktRate $speed
# ======================================
# Variables
# ======================================
set num_node           [lindex $argv 0]
set num_flow			[lindex $argv 1]
set cbr_pckt_rate     [lindex $argv 2]
set node_speed		  5;#[lindex $argv 3]
# set Tx_multiple 	    [lindex $argv 3]
set Tx_range 	    	[lindex $argv 3]
set cbr_interval		[expr 1.0/$cbr_pckt_rate]
# http://prog3.com/sbdm/blog/ysynhtt/article/details/37922773
# puts "Simulating With: #Nodes=$num_node #Flow=$num_flow PKT_rate=$cbr_pckt_rate #TX_Range=$Tx_range"
# ======================================


# ==============================================================================
# Network Parameters
# ==============================================================================
set cbr_size            64 ;	#[lindex $argv 2]; #4,8,16,32,64
set cbr_rate            11.0Mb
set grid_x_dim		[expr $Tx_range]
# 500 ;	#[lindex $argv 1]
set grid_y_dim  	[expr $Tx_range]
#500 ;	#[lindex $argv 1]
set time_duration    15 ;	#[lindex $argv 5] ;#50
set start_time          1
set extra_time          5
set flow_start_gap   0.0
puts "Simulating With: #Nodes=$num_node #Flow=$num_flow PKT_rate=$cbr_pckt_rate #TX_Area=$grid_x_dim x $grid_y_dim"
# set motion_start_gap    0.05



set source_type			Agent/UDP
set sink_type			Agent/Null

# =====================
# source / sink options
# =====================
# UDP:		Agent/UDP					Agent/Null
# TAHOE:	Agent/TCP					Agent/TCPSink
# RENO:		Agent/TCP/Reno				Agent/TCPSink
# NEWRENO:	Agent/TCP/Newreno			Agent/TCPSink
# SACK: 	Agent/TCP/FullTcp/Sack		Agent/TCPSink/Sack1
# VEGAS:	Agent/TCP/Vegas				Agent/TCPSink
# FACK:		Agent/TCP/Fack				Agent/TCPSink
# LINUX:	Agent/TCP/Linux				Agent/TCPSink

# ==============================================================================



# ==============================================================================
# Files
# ==============================================================================
set trace_file_name		TRACE.tr
set nam_file_name		NAM.nam
set topo_file_name		TOPO.topo
set directory			""
# ==============================================================================




# ==============================================================================
# Define options
# ==============================================================================
set val(chan)		Channel/WirelessChannel  	;# channel type
set val(prop)		Propagation/TwoRayGround 	;# radio-propagation model
set val(ant)		Antenna/OmniAntenna      	;# Antenna type
set val(ll)			LL                       	;# Link layer type
set val(ifq)		Queue/DropTail/PriQueue  	;# Interface queue type
set val(ifqlen)		100                       	;# max packet in ifq
set val(netif)		Phy/WirelessPhy/802_15_4    ;# network interface type
set val(mac)		Mac/802_15_4 			 	;# MAC type wireless 802.15.4
set val(rp)			DSDV                     	;# ad-hoc routing protocol
set val(nn)			$num_node                	;# number of mobilenodes
# ==============================================================================



# ==============================================================================
# Energy Parameters
# ==============================================================================
set val(energymodel)	EnergyModel;
set val(initialenergy)	100;
# ==============================================================================






# ======================================================================
# Initialization
# ======================================================================

# creating an instance of the simulator
set ns_    [new Simulator]

# setup trace support by opening the trace file
set tracefd     [open $directory$trace_file_name w]
$ns_ trace-all $tracefd

# setum nam (Network Animator) support by opening the nam file
# set namtrace    [open $directory$nam_file_name w]
# $ns_ namtrace-all-wireless $namtrace $grid_x_dim $grid_y_dim


# create a topology object that keeps track of movements...
# ...of mobilenodes within the topological boundary.
set topo_file   [open $directory$topo_file_name "w"]




# Mac/802_15_4 set syncFlag_ 1
# Mac/802_15_4 set dataRate_ 11Mb
# Mac/802_15_4 set dutyCycle_ cbr_interval



# ========================================
# EXCLUSIVE ENERGY PARAMETERS FOR 802.15.4
# ========================================
set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
Phy/WirelessPhy set CSThresh_ $dist(40m)
Phy/WirelessPhy set RXThresh_ $dist(40m)
# Phy/WirelessPhy set TXThresh_ $dist(40m)
# Phy/WirelessPhy/802_15_4 set CSThresh_ $dist(40m)
# Phy/WirelessPhy/802_15_4 set RXThresh_ $dist(40m)
# Phy/WirelessPhy/802_15_4 set TXThresh_ $dist(40m)
# ========================================


set topo	[new Topography]
$topo load_flatgrid $grid_x_dim $grid_y_dim
# Grid resolution can be passed to load_flatgrid as a 3rd parameter.
# Default is 1.

# create the object God
create-god $val(nn)

# GOD (General Operations Director) is the object that is used to...
# ...store global information about the state of the environment, network...
# ...or nodes that an omniscent observer would have, but that should...
# ...not be made known to any participant in the simulation.
# Currently, God object stores the total number of mobilenodes...
# ...and a table of shortest number of hops required to reach from...
# ...one node to another. The next hop information is normally loaded...
# ...into god object from movement pattern files, before simulation...
# ...begins, since calculating this on the fly during simulation runs...
# ...can be quite time consuming.
# ...However, in order to keep this example simple we avoid using movement...
# ...pattern files and thus do not provide God with next hop information.

# ======================================================================



# ==============================================================================
# The configuration API for creating mobilenodes
# ==============================================================================
$ns_ node-config	-adhocRouting $val(rp) \
					-llType $val(ll) \
	     			-macType $val(mac)  \
					-ifqType $val(ifq) \
	     			-ifqLen $val(ifqlen) \
					-antType $val(ant) \
	     			-propType $val(prop) \
					-phyType $val(netif) \
	     			-channel  [new $val(chan)] \
					-topoInstance $topo \
	     			-agentTrace ON \
					-routerTrace OFF\
	     			-macTrace ON \
	     			-movementTrace OFF \
             		-energyModel $val(energymodel) \
             		-initialEnergy $val(initialenergy) \
             		-rxPower 35.28e-3 \
             		-txPower 31.32e-3 \
	     			-idlePower 712e-6 \
	     			-sleepPower 144e-9
# ==============================================================================




# ==============================================================================
# Create Nodes and Set Initial Positions
# ==============================================================================
puts "start node creation"

for {set i 0} {$i < $num_node} {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0

	# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
	set x_pos [expr int($grid_x_dim*rand())] ; #random settings
	set y_pos [expr int($grid_y_dim*rand())] ; #random settings

	while {$x_pos == 0 ||
			$x_pos == $grid_x_dim} {
		set x_pos [expr int($grid_x_dim*rand())]
	}

	while {$y_pos == 0 ||
			$y_pos == $grid_y_dim} {
		set y_pos [expr int($grid_y_dim*rand())]
	}

	$node_($i) set X_ $x_pos;
	$node_($i) set Y_ $y_pos;
	$node_($i) set Z_ 0.0

	puts -nonewline $topo_file "$i x: [$node_($i) set X_] y: [$node_($i) set Y_] \n"
}

for {set i 0} {$i < $val(nn)} { incr i } {
	$ns_ initial_node_pos $node_($i) 35
    #35 = size of node in nam
}





# =====================
# random node movements
# =====================
for {set i 0} {$i < [expr $num_node] } {incr i} {
	set dest_x [expr int($grid_x_dim*rand())]
	set dest_y [expr int($grid_y_dim*rand())]

	while {$dest_x == 0 ||
			$dest_x == $grid_x_dim} {
		set dest_x [expr int($grid_x_dim*rand())]
	}

	while {$dest_y == 0 ||
			$dest_y == $grid_y_dim} {
		set dest_y [expr int($grid_y_dim*rand())]
	}
	$ns_ at $start_time "$node_($i) setdest $dest_x $dest_y  $node_speed"

	#puts "$i Destination ---> x: [$node_($i) set X_] y: [$node_($i) set Y_]"
}

puts "node creation complete"
# ==============================================================================




# ==============================================================================
# Setup Traffic Flows
# ==============================================================================
for {set i 0} {$i < $num_flow} {incr i} {
	set udp_($i) [new $source_type]
	set null_($i) [new $sink_type]
	$udp_($i) set fid_ $i
	$ns_ color $i Blue
	if { [expr $i%2] == 0} {
		$ns_ color $i Blue
	} else {
		$ns_ color $i Red
	}
}


for {set i 0} {$i < $num_flow} {incr i} {
	set source_number [expr int($num_node*rand())]
	set sink_number [expr int($num_node*rand())]
	while {$sink_number==$source_number} {
		set sink_number [expr int($num_node*rand())]
	}
	$ns_ attach-agent $node_($source_number) $udp_($i)
  	$ns_ attach-agent $node_($sink_number) $null_($i)
	puts -nonewline $topo_file "RANDOM:  Src: $source_number Dest: $sink_number\n"
}


for {set i 0} {$i < $num_flow } {incr i} {
	set cbr_($i) [new Application/Traffic/CBR]
	$cbr_($i) set packetSize_ $cbr_size
	$cbr_($i) set rate_ $cbr_rate
	$cbr_($i) set interval_ $cbr_interval
	$cbr_($i) attach-agent $udp_($i)
	$ns_ at $start_time "$cbr_($i) start"
}

# Connecting udp_node & null_node
for {set i 0} {$i < $num_flow } {incr i} {
     $ns_ connect $udp_($i) $null_($i)
}

puts "flow creation complete"
# ==============================================================================


# ==============================================================================
# Ending the simulation
# ==============================================================================

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at [expr $start_time+$time_duration] "$node_($i) reset";
}

$ns_ at [expr $start_time+$time_duration +$extra_time] "finish"
$ns_ at [expr $start_time+$time_duration +$extra_time] "$ns_ nam-end-wireless [$ns_ now]; puts \"NS Exiting...\"; $ns_ halt"


proc finish {} {
    puts "finishing"
    global ns_ tracefd namtrace topo_file nam_file_name
    $ns_ flush-trace
    close $tracefd
	close $topo_file
    # close $namtrace
    # exec nam $nam_file_name &
    exit 0
}

puts "Starting Simulation..."
$ns_ run
