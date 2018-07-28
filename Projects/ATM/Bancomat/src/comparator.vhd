--used to validate the extraction sum

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity comparator is
	port( Enable: in Std_logic;
		  Suma_utilizator: in Std_logic_vector(15 downto 0);
		  adresa_card: in std_logic_vector(3 downto 0);
		  Validation: out Std_logic := '1';
		  done : out std_logic := '0';
		  nr_coins: out std_logic_vector(19 downto 0));
end comparator;

--}} End of automatically maintained section

architecture arh of comparator is

component Mem_RAM_SOLD is						     --sold client
	port(ADDRESS: in Std_logic_vector(3 downto 0);
	     DATAIN: in STD_LOGIC_VEctor(15 downto 0);
		 DATAOUT: out STd_logic_vector(15 downto 0);
		 WE: in STD_LOGIC);
end component;

component Mem_Ram_Bancomat is						  --registru bancomat
	port(Address: in Std_logic_vector(2 downto 0);
		 DataIn: in Std_logic_vector(7 downto 0);
		 DataOut: out Std_logic_vector(7 downto 0);
		 WE: in Std_logic);
end component;

signal card_out: std_logic_vector(15 downto 0) := "0000000000000000";				  --sold

signal cash_address: std_logic_vector(2 downto 0) := "000";
signal cash_out: std_logic_vector(7 downto 0) := "00000000";				  --cash register

function make_number (vector : std_logic_vector(15 downto 0)) return integer is
variable number : integer := 0;
begin
	for i in 0 to 3 loop							
		number := number * 10 +	conv_integer(vector(3 + 4*(3-i) downto 0 + 4*(3-i)));
	end loop;																		
	return number;
end;

signal suma : integer := make_number(suma_utilizator);	  
signal reg_addr: std_logic_vector(2 downto 0) := "000";	
signal test : std_logic := '0';
signal valid1, valid2 : std_logic := '1';
signal coin_array : std_logic_vector(19 downto 0);
signal intDone : std_logic := '0';

begin
	
	sold: Mem_RAM_SOLD port map(adresa_card, "UUUUUUUUUUUUUUUU", card_out, '0');
	cash: Mem_Ram_Bancomat port map(cash_address, "UUUUUUUU", cash_out, '0');
	
	sarac: process(enable, suma_utilizator, adresa_card)
	begin
		if(enable = '1' and make_number(suma_utilizator) > make_number(card_out)) then valid1 <= '0';
		else null;
		end if;
	end process;
	
	avem_bancnote: process(enable, suma_utilizator, reg_Addr)

	variable coin : integer;
	variable coinCount : integer; 
	variable temp : integer;
	variable intValid : std_logic := '1'; 
	variable intSum : integer := 0;
	variable coin_array_address : integer;
	begin
		if(enable = '1' and intDone = '0') then
			if(reg_addr = "101") then
				reg_addr <= "000";
				intDone <= '1';
				if(intSum > 0) then 
					intValid := '0';
					test <= '1';
				else null;
				end if;
			else
				cash_address <= reg_addr;
				case reg_addr is
					when "000" => coin := 500;
								  coin_array_address := 0;
					when "001" => coin := 200;
								  coin_array_address := 4;
					when "010" => coin := 100;
								  coin_array_address := 8;
					when "011" => coin := 50;			  
								  coin_array_address := 12;
					when "100" => coin := 10;			   
								  coin_array_address := 16;
					when others => null;
				end case;  
				coinCount := intSum / coin;
				temp := conv_integer(cash_out);
				if(coinCount > temp) then coinCount := temp;
				else null;
				end if;	 
				
				coin_array(coin_array_address + 3 downto coin_array_address) <= std_logic_vector(to_unsigned(coinCount, 4)); 
				
				intSum := intSum - (coinCount * coin);
				reg_addr <= reg_addr + 1;
			 end if;
		else
			reg_addr <= "000";  
			intSum := make_number(suma_utilizator);	
			coin_array <= (others => '0');
		end if;	  
		
		if(intDone = '1') then intDone <= '0';
		else null;
		end if;
		
		done <= intDone;
		valid2 <= intValid;
		Suma <= intSum;
		nr_coins <= coin_array;
	end process;
	
	Validation <= valid1 and valid2;
	
end arh;
