library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity tb_CU_FSM is
end entity;

architecture tb of tb_CU_FSM is

    constant opcode_size : integer := 6;
    constant func_size : integer := 11;
    constant control_word_size : integer := 13;
    constant number_of_instructions : integer := 18;

    component CU_FSM is
        generic (
            opcode_size : integer := OP_CODE_SIZE;  -- number of bits for the opcode field
            func_size : integer := FUNC_SIZE;  -- number of bits for the function field
            control_word_size : integer := CTRL_WORD_SIZE  -- number of bits for the control word driven as output
        );
        port (
            opcode : in std_logic_vector(opcode_size-1 downto 0);  -- opcode field  
            func : in std_logic_vector(func_size-1 downto 0);	-- func field  
            Clk : in std_logic;	 -- clock signal
            Rst : in std_logic;	 -- reset signal
    
            -- output control word
            control_word : out std_logic_vector(control_word_size-1 downto 0)   -- the control word is a vector of bits, each mapped with one constol signal as follow
        );
    end component;

    -- test signals definition
    signal opcode_s : std_logic_vector(opcode_size-1 downto 0);
    signal func_s : std_logic_vector(func_size-1 downto 0);
    signal Clk_s, Rst_s : std_logic;
    signal control_word_s, correct_word : std_logic_vector(control_word_size-1 downto 0);
    signal err : std_logic;  -- signal high if the CU's output is different than the golden component's ouput


--        "1110100100001"  -- ADD       
--        "1110101100001"  -- SUB        
--        "1110110100001"  -- AND      
--        "1110111100001"  -- OR       
--        "0111100100001"  -- ADDI1      
--        "0111101100001"  -- SUBI1     
--        "0110110100001"  -- ANDI1    
--        "0110111100001"  -- ORI1     
--        "1010000100001"  -- ADDI2      
--        "1010001100001"  -- SUBI2      
--        "1010010100001"  -- ANDI2     
--        "1010011100001"  -- ORI2       
--        "1010000100001"  -- MOV        
--        "0111100100001"  -- S_REG1    
--        "1010000100001"  -- S_REG2     
--        "1110000101100"  -- S_MEM      
--        "0111100110111"  -- L_MEM1     
--        "1010000110111"  -- L_MEM2


begin

    DUT : CU_FSM 
            generic map(
                opcode_size => opcode_size,
                func_size => func_size,
                control_word_size => control_word_size
            )
            port map(
                opcode => opcode_s,  
                func => func_s, 
                Clk => Clk_s,
                Rst => Rst_s,
                control_word => control_word_s
            );

    -- clock process
    process
    begin
        Clk_s <= '0';
        wait for 10 ns;
        Clk_s <= '1';
        wait for 10 ns;
    end process;

    -- test process
    process
    begin
		opcode_s <= (others => '0');
        func_s <= (others => '0');

        -- reset the fsm
        Rst_s <= '1';
        wait for 20 ns;
        Rst_s <= '0';
		wait for 10 ns;

        -- Starting feeding the CU_FSM with operations

--  ================ ADD ===========================
        opcode_s <= RTYPE_OPCODE;
        func_s <= RTYPE_FUNC_ADD;
        wait for 60 ns;

--  ================ SUB ===========================
        opcode_s <= RTYPE_OPCODE;
        func_s <= RTYPE_FUNC_SUB;
        -- Check Stage 1
        wait for 60 ns;

--  ================ OR ============================
        opcode_s <= RTYPE_OPCODE;
        func_s <= RTYPE_FUNC_OR;
        wait for 60 ns;

--  ================ AND ===========================
        opcode_s <= RTYPE_OPCODE;
        func_s <= RTYPE_FUNC_AND;
        wait for 60 ns;

--  ================ NOP ===========================
        opcode_s <= RTYPE_OPCODE;
        func_s <= NOP;
        wait for 60 ns;

        -- the function field is not needed anymore for I-Type instructions
        func_s <= (others => '0');

        -- the function field is not needed anymore for I-Type instructions
        func_s <= (others => '0');

        
--  ================ ADDI1 ===========================
        opcode_s <= ITYPE_OPCODE_ADDI1;
        wait for 60 ns;

--  ================ SUBI1 ===========================
        opcode_s <= ITYPE_OPCODE_SUBI1;
        wait for 60 ns;

--  ================ ANDI1 ===========================
        opcode_s <= ITYPE_OPCODE_ANDI1;
        wait for 60 ns;

--  ================ ORI1 ============================
        opcode_s <= ITYPE_OPCODE_ORI1;
        wait for 60 ns;

--  ================ ADDI2 ===========================
        opcode_s <= ITYPE_OPCODE_ADDI2;
        wait for 60 ns;

--  ================ SUBI2 ===========================
        opcode_s <= ITYPE_OPCODE_SUBI2;
        wait for 60 ns;

--  ================ ANDI2 ===========================
        opcode_s <= ITYPE_OPCODE_ANDI2;
        wait for 60 ns;

--  ================ ORI2 ============================
        opcode_s <= ITYPE_OPCODE_ORI2;
        wait for 60 ns;

--  ================ MOV =============================
        opcode_s <= ITYPE_OPCODE_MOV;
        wait for 60 ns;

--  ================ S_REG1 ==========================
        opcode_s <= ITYPE_OPCODE_S_REG1;
        wait for 60 ns;

--  ================ S_REG2 ==========================
        opcode_s <= ITYPE_OPCODE_S_REG2;
        wait for 60 ns;

--  ================ S_MEM =============================
        opcode_s <= ITYPE_OPCODE_S_MEM;
        wait for 60 ns;

--  ================ L_MEM1 ============================
        opcode_s <= ITYPE_OPCODE_L_MEM1;
        wait for 60 ns;

--  ================ L_MEM2 ============================
        opcode_s <= ITYPE_OPCODE_L_MEM2;
        wait for 60 ns;

--  ==================================================
	
	Rst_s <= '1';  -- end testing the CU
    wait;
    end process;


    -- process for the golden component
    process
    begin
		correct_word <= (others => '0');

        wait for 30 ns;
        -- ADD check
        correct_word <= "1110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000100100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- SUB check
        correct_word <= "1110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000101100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- OR check
        correct_word <= "1110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000111100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- AND check
        correct_word <= "1110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000110100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- NOP check
        correct_word <= "0000000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000000000000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000000";  -- check stage 3
		wait for 20 ns;

        -- ADDI1 check
        correct_word <= "0110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0001100100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- SUBI1 check
        correct_word <= "0110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0001101100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- ANDI1 check
        correct_word <= "0110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000110100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- ORI1 check
        correct_word <= "0110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000111100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- ADDI2 check
        correct_word <= "1010000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000000100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- SUBI2 check
        correct_word <= "1010000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000001100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- ANDI2 check
        correct_word <= "1010000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000010100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- ORI2 check
        correct_word <= "1010000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000011100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- MOV check
        correct_word <= "1010000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000000100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- S_REG1 check
        correct_word <= "0110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0001100100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- S_REG2 check
        correct_word <= "1010000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000000100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000000001";  -- check stage 3
        wait for 20 ns;

        -- S_MEM check
        correct_word <= "1110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000000100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000001100";  -- check stage 3
        wait for 20 ns;

        -- L_MEM1 check
        correct_word <= "0110000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0001100100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000010111";  -- check stage 3
        wait for 20 ns;

        -- L_MEM2 check
        correct_word <= "1010000000000";  -- check stage 1
        wait for 20 ns;
        correct_word <= "0000000100000";  -- check stage 2
        wait for 20 ns;
        correct_word <= "0000000010111";  -- check stage 3
		wait for 20 ns;

		correct_word <= (others => '0');

		wait;
    end process;
    

    -- process that compares the output of the CU and
    -- the output of the golden component 
    process (correct_word, control_word_s)
    begin
	if (correct_word /= control_word_s) then
	        err <= '1';  -- error
	else
		err <= '0';  -- no error
	end if;
    end process;

	process(Clk_s)
	begin
		if (falling_edge(Clk_s)) then
			assert correct_word = control_word_s report "Error control word generated";
		end if;
	end process;


end architecture;

configuration CFG_TB_CU_FSM of tb_CU_FSM is
for tb
	for all : CU_FSM
		use configuration work.CFG_CU_FSM_BEH;
	end for;
end for;
end configuration;
