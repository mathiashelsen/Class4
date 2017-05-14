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

entity Class4 is
    port(
        FPGA_CLK1_50    : in    std_logic;
        SW              : in    std_logic_vector(2 downto 0);
        GPIO_0          : inout std_logic_vector(31 downto 0);
    );
end entity;

architecture default of Class4 is 
    component commandModule
    port(
        clk     :   in  std_logic;
        rst     :   in  std_logic;
        RxD     :   in  std_logic;
        TxD     :   out std_logic
    );
    end component; 
begin
    mainController : commandModule port map(
        clk     => FPGA_CLK1_50,
        rst     => SW(0),
        RxD     => GPIO_0(1),
        TxD     => GPIO_0(0) 
    );
end architecture;
