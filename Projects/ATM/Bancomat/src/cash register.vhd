library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Mem_Ram_Bancomat is
	port(Address: in Std_logic_vector(2 downto 0);
		 DataIn: in Std_logic_vector(7 downto 0);
		 DataOut: out Std_logic_vector(7 downto 0);
		 WE: in Std_logic);
end Mem_Ram_Bancomat;

architecture Arh of Mem_Ram_Bancomat is	
type Mem is array (0 to 4) of Std_logic_vector(7 downto 0);
signal Memory: Mem:=("00001010", --500
					 "00011001", --200
       				 "00110010", --100
	                 "01100100", --50
					 "11111111");--10
signal Addr: Integer := 0;
begin							  
	process(Address,DataIn,WE)
	begin
		Addr<=Conv_Integer(Address);
		if(WE='1') then
			Memory(Addr)<=DataIn;
		elsif We='0' then
			DataOut<=Memory(Addr);
		else 
			DataOut<="ZZZZZZZZ";
		end if;
	end process;
	 -- enter your statements here --

end Arh;	




