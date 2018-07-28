library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sum is
	port(
		enable: in STD_LOGIC;
		sel: in STD_LOGIC_VECTOR(1 DOWNTO 0);
		x: in STD_LOGIC_VECTOR(3 DOWNTO 0);
		button: in STD_LOGIC;
		final_sum: out STD_LOGIC_VECTOR(15 DOWNTO 0);
		complete: out STD_LOGIC
		);
end sum;		 

architecture read of sum is
begin
	process(button)
	begin
	if button = '1' and enable = '1' then	
		case sel is			
			when "00" => final_sum(3 downto 0) <= x; 
			when "01" => final_sum(7 downto 4) <= x; 
			when "10" => final_sum(11 downto 8) <= x; 
			when "11" => final_sum(15 downto 12) <= x;  
			when others => null; 	  
		end case;
		 complete <= '1';
	end if;
	end process;
end read;