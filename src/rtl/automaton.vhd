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

        status          : buffer    std_logic_vector(7 downto 0);
        node_N_W        : in        std_logic_vector(7 downto 0);
        node_N          : in        std_logic_vector(7 downto 0);
        node_N_E        : in        std_logic_vector(7 downto 0);
        node_E          : in        std_logic_vector(7 downto 0);
        node_S_E        : in        std_logic_vector(7 downto 0);
        node_S          : in        std_logic_vector(7 downto 0);
        node_S_W        : in        std_logic_vector(7 downto 0);
        node_W          : in        std_logic_vector(7 downto 0)
    );
end entity;

architecture default of automaton is
    signal  liveCells   : unsigned(63 downto 0);
begin

-- Some not-so-ugly code to do an 'OR' reduction
process(node_N_W, node_N, node_N_E,
    node_E,
    node_S_E, node_S, node_S_W,
    node_W
    ) begin
    liveCells   <= unsigned(node_N_W)
        + unsigned(node_N) + unsigned(node_N_E)
        + unsigned(node_E) + unsigned(node_S_E)
        + unsigned(node_S) + unsigned(node_S_W)
        + unsigned(node_W);
end process;

process(clkAdvance, clkShift, rst) begin
    if(rst = '1') then
        status      <= X"00";
    elsif(clkAdvance'event and clkAdvance = '1') then
        if(liveCells < to_unsigned(2, 64)) then
            status  <= X"00";
        elsif(liveCells = to_unsigned(2, 64)) then
            status  <= status;
        elsif(liveCells = to_unsigned(3, 64)) then
            status  <= X"01";
        else
            status  <= X"00";
        end if;
    elsif(clkShift'event and clkShift = '1') then
        status      <= node_N;
    end if;
end process;
end architecture;
