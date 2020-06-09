import os
import random
while (1):
	s = """
[[[ welcome to GUVM user interface ]]]
Compile DUT + Test Bench :  
1- Riscy core (based on RISC-v ISA): enter --> 1 
2- Leon core (based on Sparcv8 ISA): enter --> 2
3- Amber core (based on ARM ISA): enter --> 3
if u want to skip compiling DUT and compile test bench only
Compile Test Bench only :
1- Riscy core (based on RISC-v ISA): enter --> 11 
2- Leon core (based on Sparcv8 ISA): enter --> 22
3- Amber core (based on ARM ISA): enter --> 33
if u want to skip all compiling DUT determine which DUT u want to simulate on
Run Test   :
1- Riscy core (based on RISC-v ISA): enter --> 111
2- Leon core (based on Sparcv8 ISA): enter --> 222
3- Amber core (based on ARM ISA): enter --> 333
any other input will terminate simulation compilation the simulation
DUT: """;
	g = raw_input(s);
	print (g);
	if g == "1":
		os.system("vsim -c -do ../testing_riscy/run_riscy.do")
		x=("vsim -c -do \"vsim -novopt top +UVM_TESTNAME=")
	elif g == "2":
		os.system("vsim -c -do ../testing_leon/run_leon.do")
		x=("vsim -c -do \"vsim -novopt top +UVM_TESTNAME=")
	elif g == "3":
		os.system("vsim -c -do ../testing_amber/run_amber.do")
		x=("vsim -c -do \"vsim  top +UVM_TESTNAME=")
	elif g == "11":
		os.system("vsim -c -do ../testing_riscy/run_tb.do")
		x=("vsim -c -do \"vsim -novopt top +UVM_TESTNAME=")
	elif g == "22":
		os.system("vsim -c -do ../testing_leon/run_tb.do")
		x=("vsim -c -do \"vsim -novopt top +UVM_TESTNAME=")
	elif g == "33":
		os.system("vsim -c -do ../testing_amber/run_tb.do")
		x=("vsim -c -do \"vsim -novopt top +UVM_TESTNAME=")
	elif g == "111":
		x=("vsim -c -do \"vsim -novopt top +UVM_TESTNAME=")
	elif g == "222":
		x=("vsim -c -do \"vsim top +UVM_TESTNAME=")
	elif g == "333":
		x=("vsim -c -do \"vsim -novopt top +UVM_TESTNAME=")
	elif g == "w1":
		os.system("vsim -view vsim.wlf -do ../testing_riscy/wave.do")
		break
	elif g == "w2":
		os.system("vsim -view vsim.wlf -do ../testing_leon/wave.do")
		break
	elif g == "w3":
		os.system("vsim -view vsim.wlf -do ../testing_amber/wave.do")
		break
	else:
		print("please enter a valid number")
		break

	s="""
please choose which test to simulate:
1- add_test (based on RISC-v ISA, Sparcv8 ISA, ARM v2a ISA): enter --> 1 
2- branch with flags bief_test (based on sparcv8 ISA,ARM v2a ISA): enter --> 2  
load --> load --> change flag --> branch --> arithmatic command --> store(2)
3- A_type_test (based on RISC-v ISA, Sparcv8 ISA, ARM v2a ISA): enter --> 3     
load --> load --> command --> store(2)
4- load_double_test (based on sparcv8 ISA): enter --> 4
load --> load --> load(2) --> store(2)
5- arithmatic with and without flag arith_flag_test (based on RISC-v ISA, Sparcv8 ISA) -->5
load --> load --> change flag --> command --> check flag --> store 
6- store_test (based on RISC-v ISA, Sparcv8 ISA,ARM v2a ISA) -->6
load --> load --> store(2)
7- mul_test (based on RISC-v ISA, Sparcv8 ISA) -->7
load --> load --> mul(35) --> store(2)
8- compare_test (based on ARM v2A ISA) -->8
load --> load --> compare
any other input wil terminate the simulation
DUT: """;
	g = raw_input(s);
	print (g);
	if g == "1":
		y=("add_test")
		os.system(x+y+" +ARG_INST=A; log /* -r ; run -all ; quit\"")
################################################################################################################
	elif g == "2":
		y=("bief_test")
		s="""
please choose which instruction to simulate:
1- branch if equal flag (based on sparc-v8 ISA): enter --> BIEF
2- branch if Negative flag (based on sparc-v8 ISA): enter --> BNEGF
3- branch if carry flag (based on sparc-v8 ISA): enter --> BCSF
4- branch if overflow flag (based on sparc-v8 ISA): enter --> BVSF
any other input will simulate no operation or make an error in the simulation
DUT: """;
		z=raw_input(s)
		if z == "1":
			z=("BIEF")
		elif z == "2":
			z=("BNEGF")
		elif z == "3":
			z=("BCSF")
		elif z == "4":
			z=("BVSF")
		os.system(x+y+" +ARG_INST="+z+"; log /* -r ; run -all ; quit\"")
################################################################################################################
	elif g == "3":
		y=("A_type_test")

		instructions_list = ['A', 'BIER', 'BIGTOER', 'BILTR', 'BIGTOERU', 'BILTRU' ,'LSBMA','LSHMA','LUBMA', 'LUHMA','LWMA','LW','LDW','LWRR','LSBMARR','LSHMARR','LUBMARR','LUHMARR','LWMARR','LWMAZE','LWMAZERR','LBMAZE','LBMAZERR','SRwMas','SRwM','Sabbram','ALUB','ALUBas','SRwMw']    
		os.system(x+y+" +ARG_INST="+random.choice(instructions_list)+"; log /* -r ; run -all ; quit\"")
################################################################################################################
	elif g == "4":
		y=("load_double_test")
		s="""
please choose which instruction to simulate:
1- load double word (based on sparc-v8 ISA): enter --> LDD
2- load double word reg-reg (based on sparc-v8 ISA): enter --> LDDRR
any other input will simulate no operation or make an error in the simulation
DUT: """;
		z=raw_input(s)
		if z == "1":
			z=("LDD")
		elif z == "2":
			z=("LDDRR")
		os.system(x+y+" +ARG_INST="+z+"; log /* -r ; run -all ; quit\"")
################################################################################################################
	elif g == "5":
		y=("arith_flag_test")
		s="""
please choose which instruction to simulate:
1- ADD  (based on sparc-v8 ISA): enter --> add
2- Add and change ICC flags (based on sparc-v8 ISA): enter --> addcc
3- Add with carry (based on sparc-v8 ISA): enter --> addx
4- Add with carry and change ICC flags(based on sparc-v8 ISA): enter --> addxcc
any other input will simulate no operation or make an error in the simulation
DUT: """;
		z=raw_input(s)     
		if z == "1":
			z=("A")
		elif z == "2":
			z=("ADDCC")
		elif z == "3":
			z=("ADDX")
		elif z == "4":
			z=("ADDXCC")
        
		os.system(x+y+" +ARG_INST="+z+"; log /* -r ; run -all ; quit\"")
################################################################################################################
	elif g == "6":
		y=("store_test")

		instructions_list = ['SBMA', 'SHMA', 'SWMA', 'SB', 'SH', 'SW' ,'SBRR','SHRR','SWRR', 'SWZE','SWZERR','SBZE','SBZERR']    
            
		os.system(x+y+" +ARG_INST="+random.choice(instructions_list)+"; log /* -r ; run -all ; quit\"")
################################################################################################################
	elif g == "7": 
		y=("mul_test")
		s="""
please choose which instruction to simulate:
1- multiply unsigned reg-reg (based on RISC-v ISA and Sparc-V8 ISA): enter --> UMULR
2- multiply signed and get the upper half of result reg-reg (based on RISC-v ISA): enter --> MHSR
3- multiply signed-unsigned and get the upper half of result reg-reg (based on RISC-v ISA): enter --> MHSUR
4- multiply unsigned and get the upper half of result reg-reg (based on sparc-v8 ISA): enter --> MHUR
any other input will simulate no operation or make an error in the simulation
DUT: """;
		z=raw_input(s)
		if z == "1":
			z=("UMULR")
		elif z == "2":
			z=("MHSR")
		elif z == "3":
			z=("MHSUR")
		elif z == "4":
			z=("MHUR")
		os.system(x+y+" +ARG_INST="+z+"; log /* -r ; run -all ; quit\"")
################################################################################################################
	#elif g == "8":
               # y=("compare_test")
               # s="""
#please choose which instruction to simulate:
#1- Compare zero extending offset and reg-reg (based on ARM-v2a ISA): enter --> C
#2- Compare zero extending offset and reg-reg (based on ARM-v2a ISA): enter --> CN
#any other input will simulate no operation or make an error in the simulation
#DUT: """;
              #  z=raw_input(s)
              #  if z == "1":
               #         z=("C")
               # elif z == "2":
               #         z=("CN")
               # os.system(x+y+" +ARG_INST="+z+"; log /* -r ; run -all ; quit\"")	
################################################################################################################	
	elif g == "8": 
			y=("compare_test")
			s="""
	please choose which instruction to simulate:
	1- multiply unsigned reg-reg (based on RISC-v ISA and Sparc-V8 ISA): enter --> C
	2- multiply signed and get the upper half of result reg-reg (based on RISC-v ISA): enter --> CN
	any other input will simulate no operation or make an error in the simulation
	DUT: """;
			z=raw_input(s)
			if z == "1":
				z=("C")
			elif z == "2":
				z=("CN")
			os.system(x+y+" +ARG_INST="+z+"; log /* -r ; run -all ; quit\"")
################################################################################################################
	
			
	else:
		print("please enter a valid number")
		break
	raw_input('Press any key to start again')
	os.system("cls")
