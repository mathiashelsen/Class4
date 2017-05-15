--
-- MIT License
-- 
-- Copyright (c) 2017 Mathias Helsen
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity array is
    port(
        clk         : in    std_logic;
        advance     : in    std_logic;
        shiftDown   : in    std_logic;
        shiftRight  : in    std_logic;
        rst         : in    std_logic;
        inputData   : in    std_logic;
        outputData  : out   std_logic;
    );
end entity;

architecture default of array is
    constant N_Rows : natural := 8;
    constant N_Cols : natural := 8;

    type matrix is array(N_Rows-1 downto 0) of 
        std_logic_vector(N_Cols-1 downto 0);
    signal automatonOut : matrix;

    signal topShiftReg  : std_logic_vector(N_Cols-1 downto 0);
    signal botShiftReg  : std_logic_vector(N_Cols-1 downto 0);

    component automaton
    port(
        clk             : in        std_logic;
        advance         : in        std_logic;
        shift           : in        std_logic;
        rst             : in        std_logic;

        status          : buffer    std_logic;
        inputs          : in        std_logic_vector(7 downto 0)
    );
    end component;

    genArray:   for i in 0 to N_Rows-1 generate
        genRows:    for j in 0 to N_Cols-1 generate
            -- Center center, no edges 
            centerBlock: if (i > 0) 
                and (j > 0) 
                and i < (N_Rows-1) 
                and j < (N_Cols-1) generate
                node:   automaton port map(
                    clk         => clk,
                    advance     => advance,
                    shift       => shiftDown,
                    rst         => SW(0),
                    status      => automatonOut(i)(j),
                    inputs      => (
                          automatonOut(i+1)(j)
                        & automatonOut(i+1)(j+1)
                        & automatonOut(i)  (j+1)
                        & automatonOut(i-1)(j+1)
                        & automatonOut(i-1)(j)
                        & automatonOut(i-1)(j-1)
                        & automatonOut(i)  (j-1)
                        & automatonOut(i+1)(j-1)
                    )
                ); 
            end generate centerBlock;

            -- Top center
            topCenterBlock: if (i > 0) 
                and i < (N_Rows-1) 
                and j = (N_Cols-1) generate
                node:   automaton port map(
                    clk         => clk,
                    advance     => advance,
                    shift       => shiftDown,
                    rst         => SW(0),
                    status      => automatonOut(i)(j),
                    inputs      => (
                          topShiftReg(j)        --automatonOut(i+1)(j)
                        & topShiftReg(j+1)      --automatonOut(i+1)(j+1)
                        & automatonOut(i)  (j+1)
                        & automatonOut(i-1)(j+1)
                        & automatonOut(i-1)(j)
                        & automatonOut(i-1)(j-1)
                        & automatonOut(i)  (j-1)
                        & topShiftReg(j-1)      -- automatonOut(i+1)(j-1)
                    )
                ); 
            end generate topCenterBlock;
begin

process(clk) begin
    if(clk'event and clk = '1') then
        if( shiftRight = '1' ) then
            -- Shift to the right, cell (0, y) is rightmost
            -- Copy from bottom shift register to the output
            botShiftReg <= '0' & botShiftReg(NCols-1 downto 1);
            outputData  <= botShiftReg(0);
            -- Copy from the input to the top shift register 
            topShiftReg <= inputData & topShiftReg(NCols-1 downto 1);
        elsif( shiftDown = '1') then
            botShiftReg <= automatonOut(0);
        end if;
    end if;
end process;

end architecture;
