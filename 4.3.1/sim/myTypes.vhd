library ieee;
use ieee.std_logic_1164.all;

package myTypes is

    -- control input sizes
    constant OP_CODE_SIZE           : integer := 6;     -- opcode: identifies the type of the operation
    constant FUNC_SIZE              : integer := 11;    -- func: type of the operation specified in case of R-Type instruction


    -- control word size
    constant CTRL_WORD_SIZE         : integer := 13;    -- the control word is the output of the Control Unit and its size is stricly dependent on the number of control signals sent to the datapath

    -- == R-TYPE instructions ==============================================================================================================================================================
    -- opcode field
    constant RTYPE_OPCODE           : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "000000";        -- opcode for R-Type instructions
    
    -- func field
    constant RTYPE_FUNC_ADD         : std_logic_vector(FUNC_SIZE - 1 downto 0)      :=  "00000000001";  -- ADD RS1,RS2,RD
    constant RTYPE_FUNC_SUB         : std_logic_vector(FUNC_SIZE - 1 downto 0)      :=  "00000000010";  -- SUB RS1,RS2,RD
    constant RTYPE_FUNC_OR          : std_logic_vector(FUNC_SIZE - 1 downto 0)      :=  "00000000011";  -- OR RS1,RS2,RD
    constant RTYPE_FUNC_AND         : std_logic_vector(FUNC_SIZE - 1 downto 0)      :=  "00000000100";  -- AND RS1,RS2,RD
	constant NOP 					: std_logic_vector(FUNC_SIZE - 1 downto 0) 		:=  "00000000000";  -- NO OPERATION


    -- == I-TYPE instructions ==============================================================================================================================================================
    -- opcode field
    constant ITYPE_OPCODE_ADDI1     : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "000011";  -- ADDI1 RS1,RD,INP1
    constant ITYPE_OPCODE_SUBI1     : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "000110";  -- SUBI1 RB,RA,INP1 (meaning R[RA] = R[RB] - INP1)
    constant ITYPE_OPCODE_ANDI1     : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "001001";  -- ANDI1 RB,RA,INP1 (meaning R[RA] = R[RB] AND INP1)
    constant ITYPE_OPCODE_ORI1      : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "001100";  -- ORI1 RB,RA,INP1 (meaning R[RA] = R[RB] OR INP1)
    constant ITYPE_OPCODE_ADDI2     : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "001111";  -- ADDI2 RA,RB,INP2 (meaning R[RB] = R[RA] + INP2)
    constant ITYPE_OPCODE_SUBI2     : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "010010";  -- SUBI2 RA,RB,INP2 (meaning R[RB] = R[RA] - INP2)
    constant ITYPE_OPCODE_ANDI2     : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "010101";  -- ANDI2 RA,RB,INP2 (meaning R[RB] = R[RA] AND INP2)
    constant ITYPE_OPCODE_ORI2      : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "011000";  -- ORI2 RA,RB,INP2 (meaning R[RB] = R[RA] OR INP2)
    constant ITYPE_OPCODE_MOV       : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "011011";  -- MOV RA,RB (meaning R[RB] = R[RA]) - The value of the immediate must be equal to 0
    constant ITYPE_OPCODE_S_REG1    : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "011110";  -- S_REG1 RB,INP1 (meaning R[RB] = INP1) - Save the value INP1 in the register file, RA field is not used
    constant ITYPE_OPCODE_S_REG2    : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "100001";  -- S_REG2 RB,INP2 (meaning R[RB] = INP2) - Save the value INP2 in the register file, RA field is not used
    constant ITYPE_OPCODE_S_MEM       : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "100100";  -- S_MEM RA,RB,INP2 (meaning MEM[R[RA]+INP2] = R[RB]) - The content of the register RB is saved in a     memory cell, whose address is calculated adding the content of the register RA to the value INP2 
    constant ITYPE_OPCODE_L_MEM1      : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "100111";  -- L_MEM1 RB,RA,INP1 (meaning R[RA] = MEM[R[RB]+INP1]) - The content of the memory cell, whose address  is calculated adding the content of the register RB to the value INP1, is saved in the register RA
    constant ITYPE_OPCODE_L_MEM2      : std_logic_vector(OP_CODE_SIZE-1 downto 0)     := "101010";  -- L_MEM2 RA,RB,INP2 (meaning R[RB] = MEM[R[RA]+INP2]) - The content of the memory cell, whose address  is calculated adding the content of the register RA to the value INP2, is saved in the register RB
    
    -- =====================================================================================================================================================================================

end package;
