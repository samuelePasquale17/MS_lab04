library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;


entity CU_FSM is
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


architecture ARCHBEH of CU_FSM is
type state_type is (PIPE_STAGE_1, PIPE_STAGE_2, PIPE_STAGE_3, RST_STATE);  -- states of the FSM
signal currState, nextState : state_type;  -- curr state and next state signal for the state register


begin

	-- process for the status register of the FSM
	-- the reset signal is asynchronous 
	process(Clk, Rst)
	begin
		if (Rst = '1') then	 -- reset FSM
			currState <= RST_STATE;  -- coming back to the reset state
		elsif (rising_edge(Clk)) then
			currState <= nextState;  -- sampling the next state
		end if;	
	end process;

	-- process which computes the control word given the current state and the inputs
	-- the FSM is a mealy FSM, thus inputs should stay stable over the entire clock period 
	process(opcode, func, Rst, currState)
	begin
		nextState <= currState;  -- stay in the current state by default (safety assignment that actually will never takes place)
		control_word <= (others => '0'); -- zero output by default

		-- check the current state
		case (currState) is

			-- reset state. The output is zeroed-out
			when RST_STATE =>
				control_word <= (others => '0');
				nextState <= currState;
				if (Rst = '0') then  -- if rst is no longer active move to the PIPE_STAGE_1 state and starts generating the control word
					nextState <= PIPE_STAGE_1;
				end if;
				
			-- State which generates the control signal for the stage 1 of the datapath, the other control signals are equal to zero by default
			when PIPE_STAGE_1 =>																				   -- RF1 RF2 EN1
					   if (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_ADD) then control_word <= "1110000000000";  -- 111 00000 00000
					elsif (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_SUB) then control_word <= "1110000000000";  -- 111 00000 00000
					elsif (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_AND) then control_word <= "1110000000000";  -- 111 00000 00000
					elsif (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_OR ) then control_word <= "1110000000000";  -- 111 00000 00000
					elsif (opcode = RTYPE_OPCODE and func = NOP           ) then control_word <= "0000000000000";  -- 000 00000 00000
					elsif (opcode = ITYPE_OPCODE_ADDI1 ) 					then control_word <= "0110000000000";  -- 011 00000 00000
					elsif (opcode = ITYPE_OPCODE_SUBI1 ) 					then control_word <= "0110000000000";  -- 011 00000 00000
					elsif (opcode = ITYPE_OPCODE_ANDI1 ) 					then control_word <= "0110000000000";  -- 011 00000 00000
					elsif (opcode = ITYPE_OPCODE_ORI1  ) 					then control_word <= "0110000000000";  -- 011 00000 00000
					elsif (opcode = ITYPE_OPCODE_ADDI2 ) 					then control_word <= "1010000000000";  -- 101 00000 00000
					elsif (opcode = ITYPE_OPCODE_SUBI2 ) 					then control_word <= "1010000000000";  -- 101 00000 00000
					elsif (opcode = ITYPE_OPCODE_ANDI2 ) 					then control_word <= "1010000000000";  -- 101 00000 00000
					elsif (opcode = ITYPE_OPCODE_ORI2  ) 					then control_word <= "1010000000000";  -- 101 00000 00000
					elsif (opcode = ITYPE_OPCODE_MOV   ) 					then control_word <= "1010000000000";  -- 101 00000 00000
					elsif (opcode = ITYPE_OPCODE_S_REG1) 					then control_word <= "0110000000000";  -- 011 00000 00000
					elsif (opcode = ITYPE_OPCODE_S_REG2) 					then control_word <= "1010000000000";  -- 101 00000 00000
					elsif (opcode = ITYPE_OPCODE_S_MEM ) 					then control_word <= "1110000000000";  -- 111 00000 00000
					elsif (opcode = ITYPE_OPCODE_L_MEM1) 					then control_word <= "0110000000000";  -- 011 00000 00000
					elsif (opcode = ITYPE_OPCODE_L_MEM2) 					then control_word <= "1010000000000";  -- 101 00000 00000
					else 														 control_word <= "0000000000000";  -- 000 00000 00000
					end if;
					nextState <= PIPE_STAGE_2;		-- moving the the next state for the pipeline stage 2
					if (Rst = '1') then  -- if reset signal is raised the output is zeroed-out and the FSM moves to the reset state
						control_word <= (others => '0');
						nextState <= RST_STATE;
					end if;

			-- State which generates the control signal for the stage 2 of the datapath, the other control signals are equal to zero by default
			when PIPE_STAGE_2 =>																				   -- S1 S2 ALU1 ALU2 EN2
			   		   if (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_ADD) then control_word <= "0000100100000";  -- 000 01001 00000
					elsif (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_SUB) then control_word <= "0000101100000";  -- 000 01011 00000
					elsif (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_AND) then control_word <= "0000110100000";  -- 000 01101 00000
					elsif (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_OR ) then control_word <= "0000111100000";  -- 000 01111 00000
					elsif (opcode = RTYPE_OPCODE and func = NOP           ) then control_word <= "0000000000000";  -- 000 00000 00000
					elsif (opcode = ITYPE_OPCODE_ADDI1 ) 					then control_word <= "0001100100000";  -- 000 11001 00000
					elsif (opcode = ITYPE_OPCODE_SUBI1 ) 					then control_word <= "0001101100000";  -- 000 11011 00000
					elsif (opcode = ITYPE_OPCODE_ANDI1 ) 					then control_word <= "0000110100000";  -- 000 01101 00000
					elsif (opcode = ITYPE_OPCODE_ORI1  ) 					then control_word <= "0000111100000";  -- 000 01111 00000
					elsif (opcode = ITYPE_OPCODE_ADDI2 ) 					then control_word <= "0000000100000";  -- 000 00001 00000
					elsif (opcode = ITYPE_OPCODE_SUBI2 ) 					then control_word <= "0000001100000";  -- 000 00011 00000
					elsif (opcode = ITYPE_OPCODE_ANDI2 ) 					then control_word <= "0000010100000";  -- 000 00101 00000
					elsif (opcode = ITYPE_OPCODE_ORI2  ) 					then control_word <= "0000011100000";  -- 000 00111 00000
					elsif (opcode = ITYPE_OPCODE_MOV   ) 					then control_word <= "0000000100000";  -- 000 00001 00000
					elsif (opcode = ITYPE_OPCODE_S_REG1) 					then control_word <= "0001100100000";  -- 000 11001 00000
					elsif (opcode = ITYPE_OPCODE_S_REG2) 					then control_word <= "0000000100000";  -- 000 00001 00000
					elsif (opcode = ITYPE_OPCODE_S_MEM ) 					then control_word <= "0000000100000";  -- 000 00001 00000
					elsif (opcode = ITYPE_OPCODE_L_MEM1) 					then control_word <= "0001100100000";  -- 000 11001 00000
					elsif (opcode = ITYPE_OPCODE_L_MEM2) 					then control_word <= "0000000100000";  -- 000 00001 00000
					else 														 control_word <= "0000000000000";  -- 000 00000 00000
					end if;
					nextState <= PIPE_STAGE_3;		-- moving the the next state for the pipeline stage 3
					if (Rst = '1') then  -- if reset signal is raised the output is zeroed-out and the FSM moves to the reset state
						control_word <= (others => '0');
						nextState <= RST_STATE;
					end if;

			-- State which generates the control signal for the stage 2 of the datapath, the other control signals are equal to zero by default
			when PIPE_STAGE_3 =>																				   -- RM WM EN3 S3 WF1
				  	   if (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_ADD) then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_SUB) then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_AND) then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = RTYPE_OPCODE and func = RTYPE_FUNC_OR ) then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = RTYPE_OPCODE and func = NOP           ) then control_word <= "0000000000000";  -- 000 00000 00000
					elsif (opcode = ITYPE_OPCODE_ADDI1 ) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_SUBI1 ) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_ANDI1 ) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_ORI1  ) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_ADDI2 ) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_SUBI2 ) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_ANDI2 ) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_ORI2  ) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_MOV   ) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_S_REG1) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_S_REG2) 					then control_word <= "0000000000001";  -- 000 00000 00001
					elsif (opcode = ITYPE_OPCODE_S_MEM ) 					then control_word <= "0000000001100";  -- 000 00000 01100
					elsif (opcode = ITYPE_OPCODE_L_MEM1) 					then control_word <= "0000000010111";  -- 000 00000 10111
					elsif (opcode = ITYPE_OPCODE_L_MEM2) 					then control_word <= "0000000010111";  -- 000 00000 10111
					else 														 control_word <= "0000000000000";  -- 000 00000 00000
					end if;
					nextState <= PIPE_STAGE_1;	-- coming back to PIPE_STAGE_1 state
					if (Rst = '1') then  -- if reset signal is raised the output is zeroed-out and the FSM moves to the reset state
						control_word <= (others => '0');
						nextState <= RST_STATE;
					end if;

			when others =>  -- design of a safe FSM
				nextState <= RST_STATE;
				control_word <= (others => '0');
				
		end case;
	end process;
end architecture;

configuration CFG_CU_FSM_BEH of CU_FSM is
	for ARCHBEH
	end for;
end configuration;
