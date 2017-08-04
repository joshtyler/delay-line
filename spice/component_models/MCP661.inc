*THIS MODEL DOES NOT APPEAR TO WORK WITH LTSPICE
.SUBCKT MCP661 1 2 3 4 5
*              | | | | |
*              | | | | Output
*              | | | Negative Supply
*              | | Positive Supply
*              | Inverting Input
*              Non-inverting Input
*
********************************************************************************
* Software License Agreement                                                   *
*                                                                              *
* The software supplied herewith by Microchip Technology Incorporated (the     *
* 'Company') is intended and supplied to you, the Company's customer, for use  *
* soley and exclusively on Microchip products.                                 *
*                                                                              *
* The software is owned by the Company and/or its supplier, and is protected   *
* under applicable copyright laws. All rights are reserved. Any use in         *
* violation of the foregoing restrictions may subject the user to criminal     *
* sanctions under applicable laws, as well as to civil liability for the       *
* breach of the terms and conditions of this license.                          *
*                                                                              *
* THIS SOFTWARE IS PROVIDED IN AN 'AS IS' CONDITION. NO WARRANTIES, WHETHER    *
* EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED        *
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO  *
* THIS SOFTWARE. THE COMPANY SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR    *
* SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.     *
********************************************************************************
*
* The following op-amps are covered by this model:
*      MCP660, MCP661, MCP662, MCP663, MCP664, MCP665, MCP669
*
* Revision History:
*      REV A: 9-Mar-10, Created model
*      REV B: 01-Nov-11, Fixed Vout swing issue
*      REV C: 09-Jul-12, Added MCP660, MCP664, MCP669 
*
* Recommendations:
*      Use PSPICE (or SPICE 2G6; other simulators may require translation)
*      For a quick, effective design, use a combination of: data sheet
*            specs, bench testing, and simulations with this macromodel
*      For high impedance circuits, set GMIN=100F in the .OPTIONS statement
*
* Supported:
*      Typical performance for temperature range (-40 to 125) degrees Celsius
*      DC, AC, Transient, and Noise analyses.
*      Most specs, including: offsets, DC PSRR, DC CMRR, input impedance,
*            open loop gain, voltage ranges, supply current, ... , etc.
*      Temperature effects for Ibias, Iquiescent, Iout short circuit 
*            current, Vsat on both rails, Slew Rate vs. Temp and P.S.
*
* Not Supported:
*      Some Variation in specs vs. Power Supply Voltage
*      Vos distribution, Ib distribution for Monte Carlo
*      Distortion (detailed non-linear behavior)
*      Some Temperature analysis
*      Process variation
*      Behavior outside normal operating region
*
* Input Stage
V10  3 10 1.1
R10 10 11 20.0K
R11 10 12 20.0K
G10 10 11 10 11 5.00M
G11 10 12 10 12 5.00M
C11 11 12 2P
C12  1  0 9P
E12 71 14 POLY(4) 20 0 21 0 26 0 27 0 1.8M 47 47 1 1
G12 1 0 62 0 1m
G13 1 2 63 0 1u
M12 11 14 15 15 NMI 
M14 12 2 15 15 NMI 
G14 2 0 62 0 1m
C14  2  0 9P
I15 15 4 25M
V16 16 4 -300M
GD16 16 1 TABLE {V(16,1)} ((-100,-1p)(0,0)(1m,1u)(2m,1m)(3m,10)) 
V13 3 13 1.3
GD13 2 13 TABLE {V(2,13)} ((-100,-1p)(0,0)(1m,1u)(2m,1m)(3m,10)) 
R71  1  0 12E12
R72  2  0 12E12
R73  1  2 20E12
*
* Noise, PSRR, and CMRR
I20 21 20 423U
D20 20  0 DN1
D21  0 21 DN1
C20 20 22 3u
C21 21 23 3u
R22 22 0 .62
R23 23 0 .62
C221 22 0 140n
C231 23 0 140n
C22 22 24 .7u
C23 23 25 .7u
R24 24 0 3
R25 25 0 3
C24 24 241 .1u
C25 25 251 .1u
R241 241 0 10
R251 251 0 10
C241 241 0 .45u
C251 251 0 .45u
G26  0 26 POLY(2) 3 0 4 0   0.00 -104U -158U
R26 26  0 1
G27  0 27 POLY(2) 1 0 2 0  -403U -20U -20U
R27 27  0 1
*
* Open Loop Gain, Slew Rate
G30  0 30 12 11 1
R30 30  0 1.00K
G31 0 31 3 4 3
I31 0 31 DC 40
R31 31  0 1 TC=2.78M,-2.35U
GD31 30 0 TABLE {V(30,31)} ((-100,-1n)(0,0)(1m,0.1)(2m,50))
CD31 31 30 2p
G32 32 0 3 4 10
I32 32 0 DC 37
R32 32  0 1 TC=1.58M,-2.00U
GD32 0 30 TABLE {V(30,32)} ((-2m,50)(-1m,0.1)(0,0)(100,-1n))
CD32 32 30 2p
G33  0 33 30 0 1m
R33  33 0 1K
G34  0 34 33 0 2.5
R34  34 0 1K
C34  34 0 5.3U
G37  0 37 34 0 1m
R37  37 0 1K
C37  371 0 2P
L37  37 371 200N
G38  0 38 37 0 1m
R38  39 0 1K
L38  38 39 2U
E38  35 0 38 0 1
* Changed G35 and G36 to fix output offset - AR / 01-Nov-11
*G35 33 0 TABLE {V(35,3)} ((-1,-1n)(0,0)(900M,1n))(990M,1)(1,50))
*G36 33 0 TABLE {V(35,4)} ((-1,-50)(-990M,-1)((-900M,-1n)(0,0)(1,1n))
G35 33 0 TABLE {V(35,3)} ((-1,-1n)(0,0)(2.75,1n))(2.80,1))
G36 33 0 TABLE {V(35,4)} ((-2.80,-1)((-2.75,-1n)(0,0)(1,1n))

*
* Output Stage
R80 50 0 100MEG
G50 0 50 57 96 2
R58 57  96 0.50
R57 57  0 9.00
C58  5  0 2.00P
G57  0 57 POLY(5) 1 0 2 0 3 0 4 0 35 0 0 4M 4M 48M 30M 111M
GD55 55 57 TABLE {V(55,57)} ((-3m,-100)(-2m,-1)(-1m,-1m)(0,0)(10,1n))
GD56 57 56 TABLE {V(57,56)} ((-3m,-100)(-2m,-1)(-1m,-1m)(0,0)(10,1n))
E55 55  0 POLY(2) 3 0 51 0 -4.4M 1 -7.5M
E56 56  0 POLY(2) 4 0 52 0 3M 1 -8.0M
R51 51 0 1k
R52 52 0 1k
GD51 50 51 TABLE {V(50,51)} ((-10,-1n)(0,0)(1m,1m)(2m,1)(3m,100))
CD51 51 0 2p
GD52 50 52 TABLE {V(50,52)}  ((-3m,-100)(-2m,-1)(-1m,-1m)(0,0)(10,1n))
CD52 52 0 2p
G53  3  0 POLY(1) 51 0  -25.0M 1M
G54  0  4 POLY(1) 52 0  -25.0M -1M
*
* Current Limit
G99 96 5 99 0 1
R98 0 98 1
G97 0 98 TABLE { V(96,5) } ((-11.0,-97.0M)(-1.00M,-96.0M)(0,0)(1.00M,96.0M)(11.0,97.0M))
E97 99 0 VALUE { V(98)*((V(3)-V(4))*-95.4M + 1.26)}
D98 4 5 DESD
D99 5 3 DESD
*
* Temperature / Voltage Sensitive IQuiscent
R61 0 61 1 TC=3.01M,2.40U
G61 3 4 61 0 1
G60 0 61 TABLE {V(3, 4)} 
+ ((0,0)(1.1,55.0U)(1.45,800U)(1.6,3.6M)
+ (2.7,5.00M)(4.00,5.5M)(6.5,6.1M))
*
* Temperature Sensitive offset voltage
I73 0 70 DC 1uA
R74 0 70 1 TC=2.00
E75 1 71 70 0 1 
*
* Temp Sensistive IBias
I62 0 62 DC 1uA
R62 0 62 REXP  1.73733M
*
* Temp Sensistive Offset IBias
I63 0 63 DC 1uA
R63 0 63 2.00 TC=-15M,0.35M
*
* Models
.MODEL NMI NMOS(L=2.00U W=100U KP=20.0U LEVEL=1 )
.MODEL DESD  D   N=1 IS=1.00E-15
.MODEL DN1 D   IS=1P KF=146E-18 AF=1
.MODEL REXP  RES TCE= 6.3264
.ENDS MCP661
