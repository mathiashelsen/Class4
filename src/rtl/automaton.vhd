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
    signal  liveCells   : std_logic_vector(7 downto 0);
begin

-- Some very ugly code to do an 'OR' reduction
process(node_N_W, node_N, node_N_E,
    node_E,
    node_S_E, node_S, node_S_W,
    node_W
    ) begin

    if(node_N_W != X"00") then
        liveCells(0)    <= '1';
    else
        liveCells(0)    <= '0';
    end if;

    if(node_N != X"00") then
        liveCells(1)    <= '1';
    else
        liveCells(1)    <= '0';
    end if;

    if(node_N_E != X"00") then
        liveCells(2)    <= '1';
    else
        liveCells(2)    <= '0';
    end if;

    if(node_E != X"00") then
        liveCells(3)    <= '1';
    else
        liveCells(3)    <= '0';
    end if;

    if(node_S_E != X"00") then
        liveCells(4)    <= '1';
    else
        liveCells(4)    <= '0';
    end if;

    if(node_S != X"00") then
        liveCells(5)    <= '1';
    else
        liveCells(5)    <= '0';
    end if;

    if(node_S_W != X"00") then
        liveCells(6)    <= '1';
    else
        liveCells(6)    <= '0';
    end if;

    if(node_W != X"00") then
        liveCells(7)    <= '1';
    else
        liveCells(7)    <= '0';
    end if;
end process;

process(clkAdvance, clkShift, rst) begin
    if(rst = '1') then
        status      <= X"00";
    elsif(clkAdvance'event and clkAdvance = '1') then

    elsif(clkShift'event and clkShift = '1') then

    end if;
end
end architecture;
