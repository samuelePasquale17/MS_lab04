library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity tb_CU_HW is
end entity;

architecture tb of tb_CU_HW is

    constant opcode_size : integer := 6;
    constant func_size : integer := 11;
    constant control_word_size : integer := 13;
    constant number_of_instructions : integer := 18;



    -- test signals definition
    signal opcode_s : std_logic_vector(opcode_size-1 downto 0);
    signal func_s : std_logic_vector(func_size-1 downto 0);
    signal Clk_s, Rst_s, En_s : std_logic;
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

        component CU_HW is
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
                );
        end component;
begin

    DUT : CU_HW
            generic map(
				opcode_bits => opcode_size,
                func_bits => func_size,
                control_word_bits => control_word_size
            )
            port map(
                Clk => Clk_s,
                Rst => Rst_s,
                En => En_s,
                opcode => opcode_s,  
                func => func_s, 
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

        En_s <= '0';

        -- reset the CU
        Rst_s <= '1';
        wait for 20 ns;
        En_s <= '1';
        Rst_s <= '0';
	wait for 10 ns;

        -- Starting feeding the CU_HW with operations

--  ================ ADD ===========================
        opcode_s <= RTYPE_OPCODE;
        func_s <= RTYPE_FUNC_ADD;
        wait for 20 ns;

--  ================ SUB ===========================
        opcode_s <= RTYPE_OPCODE;
        func_s <= RTYPE_FUNC_SUB;
        -- Check Stage 1
        wait for 20 ns;

--  ================ OR ============================
        opcode_s <= RTYPE_OPCODE;
        func_s <= RTYPE_FUNC_OR;
        wait for 20 ns;

--  ================ AND ===========================
        opcode_s <= RTYPE_OPCODE;
        func_s <= RTYPE_FUNC_AND;
        wait for 20 ns;

--  ================ NOP ===========================
        opcode_s <= RTYPE_OPCODE;
        func_s <= NOP;
        wait for 20 ns;

        -- the function field is not needed anymore for I-Type instructions
        func_s <= (others => '0');

        -- the function field is not needed anymore for I-Type instructions
        func_s <= (others => '0');

        
--  ================ ADDI1 ===========================
        opcode_s <= ITYPE_OPCODE_ADDI1;
        wait for 20 ns;

--  ================ SUBI1 ===========================
        opcode_s <= ITYPE_OPCODE_SUBI1;
        wait for 20 ns;

--  ================ ANDI1 ===========================
        opcode_s <= ITYPE_OPCODE_ANDI1;
        wait for 20 ns;

--  ================ ORI1 ============================
        opcode_s <= ITYPE_OPCODE_ORI1;
        wait for 20 ns;

--  ================ ADDI2 ===========================
        opcode_s <= ITYPE_OPCODE_ADDI2;
        wait for 20 ns;

--  ================ SUBI2 ===========================
        opcode_s <= ITYPE_OPCODE_SUBI2;
        wait for 20 ns;

--  ================ ANDI2 ===========================
        opcode_s <= ITYPE_OPCODE_ANDI2;
        wait for 20 ns;

--  ================ ORI2 ============================
        opcode_s <= ITYPE_OPCODE_ORI2;
        wait for 20 ns;

--  ================ MOV =============================
        opcode_s <= ITYPE_OPCODE_MOV;
        wait for 20 ns;

--  ================ S_REG1 ==========================
        opcode_s <= ITYPE_OPCODE_S_REG1;
        wait for 20 ns;

--  ================ S_REG2 ==========================
        opcode_s <= ITYPE_OPCODE_S_REG2;
        wait for 20 ns;

--  ================ S_MEM =============================
        opcode_s <= ITYPE_OPCODE_S_MEM;
        wait for 20 ns;

--  ================ L_MEM1 ============================
        opcode_s <= ITYPE_OPCODE_L_MEM1;
        wait for 20 ns;

--  ================ L_MEM2 ============================
        opcode_s <= ITYPE_OPCODE_L_MEM2;
        wait for 20 ns;

--  ==================================================
		opcode_s <= (others => '0');
		wait for 40 ns;
	
	Rst_s <= '1';  -- end testing the CU
	En_s <= '0';
    wait;
    end process;


    -- process for the golden component
    process
    begin
        correct_word <= (others => '0');

        wait for 30 ns;
        correct_word <= "111" & "00000" & "00000"; -- ADD
		wait for 20 ns;
        correct_word <= "111" & "01001" & "00000"; -- SUB
		wait for 20 ns;
        correct_word <= "111" & "01011" & "00001"; -- OR
		wait for 20 ns;
        correct_word <= "111" & "01111" & "00001"; -- AND
		wait for 20 ns;
        correct_word <= "000" & "01101" & "00001"; -- NOP
		wait for 20 ns;
        correct_word <= "011" & "00000" & "00001"; -- ADDI1
		wait for 20 ns;
        correct_word <= "011" & "11001" & "00000"; -- SUBI1
		wait for 20 ns;
        correct_word <= "011" & "11011" & "00001"; -- ANDI1
		wait for 20 ns;
        correct_word <= "011" & "01101" & "00001"; -- ORI1
		wait for 20 ns;
        correct_word <= "101" & "01111" & "00001"; -- ADDI2
		wait for 20 ns;
        correct_word <= "101" & "00001" & "00001"; -- SUBI2
		wait for 20 ns;
        correct_word <= "101" & "00011" & "00001"; -- ANDI2
		wait for 20 ns;
        correct_word <= "101" & "00101" & "00001"; -- ORI2
		wait for 20 ns;
        correct_word <= "101" & "00111" & "00001"; -- MOV
		wait for 20 ns;
        correct_word <= "011" & "00001" & "00001"; -- S_REG1
		wait for 20 ns;
        correct_word <= "101" & "11001" & "00001"; -- S_REG2
		wait for 20 ns;
        correct_word <= "111" & "00001" & "00001"; -- S_MEM
		wait for 20 ns;
        correct_word <= "011" & "00001" & "00001"; -- L_MEM
		wait for 20 ns;
        correct_word <= "101" & "11001" & "01100"; -- L_MEM2
		wait for 20 ns;
        correct_word <= "000" & "00001" & "10111"; -- needed for the pipeline
		wait for 20 ns;
        correct_word <= "000" & "00000" & "10111"; -- needed for the pipeline
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

configuration CFG_tb_CU_HW of tb_CU_HW is
for tb
	for all : CU_HW
		use configuration work.CFG_CU_HW_ARCHSTRUCT;
	end for;
end for;
end configuration;
