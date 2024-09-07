library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;
use work.constants.all;

entity CU_HW is
	generic (
		-- default values defined into myTypes package
		opcode_bits : integer := op_code_size;  -- number of bits for the opcode field
		func_bits : integer := func_size;  -- number of bits for the function field
		control_word_bits : integer := CTRL_WORD_SIZE  -- number of bits for the control word
	);
	port (
		Clk : in std_logic;  -- clock signal
		Rst : in std_logic;  -- reset signal
		En : in std_logic;  -- enable signal

		opcode : in std_logic_vector(opcode_bits-1 downto 0);  -- opcode field
		func : in std_logic_vector(func_bits-1 downto 0);  -- opcode field
		control_word : out std_logic_vector(control_word_bits-1 downto 0)  -- control word driven as output

		-- for the CU implementation the following mapping for the control word has been defined
		-----------------------------------------
		-- |	control_word[0]		|	RF1		|
		-- |	control_word[1] 	| 	RF2	 	|
		-- |	control_word[2] 	|	EN1		|
		-- |	control_word[3] 	|	S1		|
		-- |	control_word[4] 	|	S2		|
		-- |	control_word[5] 	|	ALU1	|	
		-- |	control_word[6] 	|	ALU2	|
		-- |	control_word[7] 	|	EN2		|
		-- |	control_word[8] 	|	RM		|
		-- |	control_word[9] 	|	WM		|
		-- |	control_word[10] 	|	EN3		|
		-- |	control_word[11] 	|	S3		|
		-- |	control_word[12] 	|	WF1		|
		-----------------------------------------
	);
end entity;

architecture ARCHSTRUCT of CU_HW is

	-- Look Up Table for the control words
	component LUT_CU is
		generic (
			-- default value defined into myTypes package
			control_word_bits : integer := CTRL_WORD_SIZE  -- number of bits for the control word
		);
		port (
			-- for the LUT the size of inputs must be a constant, thus change is directly from the myTypes package
			opcode : in std_logic_vector(op_code_size-1 downto 0);  -- opcode field
			func : in std_logic_vector(func_size-1 downto 0);  -- func field
			En : in std_logic;  -- enable signal
			control_word : out std_logic_vector(control_word_bits-1 downto 0)  -- control word driven as output

			-- for the CU implementation the following mapping for the control word has been defined
			-----------------------------------------
			-- |	control_word[0]		|	WF1		|
			-- |	control_word[1] 	| 	S3	 	|
			-- |	control_word[2] 	|	EN3		|
			-- |	control_word[3] 	|	WM		|
			-- |	control_word[4] 	|	RM		|
			-- |	control_word[5] 	|	EN2		|	
			-- |	control_word[6] 	|	ALU2	|
			-- |	control_word[7] 	|	ALU1	|
			-- |	control_word[8] 	|	S2		|
			-- |	control_word[9] 	|	S1		|
			-- |	control_word[10] 	|	EN1		|
			-- |	control_word[11] 	|	RF2		|
			-- |	control_word[12] 	|	RF1		|
			-----------------------------------------
		);
	end component;

	-- register for pipelining 
	component RegN is
		generic(
			N : integer := Nbit_Reg	-- register width
		);
		port (
			Clk : in std_logic;	-- clock signal
			Rst : in std_logic;	-- reset signal
			en : in std_logic;	-- enable signal
			Out_reg : out std_logic_vector(N-1 downto 0); -- output
			In_reg : in std_logic_vector(N-1 downto 0)		-- input
		);
	end component;

	-- internal signals
	signal ctrl_word : std_logic_vector(control_word_bits-1 downto 0);
	signal out_reg_2 : std_logic_vector(control_word_bits-3-1 downto 0);
	signal out_reg_3 : std_logic_vector(control_word_bits-3-5-1 downto 0);

begin

	-- LUT for the control word generation
	LUT_control_unit : LUT_CU
		generic map(
			control_word_bits => control_word_bits  -- control word sizing
		)
		port map(
			opcode => opcode,  -- opcode field
			func => func,  -- func field
			En => En,
			control_word => ctrl_word  -- internal signal for the control word
		);

	-- driving control signals to the first stage
	control_word(control_word_bits-1 downto 10) <= ctrl_word(control_word_bits-1 downto 10);

	-- reg for stage 2
	reg_stg_2 : RegN
		generic map(
			N => control_word_bits-3  -- driving all the control signal except the 3 of the stage 1
		)
		port map(
			Clk => Clk,
			Rst => Rst,
			en => En,
			Out_reg => out_reg_2,
			In_reg => ctrl_word(control_word_bits-3-1 downto 0)
		);

	control_word(9 downto 5) <= out_reg_2(control_word_bits-3-1 downto 5);  -- second stage driving 


	-- reg for stage 3
	reg_stg_3 : RegN
		generic map(
			N => control_word_bits-3-5  -- driving all the control signal except the 3 of the stage 1 and 5 of stage 2
		)
		port map(
			Clk => Clk,
			Rst => Rst,
			en => En,
			Out_reg => out_reg_3,
			In_reg => out_reg_2(control_word_bits-3-5-1 downto 0)
		);

	control_word(4 downto 0) <= out_reg_3;  -- third stage driving

end architecture;

configuration CFG_CU_HW_ARCHSTRUCT of CU_HW is
for ARCHSTRUCT
	for all : RegN
		use configuration work.CFG_ARCHBEH_REGN;
	end for;

	for all : LUT_CU
		use configuration work.CFG_LUT_CU_ARCHBEH;
	end for;
end for;
end configuration;
