*//////////////////////////////////////////////////////////////////////
* (C) National Semiconductor, Corporation.
* Models developed and under copyright by:
* National Semiconductor, Corporation.  
*/////////////////////////////////////////////////////////////////////
* Legal Notice:  
* The model may be copied, and distributed without any modifications;
* however, reselling or licensing the material is illegal.
* We reserve the right to make changes to the model without prior notice. 
* Pspice Models are provided "AS IS, WITH NO WARRANTY OF ANY KIND" 
*////////////////////////////////////////////////////////////////////
* For more information, and our latest models,
* please visit the models section of our website at
*       http://www.national.com/models/
*////////////////////////////////////////////////////////////////////
* SPICE MODEL LMH6639
* BEGIN MODEL
.SUBCKT LMH6639 3 2 7 4 6 8
* PINOUT ORDER +IN -IN +V -V OUT NSD
* PINOUT NOS    3   2   7  4  6   8
R3 14 15 850
R4 11 15 850
R5 32 33 20
R8 34 9 1E3
R9 34 12 1E3
R10 29 35 100
R11 36 24 100
R12 25 7 2.5
R13 4 31 2.5
G1 18 30 37 38 -2E-3
R15 39 10 20
R16 37 40 22
C2 40 6 1.3E-12
R17 19 23 2.5
R18 30 28 2.5
D1 13 22 DD
D2 10 22 DD
D3 30 13 DD
D4 30 10 DD
D5 6 7 DD
D6 4 6 DD
V6 33 13 1E-3
D7 41 0 DIN
D8 42 0 DIN
I8 0 41 0.1E-3
I9 0 42 0.1E-3
E2 30 0 4 0 1
E3 22 0 7 0 1
C4 32 0 1.3E-12
C5 2 0 1.3E-12
D9 43 0 DVN
D10 44 0 DVN
I10 0 43 0.1E-3
I11 0 44 0.1E-3
E4 39 2 43 44 1.2
G2 32 39 41 42 5.5E-5
I12 7 4 0.1E-3
R22 4 7 15E3
E5 45 0 22 0 1
E6 46 0 30 0 1
E7 47 0 48 0 1
R30 45 49 1E6
R31 46 50 1E6
R32 47 51 1E6
R33 0 49 100
R34 0 50 100
R35 0 51 100
E10 52 3 51 0 -0.25
R36 53 48 1E3
R37 48 54 1E3
C6 45 49 1E-12
C7 46 50 3E-12
C8 47 51 10E-12
E11 55 52 50 0 2.4
E12 32 55 49 0 2.4
G4 37 38 9 12 1.5E-3
R40 37 38 500E3
E14 38 0 22 30 0.005
D11 37 22 DD
D12 30 37 DD
C10 9 12 0.8E-12
G5 22 20 56 0 2E-3
G6 22 26 56 0 1E-3
G7 19 30 56 0 1E-3
G8 18 30 56 0 2E-3
G9 17 16 56 0 -1.5E-6
E18 59 37 56 0 2
E19 60 38 56 0 -2
V14 58 60 1
V15 57 59 -1
R54 59 0 1E9
R55 60 0 1E9
Q23 61 62 63 QP
V16 22 63 0.4
R56 8 62 120E3
R57 0 61 1E3
V17 64 0 1
R58 56 64 1E3
C11 22 62 3E-12
V18 22 17 0.454
D13 34 65 DD
V19 65 30 -0.3
G10 7 4 56 0 2.2E-3
R60 66 7 10E3
E21 67 4 56 0 1
C12 32 2 0.25E-12
G11 15 13 56 0 1.18E-6
G12 15 10 56 0 1.16E-6
E22 53 0 39 0 1
E23 54 0 32 0 1
R61 55 32 1E9
R62 52 55 1E9
R63 3 52 1E9
R64 2 39 1E9
R65 4 67 1E9
E24 35 30 31 30 2
E25 36 22 25 22 2
R66 8 22 1E9
Q5 9 10 11 QIP
Q6 12 13 14 QIP
Q7 15 16 17 QP
Q12 18 19 20 QP
Q13 21 21 22 QP
Q14 23 23 21 QP
Q15 20 24 22 QP
Q17 6 20 25 QOP
Q18 26 26 27 QN
Q19 27 27 28 QN
Q20 18 29 30 QN
Q21 6 18 31 QON
Q22 20 26 18 QN
M10 38 57 37 37 PSW L=1.5U W=150U
M11 37 58 38 38 NSW L=1.5U W=150U
M12 56 61 0 0 NEN L=1.5U W=1500U
M13 66 67 4 4 NSW L=1.5U W=15U
.MODEL DD D
.MODEL QP PNP
.MODEL QN NPN
.MODEL QON NPN VAF=40
.MODEL QOP PNP VAF=40
.MODEL QIP PNP KF=1.25E-15 BF=333
.MODEL DVN D KF=3.2E-13
.MODEL DIN D KF=3.2E-13
.MODEL PSW PMOS KP=200U VTO=-0.5 IS=1E-18
.MODEL NSW NMOS KP=200U VTO=0.5 IS=1E-18
.MODEL NEN NMOS KP=20M VTO=0.5 IS=1E-18
.ENDS
