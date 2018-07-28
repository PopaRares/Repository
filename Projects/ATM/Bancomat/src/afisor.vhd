library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity screen is
	port(
		number:in std_logic_vector(15 downto 0);
		clk: in STD_LOGIC;
		clear: in STD_LOGIC;
		LED_out: out STD_LOGIC_VECTOR(6 downto 0);
		anode: out STD_LOGIC_VECTOR(3 downto 0)	 --pentru selectarea unui singur afisaj (active pe 0)
		);
end screen;		

architecture LED of screen is
signal sel: STD_LOGIC_VECTOR(1 downto 0);--select
signal digit: STD_LOGIC_VECTOR(3 downto 0);
signal clk_divisor: STD_LOGIC_VECTOR(18 downto 0);

begin 
	sel<=clk_divisor(18 downto 17);
	
	Select_anode: process(sel, number)
	begin
		if clear = '0' then
			case sel is
				when "00" => digit <= number(3 downto 0);
							 anode <= "0111";--LED 1
				when "01" => digit <= number(7 downto 4);
							 anode <= "1011";--LED 2
				when "10" => digit <= number(11 downto 8); 
							 anode <= "1101";--LED 3
				when "11" => digit <= number(15 downto 12);
							 anode <= "1110";--LED 4 
				when others => null;
			end case;
		end if;
	end process;

	Decode: process(digit)
	begin
		case digit is
			when "0000"=> LED_out <="1000000";  -- 0
			when "0001"=> LED_out <="1111001";  -- 1
			when "0010"=> LED_out <="0100100";  -- 2
			when "0011"=> LED_out <="0110000";  -- 3
			when "0100"=> LED_out <="0011011";  -- 4 
			when "0101"=> LED_out <="0010010";  -- 5
			when "0110"=> LED_out <="0000010";  -- 6
			when "0111"=> LED_out <="1111000";  -- 7
			when "1000"=> LED_out <="0000000";  -- 8
			when "1001"=> LED_out <="0010000";  -- 9
			when others=> LED_out <="1111111"; 	-- gol
		end case;
	end process;

	Divisor: process(clk)
	begin
		if clear = '1' then
			clk_divisor <= (others => '0');
		elsif clk'event and clk = '1' then
			clk_divisor <= clk_divisor + 1;
		end if;
	end process;
			
end LED;