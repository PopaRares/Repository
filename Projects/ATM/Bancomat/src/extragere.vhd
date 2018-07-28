library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.NUMERIC_STD.all;

entity extragere is	
	port(Adr: in Std_logic_vector(3 downto 0);
		 digit: in std_logic_vector(3 downto 0);
	 	 Set:in Std_logic;
		 Enable: in Std_logic;
		 --Extras: out Std_logic_vector(15 downto 0);
		 Chitanta_out: out Std_logic;
		 success: out std_logic;
		 error: out std_logic;
		 done: out Std_logic);
		 
end extragere;

architecture arh of extragere is

component Mem_RAM_SOLD is
	port(ADDRESS: in Std_logic_vector(3 downto 0);
	     DATAIN: in STD_LOGIC_VEctor(15 downto 0);
		 DATAOUT: out STd_logic_vector(15 downto 0);
		 WE: in STD_LOGIC);
end component;

component Mem_Ram_Bancomat is
	port(Address: in Std_logic_vector(2 downto 0);
		 DataIn: in Std_logic_vector(7 downto 0);
		 DataOut: out Std_logic_vector(7 downto 0);
		 WE: in Std_logic);
end component;	  

component PlusMinus is
	port(A,B:in STD_LOGIC_VECTOR(15 DOWNTO 0);-- A > B
		 operation: in STD_LOGIC;
		 done: in STD_LOGIC;
		 Rez:out STD_LOGIC_VECTOR(15 DOWNTO 0));
end component;

component Demux_chitanta is  
	port(S:in Std_logic;
		 En:in Std_logic:='0';
		 Data:out Std_logic:='0');
end component;

component comparator is
	port( Enable: in Std_logic;
		  Suma_utilizator: in Std_logic_vector(15 downto 0);
		  adresa_card: in std_logic_vector(3 downto 0);
		  Validation: out Std_logic := '1';
		  done : out std_logic := '0';
		  nr_coins: out std_logic_vector(19 downto 0));
end component; 

component PIN_read is
	port(
		PIN: in STD_LOGIC_VECTOR (3 downto 0);--number input
		button: in STD_LOGIC;
		reset: in STD_LOGIC;
		complete: out STD_LOGIC;
		PIN_code: out STD_LOGIC_VECTOR (15 downto 0);
		ceva_numar_idk: out integer
		);
end component;

signal card_in: std_logic_vector(15 downto 0) := (others => '0');								--sold card
signal card_out: std_logic_vector(15 downto 0);		
signal card_write: std_logic := '0';		

signal cash_address: std_logic_vector(2 downto 0) := "000";
signal cash_in: std_logic_vector (7 downto 0) := (others => '0');
signal cash_out: std_logic_vector(7 downto 0);				 								 --cash register
signal cash_write: std_logic := '0';

signal op_A, op_B: std_logic_vector(15 downto 0) := (others => '0');
signal op_enable: std_logic := '1';	 -- activ 0
signal op_rez: std_logic_vector(15 downto 0);												--scazator

signal comp_enable: std_logic := '0';
signal comp_valid: std_logic;
signal comp_done: std_logic;															 --comparator
signal comp_coin_list: std_logic_vector(19 downto 0) := (others => '0');

signal sum_reset: std_logic := '1';
signal sum_done: std_logic := '0';
signal sum_code: std_logic_vector(15 downto 0);											--sum read



signal sum: std_logic_vector(15 downto 0) := (others => '0');
signal reg_addr: std_logic_vector(2 downto 0) := "000";
signal test_env: std_logic := '1';
signal receipt_set: std_logic := '0';
signal account_done: std_logic  := '0';
signal register_done: std_logic := '0';
signal test: integer;

--signal Chitanta: Std_logic;
begin
	card: Mem_RAM_sold port map(Adr, card_in, card_out, card_write);
	cash: Mem_RAM_bancomat port map(cash_address, cash_in, cash_out, cash_write);
	op: PlusMinus port map (op_A, op_B, '1', op_enable, card_in);
	sum_input: PIN_read port map (digit, set, sum_reset, sum_done, sum_code, test);
	exchange_validation: comparator port map(comp_enable, sum, adr, comp_valid, comp_done, comp_coin_list);
	
	
	rest: process (enable)
	begin
		if(enable = '0') then
			account_done <= '0';
			register_done <= '0';
		else null;
		end if;
	end process;
	
	citire_suma: process(set, digit, sum_done, enable)
	begin		
		if(sum_reset = '1' and enable = '1') then sum_reset <= '0';	
		else null;
		end if;
		
		if(sum_done = '0' and set = '1' and enable = '1') then  
			null;
		else sum <= sum_code;
		end if;
	end process;
	
	withdraw_validation: process(sum_done, enable, comp_valid, comp_done)
	begin		
		if(sum_done = '1' and enable = '1') then
			comp_enable <= '1';
		else null;
		end if;	 
		
		if(comp_done = '1') then
			if(comp_valid = '0') then 
				error <= '1';
				success <= '0';
			else 
				error <= '0';
				success <= '1';	
			end if;
		else null;
		end if;
	end process;
	
	chitanta: process(set, comp_done, enable)
	begin
		if(receipt_set = '0'and set = '1' and comp_done = '1' and enable = '1') then
			receipt_set <= '1';
			chitanta_out <= digit(0);
		else null;
		end if;
	end process;
	
	withdraw_account: process(receipt_set, enable, account_done)
	begin	 
		if(account_done = '1') then card_write <= '0';
		else null;
		end if;
		
		if(enable = '1' and receipt_set = '1' and account_done = '0') then
			op_A <= card_out;
			op_B <= sum;
			op_enable <= '0';
			card_write <= '1';
			account_done <= '1';
		end if;
	end process;
	
	withdraw_register: process(receipt_set, enable, reg_addr, register_done) 
	variable adresa: std_logic_vector(2 downto 0) := "000";
	variable calcul: std_logic_vector(7 downto 0);
	begin		
		if(enable = '1' and receipt_set = '1' and register_done = '0' and sum_done = '1') then	
			
			if(reg_addr = "101") then
				register_done <= '1';
			else
			
			if(cash_write ='1') then cash_write <= '0';
			end if;
			
			adresa := reg_addr;
			cash_address <= adresa;
			calcul := cash_out - comp_coin_list(conv_integer(reg_addr) * 4 + 3 downto conv_integer(reg_addr) * 4 + 0);
			cash_in <= calcul;
			reg_addr <= reg_addr + 1;
			cash_write <= '1';
			
			end if;
		else reg_addr <= "000";
		end if;
	end process;
	
	done <= account_done and register_done;
	
end arh;
