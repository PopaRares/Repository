library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.NUMERIC_STD.all;

entity PlusMinus is
	port(A,B:in STD_LOGIC_VECTOR(15 DOWNTO 0);-- A > B
		 operation: in STD_LOGIC;
		 done: in STD_LOGIC;
		 Rez:out STD_LOGIC_VECTOR(15 DOWNTO 0));
end PlusMinus;



architecture operations of PlusMinus is

function make_number (vector : std_logic_vector(15 downto 0)) return integer is
variable number : integer := 0;
begin
	for i in 0 to 3 loop							
		number := number * 10 +	conv_integer(vector(3 + 4*(3-i) downto 0 + 4*(3-i)));
	end loop;																		
	return number;
end;

begin
	
	calcul: process (A, B, operation, done) is
	variable result : integer;
	variable i : integer := 0;
	begin
		if(done = '0' or done = 'U') then
			if(operation = '0')	then
				 result := make_number(A) + make_number(B);
		    else result := make_number(A) - make_number(B); 
			end if;
		
			i := 0;			 
			Rez <= "0000000000000000";
			while (i < 4) loop
				Rez(3 + 4*i downto 0 + 4*i) <= std_logic_vector(to_unsigned(result mod 10, 4));
				i := i + 1;
				result := result / 10;
			end loop;
		end if;
	end process;
end operations;
