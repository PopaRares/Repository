--------------------------------------------------------------------------------
--
--   FileName:         debounce.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 32-bit Version 11.1 Build 173 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 3/26/2012 Scott Larson
--     Initial Public Release
--
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

entity debouncer is
  	generic(DB_size:INTEGER := 19); --10.5ms pe ceas de 50mHz
  	port(
    	CLK: in  STD_LOGIC;  
    	input: in STD_LOGIC;
    	debounced: out STD_LOGIC); 
end debouncer;

architecture normalise of debouncer is

begin   
	DEBOUNCER: process(CLK)
  		variable BIST: STD_LOGIC_VECTOR(1 downto 0); --2 bistabile debouncer
  		variable DB_reset: STD_LOGIC;--reset numarator debouncer                    
  		variable DB_out: STD_LOGIC_VECTOR(DB_size downto 0) := (others => '0');--iesire numarator debouncer
  	begin		  
		
		DB_reset := BIST(0) xor BIST(1);
    	if rising_edge(CLK) then
      		BIST(0) := input;
      		BIST(1) := BIST(0);
      		
			if(DB_reset = '1') then                  
      			DB_out := (others => '0');
      		
			elsif(DB_out(DB_size) = '0') then 
        		DB_out := DB_out + 1;
      		
			else                                        
        		debounced <= BIST(1);
      		end if;    
    	
		end if;
 	end process DEBOUNCER;
	 
end normalise;
