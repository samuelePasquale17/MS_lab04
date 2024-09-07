library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity LUT_CU is
	generic (
		-- default value defined into myTypes package
		control_word_bits : integer := CTRL_WORD_SIZE  -- number of bits for the control word
	);
	port (
		-- for the LUT the size of inputs must be a constant, thus change is directly from the myTypes package
		opcode : in std_logic_vector(op_code_size-1 downto 0);  -- opcode field
		func : in std_logic_vector(func_size-1 downto 0);  -- func field
		En : in std_logic; -- enable signal
		control_word : out std_logic_vector(control_word_bits-1 downto 0)  -- control word driven as output

		-- for the CU FSM implementation the following mapping for the control word has been defined
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

architecture ARCHSTRUCT of LUT_CU is
begin

	-- process implementing the LUT 
	process (opcode, func, En)
	variable inp_sig : std_logic_vector(op_code_size+func_size downto 0);
	begin
		inp_sig := opcode & func & En;  -- checking both inputs within the same case condition
		case (inp_sig) is
			-- handling all the possible instructions and driving the control word as output
			when RTYPE_OPCODE 			& 	NOP 			& "1" => control_word <= "0000000000000";
			when RTYPE_OPCODE 			& 	RTYPE_FUNC_ADD 	& "1" => control_word <= "1110100100001";
			when RTYPE_OPCODE 			& 	RTYPE_FUNC_SUB 	& "1" => control_word <= "1110101100001";
			when RTYPE_OPCODE 			& 	RTYPE_FUNC_AND 	& "1" => control_word <= "1110110100001";
			when RTYPE_OPCODE 			& 	RTYPE_FUNC_OR 	& "1" => control_word <= "1110111100001";
			when ITYPE_OPCODE_ADDI1 	& 	"00000000000" 	& "1" => control_word <= "0111100100001";
			when ITYPE_OPCODE_SUBI1 	& 	"00000000000" 	& "1" => control_word <= "0111101100001";
			when ITYPE_OPCODE_ANDI1 	& 	"00000000000" 	& "1" => control_word <= "0110110100001";
			when ITYPE_OPCODE_ORI1 		& 	"00000000000" 	& "1" => control_word <= "0110111100001";
			when ITYPE_OPCODE_ADDI2 	& 	"00000000000" 	& "1" => control_word <= "1010000100001";
			when ITYPE_OPCODE_SUBI2 	& 	"00000000000" 	& "1" => control_word <= "1010001100001";
			when ITYPE_OPCODE_ANDI2 	& 	"00000000000" 	& "1" => control_word <= "1010010100001";
			when ITYPE_OPCODE_ORI2 		& 	"00000000000" 	& "1" => control_word <= "1010011100001";
			when ITYPE_OPCODE_MOV 		& 	"00000000000" 	& "1" => control_word <= "1010000100001";
			when ITYPE_OPCODE_S_REG1	& 	"00000000000" 	& "1" => control_word <= "0111100100001";
			when ITYPE_OPCODE_S_REG2 	& 	"00000000000" 	& "1" => control_word <= "1010000100001";
			when ITYPE_OPCODE_S_MEM 	& 	"00000000000" 	& "1" => control_word <= "1110000101100";
			when ITYPE_OPCODE_L_MEM1 	& 	"00000000000" 	& "1" => control_word <= "0111100110111";
			when ITYPE_OPCODE_L_MEM2 	& 	"00000000000" 	& "1" => control_word <= "1010000110111";
			when others 									=> control_word <= (others => '0');

		end case;
	end process;

end architecture;

configuration CFG_LUT_CU_ARCHBEH of LUT_CU is
for ARCHSTRUCT
end for;
end configuration;
