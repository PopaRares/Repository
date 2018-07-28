library ieee;
use ieee.std_logic_1164.all;


entity UC is
	port(Clk: in Std_logic:='0';
		 Reset: in Std_logic:='0';
		 Button_ok:in Std_logic:='0';	 --input_card button 
		 input_card:in Std_logic:='0';
		 Buttons_Digit:in Std_logic_vector(3 downto 0):="0000";
		 sel_Suma: in Std_logic_vector(1 downto 0):="00";
		 sel_Actiune: in Std_logic_vector(1 downto 0):="00";
		 sel_chitanta: in Std_logic:='0'; 
		 Button_Act:in Std_logic:='0';
		 Chitanta: out Std_logic:='0';
		 Led_out:out Std_logic_vector(6 downto 0):="0000000";
		 Card_out:out Std_logic:='0');
	
end UC;

architecture UC of UC is

component debouncer is
  	generic(DB_size:INTEGER := 19); --10.5ms pe ceas de 50mHz
  	port(
    	CLK: in  STD_LOGIC;  
    	input: in STD_LOGIC;
    	debounced: out STD_LOGIC); 
end component;
------
component card_id is
	port(
		adresa_card: in STD_LOGIC_VECTOR(3 downto 0);
		input_card: in STD_LOGIC;
		reset:in Std_logic:='0';
		card_num: out INTEGER range 0 to 15
		);
end component;

component Mem_ROM_PIN is
	port(ADR: in Integer;
		 CS: in Std_logic;												   -------- Pentru intrat in cont
		 DATA: out std_logic_vector(15 downto 0)
		 );
end component; 

component PIN_read is
	port(
		PIN: in STD_LOGIC_VECTOR (3 downto 0);--number input
		button: in STD_LOGIC;
		reset: in STD_LOGIC;
		complete: out STD_LOGIC:='0';
		PIN_code: out STD_LOGIC_VECTOR (15 downto 0)
		);
		
end component;

component comp_card is	
	port(Adresa_Pin,Pin_introdus:in Std_logic_vector(15 downto 0);
		 En: in Std_logic:='0';
		 Validation:out Std_logic:='0');
end component;
-------	
component Mem_RAM_SOLD is
	port(ADDRESS: in Std_logic_vector(3 downto 0);
	     DATAIN: in STD_LOGIC_VEctor(15 downto 0);
		 DATAOUT: out STd_logic_vector(15 downto 0);
		 WE: in STD_LOGIC);
end component; 

component Mem_Ram_Bancomat is
	port(Address: in Std_logic_vector(2 downto 0);
		 DataIn: in Std_logic_vector(7 downto 0);					   -------date bancomat-utilizator
		 DataOut: out Std_logic_vector(7 downto 0);
		 WE: in Std_logic);
end component;

component Mem_Suma_Total is
	port(DataIn: in Std_logic_vector(15 downto 0);
		 WE: in STd_logic;
		 DataOut: out Std_logic_vector(15 downto 0));
end component;
-----------	
component decision is
	port(S:in Std_logic_vector(1 downto 0);
		 Data:in Std_logic:='0';
		 Enable:in Std_logic;
		 Act: out Std_logic_vector(3 downto 0));
end component;

component extragere is	
	port(Extras: out Std_logic_vector(15 downto 0);
		 Chitanta: out Std_logic;
		 Terminat: out Std_logic;
		 Enable: in Std_logic;
		 Suma: in Std_logic_vector(15 downto 0);
		 Adr: in Std_logic_vector(3 downto 0);
		 Rst: in Std_logic;
		 Set:in Std_logic);	
end component;

component extragere_card is
	port(Extrag_Bani,Vizual_Sold,Return_card,Depunere: in Std_logic:='0';
		 Termin: in Std_logic:='0';
		 Done: out std_logic:='0');
end component;	 															 --------actiunile

component depunere is
	port(money : in std_logic_vector(3 downto 0);
		 submit : in std_logic;
		 enable : in std_logic;
		 account_address : in Integer range 0 to 15;
		 gata : out std_logic:='0');
end component;	

component vizualizare_sold is
	port(Addr:in Integer range 0 to 15;
	     Enable: in std_logic;
		 inRetragere:in std_logic:='0';
		 outRetragere:out std_logic:='0';
		 Suma: out std_logic_vector(15 downto 0));
end component;

----------------- 
--

component screen is
	port(
		number:in std_logic_vector(15 downto 0);
		clk: in STD_LOGIC;
		clear: in STD_LOGIC;
		LED_out: out STD_LOGIC_VECTOR(6 downto 0);
		anode: out STD_LOGIC_VECTOR(3 downto 0)	 --pentru selectarea unui singur afisaj (active pe 0)
		);
end component;	         

-- 
signal intReset: Std_logic:='0';
signal intButton_ok: Std_logic:='0';
signal intSel_Suma: Std_logic_vector(1 downto 0):="00";
signal intSel_Actiun:Std_logic_vector(1 downto 0):="00";
signal intSel_Chitanta:Std_logic:='0';

signal intCard_num: Integer range 0 to 15; 
signal intPin_rom:Std_logic_vector(15 downto 0);
signal intPin_read:Std_Logic_vector(15 downto 0):="0000000000000000";
signal intButtons_digit: Std_Logic_vector(3 downto 0);
signal intcard_input:Std_logic:='0';	
signal intComplete: Std_logic:='0';

signal intValidation_Card:Std_logic:='0';
signal intAct:Std_logic_vector(3 downto 0):="0000";
signal intDone_depunere:Std_logic:='0';
signal intTermin:Std_logic:='0';	
signal intExtragere_card:Std_logic:='0';
signal intSuma_Vizual_sold: Std_logic_vector(15 downto 0);
signal retragere_Vizual: Std_logic:='0';  
signal IntButton_Act:Std_logic:='0';

begin

	--DB_Reset: debouncer port map (Clk,Reset, intReset);
	intReset<=Reset;
	--DB_Button: debouncer port map(Clk,Button_ok,intButton_ok);
	intButton_ok<=Button_ok;  
	intCard_input<=Input_card; 
	intButton_act<=Button_act;
	--DB_Buttons_digit_0: debouncer port map(Clk,Buttons_digit(0),intButtons_digit(0));
	--DB_Buttons_digit_1: debouncer port map(Clk,Buttons_digit(1),intButtons_digit(1));				--Deboucers
	--DB_Buttons_digit_2: debouncer port map(Clk,Buttons_digit(2),intButtons_digit(2));
	--DB_Buttons_digit_3: debouncer port map(Clk,Buttons_digit(3),intButtons_digit(3));	
	  intButtons_digit<=Buttons_digit;
	--DB_Sel_Suma_0: debouncer port map(Clk,Sel_suma(0),intSel_Suma(0));	
	--DB_Sel_Suma_1: debouncer port map(Clk,Sel_suma(1),intSel_Suma(1));
	  intSel_Suma<=Sel_Suma;
	--DB_Sel_Actiune_0: debouncer port map(Clk,Sel_Actiune(0),intSel_Actiune(0));
	--DB_Sel_Actiune_1: debouncer port map(Clk,Sel_Actiune(1),intSel_Actiune(1));
	  intSel_Actiun<=Sel_Actiune;
	--DB_Sel_Chitanta: debouncer port map(Clk,Sel_Chitanta,intSel_Chitanta);
	intSel_Chitanta<=Sel_Chitanta;

	------------
	CD_ID: card_id port map (intButtons_Digit,intcard_input,intReset,intCard_Num);
	M_PIN: mem_rom_pin port map(intCard_num,intButton_ok,intPin_Rom);
	R_PIN: Pin_read port map(intButtons_Digit,intButton_ok,intReset,intComplete,intPin_read);
	Comp1: comp_card port map(intPin_Rom,intPin_Read,intComplete,intValidation_Card);----Introducere card
	------------
	
	DEC: decision port map(intSel_Actiun,intValidation_Card,intButton_act,intAct);
	Ac1: --intTermin<=intAct(0)or intDone_Depunere or Retragere_vizual;
		 intExtragere_card<=intAct(0) or intDone_Depunere or  Retragere_vizual;
	Ac2: vizualizare_sold port map(intCard_Num,intAct(1),intButton_ok,Retragere_vizual,intSuma_vizual_sold);
	--Ac3: extragere port map();
	Ac4: depunere port map(intButtons_Digit,intButton_ok,intAct(3),intCard_Num,intDone_depunere);
	----Decizie
	
	card_Out<=intExtragere_card and (not intcard_input) ;
	
	------------
end UC;
