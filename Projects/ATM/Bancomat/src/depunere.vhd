library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;

entity depunere is
	port(money : in std_logic_vector(3 downto 0);
		 submit : in std_logic;
		 enable : in std_logic;
		 account_address : in std_logic_vector(3 downto 0);
		 gata : out std_logic);
end depunere;


architecture depunere of depunere is

component Mem_Ram_Bancomat is
	port(Address: in Std_logic_vector(2 downto 0);
		 DataIn: in Std_logic_vector(7 downto 0);
		 DataOut: out Std_logic_vector(7 downto 0);
		 WE: in Std_logic);
end component;

component Mem_Ram_SOLD is
	port(ADDRESS: in std_logic_vector(3 downto 0);
	     DATAIN: in std_logic_vector(15 downto 0);
		 DATAOUT: out std_logic_vector(15 downto 0);
		 WE: in std_logic);
end component;

component PlusMinus is
	port(A,B:in STD_LOGIC_VECTOR(15 DOWNTO 0);-- A > B
		 operation: in STD_LOGIC;
		 done: inout STD_LOGIC;
		 Rez:out STD_LOGIC_VECTOR(15 DOWNTO 0));
end component;

signal op1, op2: std_logic_vector(15 downto 0);
signal SumEnable: std_logic := '1';
signal result : std_logic_vector(15 downto 0);		  --sumator-scazator

--signal card_address: std_logic_vector(3 downto 0) := "0000";
signal card_dataIn: std_logic_vector(15 downto 0);
signal card_dataOut: std_logic_vector(15 downto 0);
signal card_write: std_logic := '0';				  --sold

signal cash_address: std_logic_vector(2 downto 0);
signal cash_in: std_logic_vector(7 downto 0);
signal cash_out: std_logic_vector(7 downto 0);
signal cash_write: std_logic := '0';				  --cash register

--WE = 0 => citire
signal num: std_logic_vector(2 downto 0) := "000";

signal temp: std_logic_vector(15 downto 0);

function vectorize (number : integer) return std_logic_vector is
variable vector : std_logic_vector(15 downto 0);
variable i : integer;
variable nr : integer := number;
begin		  
	i := 0;
	vector := "0000000000000000";
	while (nr > 0) loop
		vector(3 + i*4 downto 0 + i*4) := std_logic_vector(to_unsigned(nr mod 10, 4)); 
		nr := nr / 10;
		i := i + 1;
	end loop;
	return vector;	
end;

begin
	
	calculator: PlusMinus port map(op1, op2, '0', SumEnable, result);
	sold: Mem_Ram_SOLD port map(account_address, card_dataIn, card_dataOut, card_write);
	cash: Mem_Ram_Bancomat port map(cash_address, cash_in, cash_out, cash_write);
	
	
	deposit: process(submit)
	begin
		if(enable = '1') then
			if(card_write = '1') then card_write <= '0';	 --reset card write
			end if;	
		
			if(cash_write = '1') then cash_write <= '0';	 --reset cash register write
			end if;
		
			if(SumEnable = '0') then SumEnable <= '1';				 --reset sumatorScazator enable
			end if;
		
			gata <= num(0) and num(2);
		
			if(conv_integer(num) < 5 and submit = '1') then
				cash_address <= num;
				cash_in <= cash_out + money;
				cash_write <= '1';
			
				case num is
					when "000" => temp <= vectorize(conv_integer(money) * 500); --500
					when "001" => temp <= vectorize(conv_integer(money) * 200); --200
					when "010" => temp <= vectorize(conv_integer(money) * 100); --100
					when "011" => temp <= vectorize(conv_integer(money) * 50);  --50
					when "100" => temp <= vectorize(conv_integer(money) * 10); --10 
					when others => null;
				end case;
			
				op1 <= card_dataOut;
				op2 <= temp;
				SumEnable <= '0';
				card_dataIn <= result;
				card_write <= '1';
			
				num <= num + 1;	   
			
			end if;
		else null;
		end if;
	end process;

end depunere;
