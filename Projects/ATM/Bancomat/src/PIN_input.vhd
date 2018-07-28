library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity PIN_read is
	port(
		PIN: in STD_LOGIC_VECTOR (3 downto 0);--number input
		button: in STD_LOGIC;
		reset: in STD_LOGIC;
		complete: out STD_LOGIC;
		PIN_code: out STD_LOGIC_VECTOR (15 downto 0);
		ceva_numar_idk: out integer
		);
		
end PIN_read;

--}} End of automatically maintained section

architecture PIN_input of PIN_read is
begin
	PIN_input: process(reset, button, PIN)
  	variable current_digit : INTEGER := 3;
  	begin
	  
	  if(reset = '1') then	  -- reset
		  PIN_code <= (others => '0');
		  current_digit := 3;
	  end if;
	  
	  for i in 0 to 3 loop		   -- memorise digit in right place
	  	PIN_code(i + (current_digit * 4)) <= PIN(i);
	  end loop;  
	  
	  if(button = '1') then		   -- moving to next digit
		  current_digit := current_digit - 1;
	  end if;
	  
	  if(current_digit = -1) then
		  current_digit := 3;
		  complete <= '1';
	  end if; 
	  ceva_numar_idk <= current_digit;
  end process PIN_INPUT;

end PIN_input;
