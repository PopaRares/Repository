LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

entity card_id is
	port(
		adresa_card: in STD_LOGIC_VECTOR(3 downto 0);
		input_card: in STD_LOGIC;
		card_num: inout INTEGER range 0 to 15;
		valid: out STD_LOGIC
		);
end card_id;

architecture identify of card_id is
begin
	process(input_card)
	begin
		if(input_card='1') then
			case adresa_card is	
				when "0001" => card_num <=1;
				when "0010" => card_num <=2;
				when "0011" => card_num <=3;
				when "0100" => card_num <=4;
				when "0101" => card_num <=5;
				when "0110" => card_num <=6;
				when "0111" => card_num <=7;
				when "1000" => card_num <=8;
				when "1001" => card_num <=9;
				when "1010" => card_num <=10;
				when "1011" => card_num <=11;
				when "1100" => card_num <=12;
				when "1101" => card_num <=13;
				when "1110" => card_num <=14;
				when "1111" => card_num <=15;	 
				when others => null;  
			end case;	 
		end if;	
    end process;	 

end identify;