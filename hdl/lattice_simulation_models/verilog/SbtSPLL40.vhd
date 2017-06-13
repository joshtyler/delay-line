-------------------------------------------------------------------------
--			 	SbtSPLL40  				---	
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;
use work.std_logic_SBT.all;
use work.all; 
 

entity SbtSPLL40  is
 
	generic ( 
		 FEEDBACK_PATH 			: string 		 :="SIMPLE"; 
		 DELAY_ADJUSTMENT_MODE_FEEDBACK	: string 		 :="FIXED"; 
		 DELAY_ADJUSTMENT_MODE_RELATIVE : string 		 :="FIXED";
		 SHIFTREG_DIV_MODE		: bit_vector(1 downto 0) := "00"; 
		 FDA_FEEDBACK			: bit_vector(3 downto 0) :="0000";
		 FDA_RELATIVE			: bit_vector(3 downto 0) := "0000";
		 PLLOUT_SELECT_PORTA		: string 		 :="GENCLK"; 
		 PLLOUT_SELECT_PORTB            : string         	 :="GENCLK";

		 DIVR				: bit_vector(3 downto 0) := "0000";
		 DIVF  				: bit_vector(6 downto 0) := "0000000";
		 DIVQ	   			: bit_vector(2 downto 0) := "000";  
		 FILTER_RANGE 			: bit_vector(2 downto 0) := "000";
		 		
 		 ENABLE_ICEGATE_PORTA            : bit 			 :='0';
		 ENABLE_ICEGATE_PORTB           : bit 			 :='0' 
	);
	port	(
		REFERENCECLK	: in    std_logic;
		EXTFEEDBACK 	: in    std_logic; 				 	
		DYNAMICDELAY	: in    std_logic_vector(7 downto 0); 
		BYPASS 		: in	std_logic;
		RESETB	 	: in 	std_logic;
		PLLOUT1 	: out  	std_logic;
		PLLOUT2		: out 	std_logic ; 
		LOCK		: out 	std_logic  
	); 

end SbtSPLL40;

	
architecture SbtSPLL40_arch  of SbtSPLL40  is

component ShiftReg427  is
 
	generic ( 
		SHIFTREG_DIV_MODE :  bit_vector(1 downto 0) := "00"  
		);
	port 	( 
		clk 		: in std_logic; 
		init 		: in std_logic; 
		phase0 		: out std_logic; 
		phase90		: out std_logic
		); 
end component;

component  mux4to1   is
	port ( 
		a,b,c,d : in std_logic; 
		sel 	: in std_logic_vector(1 downto 0); 
		o	: out std_logic 
	      ); 
end component ;


component FineDlyAdj  is
	generic (
		FIXED_DELAY_ADJUSTMENT   : bit_vector(3 downto 0) :="0000"; 
		DELAY_ADJUSTMENT_MODE    : string 		  :="FIXED";
		BUF_DELAY		 : time 		  := 100 ps;
		MUXINV_DELAY		 : time 		  := 0 ps
		); 
	port 	( 
		signalin		:in  std_logic; 
		DlyAdj			:in  std_logic_vector(3 downto 0); 
		delayedout 		:out std_logic
		); 
end component ;

 
component  ABIWTCZ4  is 
  port  	(
                REF	:in  std_logic; 
                FB  	:in  std_logic; 
                FSE	:in  std_logic; 
                BYPASS 	:in  std_logic;
                RESET	:in  std_logic; 
                DIVF6	:in  std_logic; 
                DIVF5 	:in  std_logic; 
                DIVF4 	:in  std_logic; 
                DIVF3 	:in  std_logic; 
                DIVF2 	:in  std_logic; 
                DIVF1	:in  std_logic; 
                DIVF0 	:in  std_logic; 
                DIVQ2	:in  std_logic; 
                DIVQ1 	:in  std_logic; 
                DIVQ0 	:in  std_logic; 
                DIVR3 	:in  std_logic; 
                DIVR2 	:in  std_logic; 
                DIVR1 	:in  std_logic; 
                DIVR0	:in  std_logic; 
                RANGE2  :in  std_logic; 
                RANGE1  :in  std_logic;
                RANGE0  :in  std_logic; 
                LOCK    :out std_logic;
                PLLOUT  :out std_logic  
                );
end component; 

 signal DIVFBus    		: std_logic_vector(6 downto 0); 
 signal DIVRBus 		: std_logic_vector(3 downto 0); 
 signal DIVQBus 		: std_logic_vector(2 downto 0); 
 signal RANGEBus 		: std_logic_vector(2 downto 0); 	 	

 signal ABPLLOUTDiv2		: std_logic :='0'; 
 signal ABPLLOUT     		: std_logic ; 
 signal FSEnet       		: std_logic ; 
 signal FBnet 	     		: std_logic ; 	

 signal phase0net, phase90net  	: std_logic; 
 signal delaymuxsel  		: std_logic_vector(1 downto 0);
 signal pllout1Sel,pllout2Sel	: std_logic_vector(1 downto 0);	
 signal pllout1Muxnet, pllout2Muxnet 		: std_logic; 	 

 signal finedelayFBin 		: std_logic; 
 signal finedelayFBout		: std_logic; 
 signal fdaRelInput		: std_logic;

begin 

 -- generic conversions   
 DIVFBus <= TO_STDLOGICVECTOR(DIVF); 		
 DIVRBus <= TO_STDLOGICVECTOR(DIVR);
 DIVQBus <= TO_STDLOGICVECTOR(DIVQ); 		
 RANGEBus <= TO_STDLOGICVECTOR(FILTER_RANGE); 		
  -- validations 
 initial_proc : process 
 begin 
 if (PLLOUT_SELECT_PORTA = "SHIFTREG_0deg") then 
    pllout1Sel <= "00";
 elsif (PLLOUT_SELECT_PORTA = "SHIFTREG_90deg") then 
    pllout1Sel <= "01";
 elsif (PLLOUT_SELECT_PORTA = "GENCLK_HALF") then 
    pllout1Sel <= "10";
 elsif (PLLOUT_SELECT_PORTA = "GENCLK") then 
    pllout1Sel <= "11";
 else 
        report ("************************SBT : ERROR ****************************") severity error;
       	report ("Parameter PLLOUT_SELECT_PORTA is set to an illegal value.") severity error;
        report ("Legal values should be one of SHIFTREG_0deg, SHIFTREG_90deg, GENCLK_HALF, GENCLK") severity error;
        report ("Due to incorrect configuration of the PLL, the simulation results are invalid.");
 end if ;	



 if (PLLOUT_SELECT_PORTB = "SHIFTREG_0deg") then 
    pllout2Sel <= "00";
 elsif (PLLOUT_SELECT_PORTB = "SHIFTREG_90deg") then 
    pllout2Sel <= "01";
 elsif (PLLOUT_SELECT_PORTB = "GENCLK_HALF") then 
    pllout2Sel <= "10";
 elsif (PLLOUT_SELECT_PORTB = "GENCLK") then 
    pllout2Sel <= "11";
 else 
        report ("************************SBT : ERROR ****************************") severity error;
       	report ("Parameter PLLOUT_SELECT_PORTB is set to an illegal value.") severity error;
        report ("Legal values should be one of SHIFTREG_0deg, SHIFTREG_90deg, GENCLK_HALF, GENCLK") severity error;
        report ("Due to incorrect configuration of the PLL, the simulation results are invalid.");
 end if ;	


 -- FB 
  if (FEEDBACK_PATH /= "EXTERNAL") then
            report ("************************SBT : Info*****************************");
            report ("PLL Feedback is set to INTERNAL. Any signal connected to the EXTFEEDBACK port of the PLL will be ignored");
  end if; 

 if (FEEDBACK_PATH = "EXTERNAL") then 
       delaymuxsel <= "11";

        if((DELAY_ADJUSTMENT_MODE_FEEDBACK /= "FIXED") and (DELAY_ADJUSTMENT_MODE_FEEDBACK /= "DYNAMIC") ) then 
                report ("************************SBT : ERROR ************************");
                report ("Since FEEDBACK_PATH=EXTERNAL, DELAY_ADJUSTMENT_MODE_FEEDBACK should be FIXED or DYNAMIC");
                report ("Due to incorrect configuration of the PLL, the simulation results are invalid.");
        end if; 
        if (PLLOUT_SELECT_PORTA = "SHIFTREG_0deg" or  PLLOUT_SELECT_PORTA = "SHIFTREG_90deg" 
			or PLLOUT_SELECT_PORTB = "SHIFTREG_0deg" or  PLLOUT_SELECT_PORTB = "SHIFTREG_90deg")  then 
                report ("************************ SBT : ERROR **************************") severity error;
                report ("Since FEEDBACK_PATH=EXTERNAL, Phase Adjustment is NOT permitted.") severity error;
        end if; 

   elsif (FEEDBACK_PATH = "DELAY") then 
        delaymuxsel <= "00";
        if ( (DELAY_ADJUSTMENT_MODE_FEEDBACK /= "FIXED") and (DELAY_ADJUSTMENT_MODE_FEEDBACK /= "DYNAMIC") ) then 
                report ("************************ SBT : ERROR **************************") severity error ;
                report ("Since FEEDBACK_PATH=DELAY, DELAY_ADJUSTMENT_MODE_FEEDBACK should be FIXED or DYNAMIC") severity error ;
                report ("Due to incorrect configuration of the PLL, the simulation results are invalid.");
        end if; 
        if (PLLOUT_SELECT_PORTA = "SHIFTREG_0deg" or  PLLOUT_SELECT_PORTA = "SHIFTREG_90deg"
                    or PLLOUT_SELECT_PORTB = "SHIFTREG_0deg" or PLLOUT_SELECT_PORTB = "SHIFTREG_90deg") then  
                report ("************************ SBT : ERROR **************************") severity error;
                report ("Since FEEDBACK_PATH=DELAY, Phase Adjustment is NOT permitted. Please set PLLOUT_SELECT_PORTA/B=GENCLK or GENCLK_HALF");
                report ("Due to incorrect configuration of the PLL, the simulation results are invalid.");
 	end if;
    elsif (FEEDBACK_PATH = "PHASE_AND_DELAY") then 
        delaymuxsel <= "01";
        if ( (DELAY_ADJUSTMENT_MODE_FEEDBACK /= "FIXED") and (DELAY_ADJUSTMENT_MODE_FEEDBACK /= "DYNAMIC") ) then 
                report ("************************SBT : Attention************************");
                report ("Since FEEDBACK_PATH=PHASE_AND_DELAY, DELAY_ADJUSTMENT_MODE_FEEDBACK should be FIXED or DYNAMIC");
        end if; 
        if ( (PLLOUT_SELECT_PORTA /= "SHIFTREG_0deg") and (PLLOUT_SELECT_PORTA /= "SHIFTREG_90deg" )
                                and (PLLOUT_SELECT_PORTB /= "SHIFTREG_0deg") and  (PLLOUT_SELECT_PORTB /= "SHIFTREG_90deg") ) then 
                report ("************************SBT : Attention************************") severity note;
                report ("FEEDBACK_PATH=PHASE_AND_DELAY, but PLLOUT_SELECT_PORTA/B is not specified correctly") severity note;
        end if; 
   elsif (FEEDBACK_PATH = "SIMPLE") then 
	-- delaymuxsel <= "00";  -- Not used 
                -- Ignore DELAY_ADJUSTMENT_MODE_FEEDBACK, FDA_FEEDBACK
          report ("************************SBT : Attention***************************") severity note;
          report ("Since FEEDBACK_PATH=SIMPLE, the FDA_FEEDBACK value will be ignored") severity note;

        if (PLLOUT_SELECT_PORTA = "SHIFTREG_0deg" or PLLOUT_SELECT_PORTA = "SHIFTREG_90deg"
                   or PLLOUT_SELECT_PORTB = "SHIFTREG_0deg" or PLLOUT_SELECT_PORTB = "SHIFTREG_90deg")  then  
                report ("************************SBT : Attention***************************") severity note;
                report ("The PLL output frequency will be divided by 4 or 5 or 7 and phase shifted.") severity note;
                report ("To avoid this, please set PLLOUT_SELECT_PORTA/B = GENCLK");
        end if;
   else
                report ("************************SBT : Attention***************************") severity note;
                report ("Please set FEEDBACK_PATH to a valid value. Legal settings should be one of SIMPLE, DELAY, PHASE_AND_DELAY, EXTERNAL") severity note;
  end if; 

   if( SHIFTREG_DIV_MODE ="10") then 
                report ("************************ SBT : ERROR **************************") severity error ;
                report ("SHIFTREG_DIV_MODE =10 is NOT permitted. Please set it 00/01/11") severity error  ;
                report ("Due to incorrect configuration of the PLL, the simulation results are invalid.") severity error ;
   end if; 	
 
 wait ;			-- wait forever  

 end process initial_proc;   

  -- logic 	

 ABPLLoutdiv_proc: process(ABPLLOUT) 
 begin 
	if rising_edge(ABPLLOUT) then 
		ABPLLOUTDiv2 <= not(ABPLLOUTDiv2); 
	end if ;
 end  process ABPLLoutdiv_proc; 

  -- FSE sections
 FSEnet <= '1' when FEEDBACK_PATH = "SIMPLE" else '0';  

 FBnetsel_proc:  process(finedelayFBout) 
 begin 
	if(FEEDBACK_PATH = "SIMPLE") then
	   FBnet <= '0' ; 
	else
	   FBnet <= finedelayFBout after 1 ps;  -- 1ps delay to handle NaN  issue. 
	end if;  	
 end process FBnetsel_proc; 


 instShftReg427 : ShiftReg427  
 generic map( 
	  	 SHIFTREG_DIV_MODE => SHIFTREG_DIV_MODE
            )
 port  map  (	
                clk => ABPLLOUT, 
                init => RESETB,
                phase0 => phase0net, 
                phase90 => phase90net
            );

 instFBDlyAdjInMux : mux4to1	
 port map (
		 a=>ABPLLOUT,
		 b=>phase0net,
		 c=>phase0net,
		 d=>EXTFEEDBACK,
		 sel=>delaymuxsel(1 downto 0),
		 o=>finedelayFBin
	);   


 instPLLOUT2SelMux : mux4to1 
 port map (
		 a=>phase0net,
		 b=>phase90net,
		 c=>ABPLLOUTDiv2,
		 d=>ABPLLOUT,
		 sel=>pllout2Sel(1 downto 0),
		 o=>pllout2Muxnet
	);   
    
 bypasspll2_proc:  process(REFERENCECLK, pllout2Muxnet) 
 begin 	 	
	if(BYPASS ='1') then 
	PLLOUT2 <= REFERENCECLK; 
	else 
	PLLOUT2 <= pllout2Muxnet; 
	end if ; 
 end process bypasspll2_proc;   

	
 instPLLOUT1SelMux : mux4to1 
 port map (
		 a=>phase0net,
		 b=>phase90net,
		 c=>ABPLLOUTDiv2,
		 d=>ABPLLOUT,
		 sel=>pllout1Sel(1 downto 0),
		 o=>pllout1Muxnet
	);   

  
 bypasspll1_proc: process(REFERENCECLK, pllout1Muxnet) 
 begin 	 	
	if(BYPASS ='1') then 
	fdaRelInput <= REFERENCECLK; 
	else 
	fdaRelInput <= pllout1Muxnet; 
	end if ; 
 end process bypasspll1_proc;   

 instFineDlyAdjFB : FineDlyAdj 
 generic map    ( 
		FIXED_DELAY_ADJUSTMENT => FDA_FEEDBACK, 
		DELAY_ADJUSTMENT_MODE  => DELAY_ADJUSTMENT_MODE_FEEDBACK
		)	
 port map      (
                DlyAdj => DYNAMICDELAY(3 downto 0),
                signalin=>finedelayFBin,
                delayedout=>finedelayFBout
                );

 instFineDlyAdjRel : FineDlyAdj 
 generic map 	( 
		FIXED_DELAY_ADJUSTMENT => FDA_RELATIVE, 
		DELAY_ADJUSTMENT_MODE  => DELAY_ADJUSTMENT_MODE_RELATIVE
		)		
  port map	(
                DlyAdj => DYNAMICDELAY(7 downto 4),
                signalin =>fdaRelInput,
                delayedout => PLLOUT1 
                );

 instABitsPLL : ABIWTCZ4 
 port map  	(
                REF => REFERENCECLK,
                FB  => FBnet,
                FSE => FSEnet,
                BYPASS => BYPASS,
                RESET => RESETB,
                DIVF6 => DIVFBus(6),
                DIVF5 =>DIVFBus(5),
                DIVF4 => DIVFBus(4),
                DIVF3 =>DIVFBus(3),
                DIVF2 =>DIVFBus(2),
                DIVF1 => DIVFBus(1),
                DIVF0 => DIVFBus(0),
                DIVQ2 => DIVQBus(2),
                DIVQ1 => DIVQBus(1),
                DIVQ0 => DIVQBus(0),
                DIVR3 => DIVRBus(3),
                DIVR2 => DIVRBus(2),
                DIVR1 => DIVRBus(1),
                DIVR0 => DIVRBus(0),
                RANGE2 => RANGEBus(2),
                RANGE1 => RANGEBus(1),
                RANGE0 => RANGEBus(0),
                LOCK => LOCK,
                PLLOUT =>ABPLLOUT 
                );

end SbtSPLL40_arch;

