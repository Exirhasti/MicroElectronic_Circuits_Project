
*************CMOS Inverter HSPICE netlist************ 
.include 'C:\Users\exirh\Desktop\project\mosistsmc180.lib'
*netlist--------------------------------------- 
.param SUPPLY=5.0
.param WN=0.36u
.param WP=0.72u
.param LSD=0.18u


*VDD Vdd 0 5.0
VDD Vdd 0 'SUPPLY'
VA0 A0 gnd PULSE 'SUPPLY' 0 0ps 100PS 100PS 10NS 20NS 	*input line: square wave, amp. rise t, fall t, on t, period 
VB0 B0 gnd PULSE 'SUPPLY' 0 0ps 100ps 100ps 20ns 40ns



*******************
*EXAMPLE FOR PART B
*******************
*VA0 A0 gnd PULSE  'SUPPLY' 0 5ns 100ps 100ps 5ns 20ns
*VB0 B0 gnd DC 'SUPPLY'



**********
*INVERTER
**********
.subckt inv a Vout Vdd WN=0.36u WP=0.72u

   *Darin Gate Source Bulk Model_Name L=length W=width AS="Area of Source" PS="Perimeter of Source" AD PD
MP1 Vdd a Vout Vdd PMOS L=.18u W='WP' AS='WP*LSD' PS='2*WP+2*LSD' AD='WP*LSD' PD='2*WP+2*LSD'
MN1 Vout a 0 0     NMOS L=.18u W='WN' AS='WN*LSD' PS='2*WN+2*LSD' AD='WN*LSD' PD='2*WN+2*LSD'

.ends


******************
*AND GATE: y = a&b
******************
.subckt AND a b y Vdd WN=0.36u WP=0.72u

MP1 Vdd a Vout Vdd PMOS L=.18u W='WP' AS='WP*LSD' PS='2*WP+2*LSD' AD='WP*LSD' PD='2*WP+2*LSD'
MP2 Vdd b Vout Vdd PMOS L=.18u W='WP' AS='WP*LSD' PS='2*WP+2*LSD' AD='WP*LSD' PD='2*WP+2*LSD'
MN1 N1 a 0 0     NMOS L=.18u W='WN' AS='WN*LSD' PS='2*WN+2*LSD' AD='WN*LSD' PD='2*WN+2*LSD'
MN2 N1 b Vout N1     NMOS L=.18u W='WN' AS='WN*LSD' PS='2*WN+2*LSD' AD='WN*LSD' PD='2*WN+2*LSD'

XINV0 Vout y Vdd inv WN=0.36u WP=0.72u

.ends


*****************************************
*XNOR GATE: y = a xnor b = !(!a&b + a&!b)
*****************************************
.subckt XNOR a b y Vdd WN=0.36u WP=0.72u

*invert A and B
XINV1 a na Vdd inv WN=0.36u WP=0.72u
XINV2 b nb Vdd inv WN=0.36u WP=0.72u

*XNOR PULL-DOWN

*!A&B
XAND1 na b AND1 Vdd AND WN=0.36u WP=0.72u
*A&!B
XAND2 a nb AND2 Vdd AND WN=0.36u WP=0.72u

MN1 y AND1 0 0     NMOS L=.18u W='WN' AS='WN*LSD' PS='2*WN+2*LSD' AD='WN*LSD' PD='2*WN+2*LSD'
MN2 y AND2 0 0     NMOS L=.18u W='WN' AS='WN*LSD' PS='2*WN+2*LSD' AD='WN*LSD' PD='2*WN+2*LSD'

*XNOR PULL-UP
MP1 Vdd a N1 Vdd PMOS L=.18u W='WP' AS='WP*LSD' PS='2*WP+2*LSD' AD='WP*LSD' PD='2*WP+2*LSD'
MP2 Vdd nb N1 Vdd PMOS L=.18u W='WP' AS='WP*LSD' PS='2*WP+2*LSD' AD='WP*LSD' PD='2*WP+2*LSD'
MP3 N1 na y Vdd PMOS L=.18u W='WP' AS='WP*LSD' PS='2*WP+2*LSD' AD='WP*LSD' PD='2*WP+2*LSD'
MP4 N1 b y Vdd PMOS L=.18u W='WP' AS='WP*LSD' PS='2*WP+2*LSD' AD='WP*LSD' PD='2*WP+2*LSD'

.ends



*invert A and B
XINV1 A0 NA0 Vdd inv WN=0.36u WP=0.72u
XINV2 B0 NB0 Vdd inv WN=0.36u WP=0.72u


****************
*LT (A<B) = !A&B
****************
XAND1 NA0 B0 LT Vdd AND WN=0.36u WP=0.72u


****************
*GT (A>B) = A&!B
****************
XAND2 A0 NB0 GT Vdd AND WN=0.36u WP=0.72u


********************
*EQ (A=B) = A XNOR B
********************
XXNOR A0 B0 EQ Vdd XNOR WN=0.36u WP=0.72u


**********
*LOAD CAPS
**********
CL1 LT gnd 10fF
CL2 GT gnd 10fF
CL3 EQ gnd 10fF


*extra control information--------------------- 
.options post=2 nomod 
.op 
*analysis-------------------------------------- 
.TRAN 10ps 120ns * transient analysis: Step end_time 
.PROBE V(A0) V(B0) V(LT) V(GT) V(EQ)



.measure charge INTEGRAL I(CL3) FROM=0ns TO=120ns
.measure energy param='-charge * 5.0'
.measure power param='energy / 120n'


.measure tpdr				* rising propagation delay
+     TRIG v(A0)		VAL='SUPPLY/2' FALL=1 
+     TARG v(EQ)	  	VAL='SUPPLY/2' RISE=1
.measure tpdf				* falling propagation delay
+     TRIG v(A0)  	VAL='SUPPLY/2' RISE=2
+     TARG v(EQ)  	VAL='SUPPLY/2' FALL=2 
.measure tpd param='(tpdr+tpdf)/2'	* average propagation delay

.measure trise					* rise time
+	TRIG v(EQ)	VAL='0.1 * SUPPLY' RISE=1
+	TARG v(EQ)	VAL='0.9 * SUPPLY' RISE=1
.measure tfall					* fall time
+	TRIG v(EQ)	VAL='0.9 * SUPPLY' FALL=2
+	TARG v(EQ)	VAL='0.1 * SUPPLY' FALL=2


.END 