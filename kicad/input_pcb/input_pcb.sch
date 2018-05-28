EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Conn_01x02 J1
U 1 1 5A1A8FDC
P 4000 2850
F 0 "J1" H 4000 2950 50  0000 C CNN
F 1 "Conn_01x02" H 4000 2650 50  0000 C CNN
F 2 "Connectors:SMA_THT_Jack_Straight" H 4000 2850 50  0001 C CNN
F 3 "" H 4000 2850 50  0001 C CNN
F 4 "2779836" H 4000 3050 50  0001 C CNN "order_code"
F 5 "Farnell" H 4000 3050 50  0001 C CNN "supplier"
	1    4000 2850
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR1
U 1 1 5A1A98CE
P 4350 3000
F 0 "#PWR1" H 4350 2750 50  0001 C CNN
F 1 "GND" H 4350 2850 50  0000 C CNN
F 2 "" H 4350 3000 50  0001 C CNN
F 3 "" H 4350 3000 50  0001 C CNN
	1    4350 3000
	1    0    0    -1  
$EndComp
$Comp
L POT RV1
U 1 1 5A1B4C1C
P 6400 3200
F 0 "RV1" V 6225 3200 50  0000 C CNN
F 1 "4k7" V 6300 3200 50  0000 C CNN
F 2 "Potentiometers:Potentiometer_Trimmer_ACP_CA9v_Horizontal_Px10.0mm_Py5.0mm" H 6400 3200 50  0001 C CNN
F 3 "" H 6400 3200 50  0001 C CNN
F 4 "1227538" H 6225 3300 50  0001 C CNN "order_code"
F 5 "Farnell" H 6225 3300 50  0001 C CNN "supplier"
	1    6400 3200
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5A1B4CE3
P 5300 2850
F 0 "C1" H 5325 2950 50  0000 L CNN
F 1 "2.2n" H 5325 2750 50  0000 L CNN
F 2 "Capacitors_SMD:C_0603_HandSoldering" H 5338 2700 50  0001 C CNN
F 3 "" H 5300 2850 50  0001 C CNN
F 4 "Farnell" H 5325 3050 50  0001 C CNN "supplier"
	1    5300 2850
	0    1    1    0   
$EndComp
$Comp
L R R2
U 1 1 5A1B5444
P 5700 3200
F 0 "R2" V 5780 3200 50  0000 C CNN
F 1 "68" V 5700 3200 50  0000 C CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" V 5630 3200 50  0001 C CNN
F 3 "" H 5700 3200 50  0001 C CNN
F 4 "Farnell" H 5780 3300 50  0001 C CNN "supplier"
F 5 "1738673" V 5700 3200 60  0001 C CNN "order_code"
	1    5700 3200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR2
U 1 1 5A1B55ED
P 5700 3400
F 0 "#PWR2" H 5700 3150 50  0001 C CNN
F 1 "GND" H 5700 3250 50  0000 C CNN
F 2 "" H 5700 3400 50  0001 C CNN
F 3 "" H 5700 3400 50  0001 C CNN
	1    5700 3400
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x02 J3
U 1 1 5A1B63EA
P 7350 3200
F 0 "J3" H 7350 3300 50  0000 C CNN
F 1 "Conn_01x02" H 7350 3000 50  0000 C CNN
F 2 "Connectors:SMA_THT_Jack_Straight" H 7350 3200 50  0001 C CNN
F 3 "" H 7350 3200 50  0001 C CNN
F 4 "2779836" H 7350 3400 50  0001 C CNN "order_code"
F 5 "Farnell" H 7350 3400 50  0001 C CNN "supplier"
	1    7350 3200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR6
U 1 1 5A1BA9C5
P 7050 3350
F 0 "#PWR6" H 7050 3100 50  0001 C CNN
F 1 "GND" H 7050 3200 50  0000 C CNN
F 2 "" H 7050 3350 50  0001 C CNN
F 3 "" H 7050 3350 50  0001 C CNN
	1    7050 3350
	1    0    0    -1  
$EndComp
Wire Wire Line
	4200 2950 4350 2950
Wire Wire Line
	4350 2950 4350 3000
Wire Wire Line
	5700 3350 5700 3400
Wire Wire Line
	7050 3350 7050 3300
Wire Wire Line
	7050 3300 7150 3300
Wire Wire Line
	5700 3050 5700 2850
Connection ~ 5700 2850
$Comp
L Conn_01x02 J2
U 1 1 5A7A25DE
P 7350 2050
F 0 "J2" H 7350 2150 50  0000 C CNN
F 1 "Conn_01x02" H 7350 1850 50  0000 C CNN
F 2 "Connectors:SMA_THT_Jack_Straight" H 7350 2050 50  0001 C CNN
F 3 "" H 7350 2050 50  0001 C CNN
F 4 "2779836" H 7350 2250 50  0001 C CNN "order_code"
F 5 "Farnell" H 7350 2250 50  0001 C CNN "supplier"
	1    7350 2050
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR5
U 1 1 5A7A25E4
P 7050 2200
F 0 "#PWR5" H 7050 1950 50  0001 C CNN
F 1 "GND" H 7050 2050 50  0000 C CNN
F 2 "" H 7050 2200 50  0001 C CNN
F 3 "" H 7050 2200 50  0001 C CNN
	1    7050 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	7050 2200 7050 2150
Wire Wire Line
	7050 2150 7150 2150
Wire Wire Line
	5450 2850 5700 2850
Wire Wire Line
	5700 2850 6400 2850
Wire Wire Line
	6400 2850 6400 3050
Wire Wire Line
	4200 2850 4400 2850
Wire Wire Line
	4400 2850 5150 2850
$Comp
L GND #PWR3
U 1 1 5A7A2706
P 6400 3400
F 0 "#PWR3" H 6400 3150 50  0001 C CNN
F 1 "GND" H 6400 3250 50  0000 C CNN
F 2 "" H 6400 3400 50  0001 C CNN
F 3 "" H 6400 3400 50  0001 C CNN
	1    6400 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	6400 3350 6400 3400
Wire Wire Line
	6550 3200 7150 3200
$Comp
L D D1
U 1 1 5A7A2983
P 4800 2050
F 0 "D1" H 4800 2150 50  0000 C CNN
F 1 "D" H 4800 1950 50  0000 C CNN
F 2 "" H 4800 2050 50  0001 C CNN
F 3 "" H 4800 2050 50  0001 C CNN
	1    4800 2050
	-1   0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 5A7A2A58
P 5300 2050
F 0 "R1" V 5380 2050 50  0000 C CNN
F 1 "10" V 5300 2050 50  0000 C CNN
F 2 "" V 5230 2050 50  0001 C CNN
F 3 "" H 5300 2050 50  0001 C CNN
	1    5300 2050
	0    1    1    0   
$EndComp
$Comp
L L L1
U 1 1 5A7A2ABB
P 5800 2050
F 0 "L1" V 5750 2050 50  0000 C CNN
F 1 "1m" V 5875 2050 50  0000 C CNN
F 2 "" H 5800 2050 50  0001 C CNN
F 3 "" H 5800 2050 50  0001 C CNN
F 4 "Farnell" V 5800 2050 60  0001 C CNN "supplier"
F 5 "2457854" V 5800 2050 60  0001 C CNN "order_code"
	1    5800 2050
	0    -1   -1   0   
$EndComp
$Comp
L C C2
U 1 1 5A7A2B56
P 6250 2250
F 0 "C2" H 6275 2350 50  0000 L CNN
F 1 "10m" H 6275 2150 50  0000 L CNN
F 2 "" H 6288 2100 50  0001 C CNN
F 3 "" H 6250 2250 50  0001 C CNN
	1    6250 2250
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 5A7A2BA3
P 6650 2250
F 0 "R3" V 6730 2250 50  0000 C CNN
F 1 "68" V 6650 2250 50  0000 C CNN
F 2 "Resistors_SMD:R_0603_HandSoldering" V 6580 2250 50  0001 C CNN
F 3 "" H 6650 2250 50  0001 C CNN
F 4 "2059570" H 6730 2350 50  0001 C CNN "order_code"
F 5 "Farnell" H 6730 2350 50  0001 C CNN "supplier"
	1    6650 2250
	1    0    0    -1  
$EndComp
Wire Wire Line
	4650 2050 4400 2050
Wire Wire Line
	4400 2050 4400 2850
Connection ~ 4400 2850
Wire Wire Line
	4950 2050 5150 2050
Wire Wire Line
	5450 2050 5650 2050
Wire Wire Line
	5950 2050 6250 2050
Wire Wire Line
	6250 2050 6650 2050
Wire Wire Line
	6650 2050 7150 2050
Wire Wire Line
	6250 2050 6250 2100
Wire Wire Line
	6650 2050 6650 2100
Connection ~ 6250 2050
Wire Wire Line
	6250 2400 6250 2450
Wire Wire Line
	6250 2450 6450 2450
Wire Wire Line
	6450 2450 6650 2450
Wire Wire Line
	6650 2450 6650 2400
$Comp
L GND #PWR4
U 1 1 5A7A2DDB
P 6450 2500
F 0 "#PWR4" H 6450 2250 50  0001 C CNN
F 1 "GND" H 6450 2350 50  0000 C CNN
F 2 "" H 6450 2500 50  0001 C CNN
F 3 "" H 6450 2500 50  0001 C CNN
	1    6450 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6450 2500 6450 2450
Connection ~ 6450 2450
Connection ~ 6650 2050
Text Notes 5150 1850 0    60   ~ 0
Power Rectification
Text Notes 5100 2650 0    60   ~ 0
Pulse Filtering
$EndSCHEMATC
