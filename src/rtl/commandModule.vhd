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
    type states is (IDLE, 
        RX_CMD_0, 
        RX_CMD_1,
        TX_ACK_0,
        TX_ACK_1
        );
    signal FSM              :   states;

    signal RxFlag           :   std_logic;

    signal TxEn             :   std_logic;
    signal TxReq            :   std_logic;
    signal inputData        :   std_logic_vector(7 downto 0);
    signal outputData       :   std_logic_vector(7 downto 0);
    signal uartStatus       :   std_logic_vector(31 downto 0);
    signal cmdWord          :   std_logic_vector(23 downto 0);
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
        FSM             <= IDLE;
        TxReq           <= '0';
        TxEn            <= '0';
        cmdWord         <= std_logic_vector(to_unsigned(0, 24));
    elsif(clk'event and clk = '1') then
        RxFlag          <= uartStatus(2);
        case FSM is
            when IDLE =>
                if(uartStatus(2) = '1' and RxFlag = '0') then
                    FSM <= RX_CMD_0;
                    cmdWord <= inputData & std_logic_vector(to_unsigned(0, 16));
                end if;
            when RX_CMD_0 =>
                if(uartStatus(2) = '1' and RxFlag = '0') then
                    FSM <= RX_CMD_1;
                    cmdWord <= cmdWord(23 downto 16) & inputData 
                        & std_logic_vector(to_unsigned(0, 8));
                end if;

            when RX_CMD_1 =>
                if(uartStatus(2) = '1' and RxFlag = '0') then
                    FSM <= TX_ACK_0;
                    cmdWord <= cmdWord(23 downto 8) & inputData;
                end if;

            when TX_ACK_0 =>
                TxEn    <= '1';
                outputData  <= std_logic_vector(to_unsigned(48, 8));
                FSM     <= TX_ACK_1;

            when TX_ACK_1 =>
                TxEn    <= '0';
                FSM     <= IDLE;

            when others =>
                FSM     <= IDLE;

        end case;
    end if;

end process;
end architecture;
