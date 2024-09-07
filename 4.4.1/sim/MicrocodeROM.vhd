library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;


entity MicrocodeROM is
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
end entity;


architecture ARCHBEH of MicrocodeROM  is
    -- definition of a mem_type for the internal storage of the microcode memory
    type mem_type is array (integer range 0 to Nentries-1) of std_logic_vector(control_word_size-1 downto 0);
	signal microcode : mem_type;

    -- procedure for init the microcode rom 
	procedure init_microcodeROM(signal microcode : out mem_type) is
	variable address : std_logic_vector(opcode_bits+func_bits-1 downto 0);
	begin
	
		for i in 0 to Nentries-1 loop  -- ROM memory zeroed-out
			microcode(i) <= "0000000000000";
		end loop;

        -- storing control word 

        -- ======================================================================= NOP
        -- address is the concatenation func & opcode
		address := NOP & RTYPE_OPCODE;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "0000000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000000000000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000000";  -- stage 3
        
        -- ======================================================================= ADD
        -- address is the concatenation func & opcode
		address := RTYPE_FUNC_ADD & RTYPE_OPCODE;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000100100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= SUB
        -- address is the concatenation func & opcode
		address := RTYPE_FUNC_SUB & RTYPE_OPCODE;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000101100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= AND
        -- address is the concatenation func & opcode
		address := RTYPE_FUNC_AND & RTYPE_OPCODE;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000110100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= OR
        -- address is the concatenation func & opcode
		address := RTYPE_FUNC_OR & RTYPE_OPCODE;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000111100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= ADDI1
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_ADDI1;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "0110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0001100100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= SUBI1
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_SUBI1;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "0110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0001101100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= ANDI1
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_ANDI1;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "0110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000110100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= ORI1
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_ORI1;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "0110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000111100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= ADDI2
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_ADDI2;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1010000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000000100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= SUBI2
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_SUBI2;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1010000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000001100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= ANDI2
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_ANDI2;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1010000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000010100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= ORI2
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_ORI2;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1010000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000011100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= MOV
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_MOV;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1010000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000000100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= S_REG1
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_S_REG1;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "0110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0001100100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= S_REG2
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_S_REG2;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1010000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000000100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000000001";  -- stage 3

        -- ======================================================================= S_MEM
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_S_MEM;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000000100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000001100";  -- stage 3

        -- ======================================================================= L_MEM1
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_L_MEM1;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "0110000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0001100100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000010111";  -- stage 3

        -- ======================================================================= L_MEM2
        -- address is the concatenation func & opcode
		address := "00000000000" & ITYPE_OPCODE_L_MEM2;
        -- control word for the three stages
		microcode(to_integer(unsigned(address)))        <= "1010000000000";  -- stage 1
        microcode(to_integer(unsigned(address)) + 1)    <= "0000000100000";  -- stage 2
        microcode(to_integer(unsigned(address)) + 2)    <= "0000000010111";  -- stage 3


	end procedure;


begin

	-- init the ROM
	process
	begin
		init_microcodeROM(microcode);  -- function for the initialization
		wait;
	end process;

    -- behavior defined by a process
    process(Addr1, Clk)
    begin
        if (En = '1') then  -- asynchronous read port
            Out1 <= microcode(to_integer(unsigned(Addr1)));  -- reading the entry at address Addr1 and driving the output
        end if;
    end process ;

end ARCHBEH ;

configuration CFG_MICROCODEROM_ARCHBEH of MicrocodeROM is
for ARCHBEH
end for;
end configuration;
