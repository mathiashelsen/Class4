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

entity commandModule is 
    port(
        clk     :   in  std_logic;
        rst     :   in  std_logic;
        RxD     :   in  std_logic;
        TxD     :   out std_logic
    );
end entity;

architecture default of commandModule is
    signal TxEn             :   std_logic;
    signal TxReq            :   std_logic;
    signal inputData        :   std_logic_vector(7 downto 0);
    signal outputData       :   std_logic_vector(7 downto 0);
    signal uartStatus       :   std_logic_vector(31 downto 0);
    signal prevUartStatus   :   std_logic_vector(31 downto 0);
    component uart 
        port(
        clk         : in    std_logic;          
        rst         : in    std_logic;          -- async reset
        RxD         : in    std_logic;          -- serial input for the UART
        TxD         : out   std_logic;         -- output from the UART
        TxEn        : in    std_logic;          -- start sending data
        inputData   : in    std_logic_vector(7 downto 0);
        outputData  : out   std_logic_vector(7 downto 0);
        uartStatus  : buffer std_logic_vector(31 downto 0)
        );
    end component;
begin
    mainIODev : uart port map(
        clk         =>  clk,
        rst         =>  rst,
        RxD         =>  RxD,
        TxD         =>  TxD,
        inputData   =>  outputData,
        outputData  =>  inputData,
        uartStatus  =>  uartStatus,
        TxEn        =>  TxEn
    ); 

process(clk, rst) begin
    if(rst = '1') then
        prevUartStatus  <= std_logic_vector(to_unsigned(0, 32));
        TxReq           <= '0';
        TxEn            <= '0';
    elsif(clk'event and clk = '1') then
        prevUartStatus  <= uartStatus;
       

        -- Basic ECHO implementation, if char received, tx it back -- 
        if(prevUartStatus(2) = '0' and uartStatus(2) = '1') then
            outputData  <=  inputData;
            TxReq       <= '1';
        end if;

        if(TxReq = '1' and uartStatus(0) = '0') then
            TxEn    <= '1';
            TxReq   <= '0';
        else
            TxEn    <= '0';
        end if;
    end if;

end process;
end architecture;
