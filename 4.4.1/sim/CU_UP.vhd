library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;
use work.constants.all;

entity CU_UP is
    generic (
		-- default values from the myTypes package
        opcode_size : integer := OP_CODE_SIZE;  -- number of bits for the opcode field
		func_size : integer := FUNC_SIZE;  -- number of bits for the function field
		control_word_size : integer := CTRL_WORD_SIZE;  -- number of bits for the control word driven as output
        Nentries_MicrocodeROM : integer := 259  -- number of entries in the microcode ROM
    );
    port (
        Clk : in std_logic; -- Clock signal
        Rst : in std_logic; -- Reset signal for the internal uPC
        En : in std_logic;  -- Enable signal

        opcode : in std_logic_vector(opcode_size-1 downto 0);  -- opcode field  
		func : in std_logic_vector(func_size-1 downto 0);	-- func field 
        control_word : out std_logic_vector(control_word_size-1 downto 0)   -- the control word is a vector of bits, each mapped with one constol signal as follow
 
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
end entity;


architecture ARCHSTRUCT of CU_UP is

    -- microcode memory storing the control words for each instruction and for each stage of the pipeline
    component MicrocodeROM is
        generic (
            -- default values defined in myTypes.vhd
            opcode_bits : integer := OP_CODE_SIZE;
            func_bits : integer := FUNC_SIZE;
            control_word_size : integer := CTRL_WORD_SIZE;
            Nentries : integer := 259  -- it must be equal to the biggest func&opcode value + 2
        );
        port (
            Clk : in std_logic;  -- Clock signal
            En : in std_logic;  -- enable signal
    
            Addr1 : in std_logic_vector(opcode_bits+func_bits-1 downto 0);  -- address signal
            Out1 : out std_logic_vector(control_word_size-1 downto 0)  -- ROM output
        );
    end component;


    -- up counter for scanning the 3 control words of the instruction in execution
    component UpCntN is
        generic(
            N : integer := Nbit_UpCnt;
            maxVal : integer := MaxVal_UpCnt
        );
        port (
            Clk : in std_logic;
            Rst : in std_logic;
            cnt : in std_logic;
            Out_cnt : out std_logic_vector(N-1 downto 0);
            TC : out std_logic
        );
    end component;


    -- Adder for adding the uPC with the counter
    component RCA is
        generic (
            N 	: integer 	:= Nbit_RCA
        );
        port(
            A 	: 	in 		std_logic_vector(N-1 downto 0);
            B 	: 	in 		std_logic_vector(N-1 downto 0);
            Ci 	: 	in 		std_logic;
            S 	: 	out 	std_logic_vector(N-1 downto 0);
            Co 	: 	out 	std_logic
        );
    end component;

	-- register for delaying the counter by one clock cycle
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

	-- multiplexer for masking the output in case of reset signal high
    component muxN1 is
        generic (N : integer := Nbit_MUXN1);
        port(
            A : 	in 		std_logic_vector(N-1 downto 0);	-- input A
            B : 	in 		std_logic_vector(N-1 downto 0);	-- input B
            S : 	in 		std_logic;						-- selection signal
            Y : 	out 	std_logic_vector(N-1 downto 0)	-- output
        );
    end component;

    -- internal signals
	signal out_cnt_addr, out_counter, in_concat : std_logic_vector(opcode_size+func_size-1 downto 0);
	signal out_microcode_mem : std_logic_vector(control_word_size-1 downto 0);
	signal cnt_counter_in, en_in_reg : std_logic_vector(1 downto 0);


    begin

	in_concat <= func & opcode;  -- concatenation of the func and opcode field

    -- microcode ROM
    microcodeMemory : MicrocodeROM
        generic map(
            opcode_bits => opcode_size,
            func_bits => func_size,
            control_word_size => control_word_size,
            Nentries => Nentries_MicrocodeROM
        )
        port map(
            Clk => Clk,
            En => En,
            Addr1 => out_cnt_addr,
            Out1 => out_microcode_mem
        );


    -- counter for scan the control words from stage 1 to stage 3 
    -- of the given intruction 
    counterScan : UpCntN
        generic map(
            N => opcode_size + func_size,
            maxVal => 2 -- counter that has to count up to 2 (0, 1, 2)
        )
        port map(
            Clk => Clk,
            Rst => Rst,
            cnt => cnt_counter_in(0),
            Out_cnt => out_counter,
            TC => open
        );

	en_in_reg <= "0" & En;  -- internal enable signal for driving the register

	-- this register allows to delay the enable signal of the
	-- counter by 1 clock cycle, allowing therefore to start counting from 0
	-- as soon as we receive the first opcode and func bits 
	regCntSignal : RegN
        generic map(
            N => 2  -- size is 2 instead of 1 to avoid miss matching between std_logic and std_logic_vector
        )
        port map(
            Clk => Clk,  -- clock signal
            Rst => Rst,  -- reset signal
            en => En,  -- external enable signal
            Out_reg => cnt_counter_in,  -- enable signal delayed by 1 clock cycle
            In_reg => en_in_reg  -- external enable signal that has to be delayed
        );


	-- multiplexer for masking the output, driving zero in case of reset signal high 
    mux_masc_out : muxN1
        generic map(
            N => control_word_size
        )
        port map(
            A => (others => '0'),  -- zero output in case of Rst = 1
            B => out_microcode_mem,  -- other input is the output of the microcode memory
            S => Rst,  -- selection signal is Rst
            Y => control_word  
        );


    -- adder which adds the func and opcode field with the current output of the
	-- counter. This allows to send all the signals to all three stages with the 
	-- proper timing. Thus the control word is splitted in 3 control words per each 
	-- stage, stored contiguously in the microcode rom. The adder therefore allows to scan
	-- all these three control words
    adder : RCA 
        generic map(
            N => opcode_size + func_size  -- size equal to the uPC width
        )
        port map(
            A => in_concat,  -- func and opcode fields
            B => out_counter,  -- counter status
            Ci => '0',  -- not needed
            S => out_cnt_addr,  -- final address driven to the memory
            Co => open  -- not needed
        );

end architecture;

configuration CFG_CU_UP of CU_UP is
for ARCHSTRUCT
    for all : MicrocodeROM 
        use configuration work.CFG_MICROCODEROM_ARCHBEH;
    end for;

    for all : UpCntN 
        use configuration work.CFG_ARCHSTRUCT_UPCNT;
    end for;

    for all : RCA 
        use configuration work.CFG_RCA_ARCHSTRUCT;
    end for;

    for all : RegN 
        use configuration work.CFG_ARCHBEH_REGN;
    end for;

    for all : muxN1 
        use configuration work.CFG_MUXN1_ARCHSTRUCT;
    end for;
end for;
end configuration;
