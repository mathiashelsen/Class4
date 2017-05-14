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


--
-- This automaton will implement Conway's Game of Life
--
entity automaton is
    port(
        clkAdvance      : in        std_logic;
        clkShift        : in        std_logic;
        rst             : in        std_logic;

        status          : buffer    std_logic;
        inputs          : in        std_logic_vector(7 downto 0)
    );
end entity;

architecture default of automaton is
    signal  liveCells   : unsigned(7 downto 0);
begin

-- Some not-so-ugly code to do an 'OR' reduction
process( inputs ) is
    variable tmp : integer range 0 to 7 := 0;
begin
    for i in inputs'range loop
        tmp     := tmp + to_integer(unsigned(inputs(i downto i)));
    end loop;
    liveCells   <= to_unsigned(tmp, 8);
end process;

process(clkAdvance, rst) begin
    if(rst = '1') then
        status      <= '0';
    elsif(clkAdvance'event and clkAdvance ='1') then
        if( clkShift = '1') then
            status      <= inputs(0);
        else
            if(liveCells < to_unsigned(2, 8)) then
                status  <= '0';
            elsif(liveCells = to_unsigned(2, 8)) then
                status  <= status;
            elsif(liveCells = to_unsigned(3, 8)) then
                status  <= '1';
            else
                status  <= '0';
            end if;
        end if;
    end if;
end process;
end architecture;
