
-- ROM with synchonous read (inferring Block RAM)
-- character ROM
--   - 8-by-16 (8-by-2^4) font
--   - 128 (2^7) characters
--   - ROM size: 512-by-8 (2^11-by-8) bits
--               16K bits: 1 BRAM

-- Original Source: https://github.com/thelonious/vga_generator/tree/master/vga_text
-- NOTE: This is not the original. Cleaned up by MLM

-- VHDL'93 supports the full table of ISO-8859-1 characters (0x00 through 0xFF(255))

-- Note that signal initial values are used to store values in the rom. Normally signal initial
-- values are not synthesizable, but Quartus will use the signal initial values to preload a
-- register when the FPGA configuration is done, assuming that the signal is mapped to a register output.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


-- modified to make it a ROM, and to address by character code, font row and font column (JJClark Sept 2016)

entity sprite_rom is
    generic(
        addrWidth: integer := 6;
        dataWidth: integer := 16
    );
    port(
        clk: in std_logic;
        sprite_addr : in std_logic_vector(2 downto 0); -- 0-7 addr of sprite
        sprite_row  : in std_logic_vector(2 downto 0); -- 0-7 row address in single character
        sprite_col  : in std_logic_vector(3 downto 0); -- 0-15 column address in single character
        sprite_bit  : out std_logic -- pixel value at the given row and column for the selected character code
    );
end sprite_rom;

architecture Behavioral of sprite_rom is
   

    type rom_type is array (0 to 2**addrWidth-1) of std_logic_vector(dataWidth-1 downto 0);
    
    signal addr : std_logic_vector(addrWidth-1 downto 0);
    signal dataOut: std_logic_vector(dataWidth-1 downto 0);

    -- ROM definition
    signal ROM: rom_type := (  
        -- SCO: code x00
    --   SSSS-CCCC-OOOO  
        "0000000000000000", -- 0
        "0110001110011000", -- 1
        "1001010000100100", -- 2
        "1000010000100100", -- 3
        "0110010000100100", -- 4
        "0001010000100100", -- 5
        "1001010000100100", -- 6
        "0110001110011000", -- 7

        -- RE: code x01
    --   RRRRR-EEEE
        "0000000000000000", -- 0
        "1110000111000000", -- 1
        "1001001000000000", -- 2
        "1001001000000000", -- 3
        "1110001111000000", -- 4
        "1010001000000000", -- 5
        "1001001000000000", -- 6
        "1000100111000000", -- 7
        -- 0123: code x02
    --   000-1---222-333 
        "0000000000000000", -- 0
        "0100100001101100", -- 1
        "1010100000100010", -- 2 
        "1010100000100010", -- 3
        "1010100001101110", -- 4
        "1010100010000010", -- 5
        "1010100010000010", -- 6
        "0100100011001100", -- 7
        --4567: code x03
    --   444-555-666-777 
        "0000000000000000", -- 0
        "1010011011101110", -- 1
        "1010100010000010", -- 2 
        "1110100010000010", -- 3
        "0010111011100010", -- 4
        "0010001010100010", -- 5
        "0010001010100010", -- 6
        "0010111011100010", -- 7
        -- 89: code x04
    --   888-999
        "0000000000000000", -- 0
        "0100111000000000", -- 1
        "1010101000000000", -- 2 
        "1010101000000000", -- 3
        "0110111000000000", -- 4
        "1010001000000000", -- 5
        "1010001000000000", -- 6
        "0100001000000000", -- 7
		  -----------------------------------
        -- ship: code x05
    --TODO:design your own ship

--	    	 "0000000000000000", -- 0
--        "0000000000000000", -- 1
--        "0000000000000000", -- 2 
--        "0000000000000000", -- 3
--        "0000000000000000", -- 4
--        "0000000000000000", -- 5
--        "0000000000000000", -- 6
--        "0000000000000000", -- 7
		  

        "0000000110000000", -- 2 
        "0000001111000000", -- 3
        "0000011111100000", -- 4
        "0001111111111000", -- 5
        "0111111111111110", -- 6
        "0111111111111110", -- 7
		  "0000000000000000", -- 0
		  "0000000000000000",
		  --------------------------------------
        -- Alien: code x06
    --TODO:design your own alien
		
--		  "0000000000000000", -- 0
--      "0000000000000000", -- 1
--      "0000000000000000", -- 2 
--      "0000000000000000", -- 3
--      "0000000000000000", -- 4
--      "0000000000000000", -- 5
--      "0000000000000000", -- 6
--	 	  "0000000000000000", -- 7
		
        "0001000000001000", -- 0
        "0001000000001000", -- 1
        "0000100000010000", -- 2 
        "0001111111111000", -- 3
        "0011111111111100", -- 4
        "0010101010101100", -- 5
        "0010111111110100", -- 6
   	  "0001000000001000", -- 7		
		----------------------------------------
        -- Bullet, M, V: code x07
    --   bbb mmmmm vvvvv
        "0100000000000000", -- 0
        "1110100010100010", -- 1
        "1110110110100010", -- 2 
        "0100101010100010", -- 3
        "0000100010100010", -- 4
        "0000100010100010", -- 5
        "0000100010010100", -- 6
        "0000100010001000"  -- 7

        -- Empty Template: code x01
        --"0000000000000000", -- 0
        --"0000000000000000", -- 1
        --"0000000000000000", -- 2 
        --"0000000000000000", -- 3
        --"0000000000000000", -- 4
        --"0000000000000000", -- 5
        --"0000000000000000", -- 6
        --"0000000000000000", -- 7

    );
begin

    -- Concat sprite addr with row addr
    addr <= sprite_addr & sprite_row;
    
    sprite_bit <= dataOut(to_integer(unsigned(not sprite_col)));
    
    -- address register to infer block RAM
    setReg: process (clk)
    begin
        if rising_edge(clk) then
        
            -- Read from rom
            dataOut <= ROM(to_integer(unsigned(addr)));

        end if;
    end process;
    
end Behavioral;
