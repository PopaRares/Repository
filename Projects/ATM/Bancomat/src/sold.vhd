library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Mem_RAM_SOLD is
	port(ADDRESS: in Std_logic_vector(3 downto 0);
	     DATAIN: in STD_LOGIC_VEctor(15 downto 0);
		 DATAOUT: out STd_logic_vector(15 downto 0);
		 WE: in STD_LOGIC);
end Mem_RAM_SOLD;

--suma e pastrata pe 16 biti, fiecare 4 biti constituie o cifra

architecture ARH_Mem_RAM_SOLD of Mem_RAM_SOLD is
type MEM is array (0 to 15) of STD_logic_vector(15 downto 0);
signal Memory: MEM :=("0010000000000000",
					  "0001100100000000",
					  "0001100000000000",
					  "0001011100000000",
					  "0001011000000000",
					  "0001010100000000",
					  "0001010000000000",
					  "0001001100000000",
					  "0001001000000000",
					  "0001000100000000",
					  "0001000000000000",
					  "0000100100000000",
					  "0000100000000000",
					  "0000011100000000",
					  "0000011000000000",
					  "0000010100000000");
signal ADDR: Integer Range 0 to 15;
begin
	process(ADDRESS,DATAIN, WE)
	begin
		ADDR<=Conv_Integer(ADDRESS);
		if WE='1' then
			Memory(Addr)<=DATAIN;
		elsif WE='0' then
			DATAOUT<=Memory(ADDR);
		else 
			DATAOUT<="ZZZZZZZZZZZZZZZZ";
		end if;	

	  end process;
end ARH_Mem_RAM_SOLD;