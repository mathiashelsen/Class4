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

entity UART is
    port(
    clk         : in std_logic;          
    rst         : in std_logic;          -- async reset
    RxD         : in std_logic;          -- serial input for the UART
    TxD         : out std_logic;         -- output from the UART
    TxEn        : in std_logic;          -- start sending data
    inputData   : in std_logic_vector(7 downto 0);
    outputData  : out std_logic_vector(7 downto 0);
    uartStatus  : buffer std_logic_vector(31 downto 0)
    );
end UART;

architecture default of UART is
    type txState is ( IDLE, SENDING );
    signal txCurrent: txState;
    signal outputBuffer : std_logic_vector(9 downto 0);
    signal inputBuffer  : std_logic_vector(39 downto 0); -- 10 bits x 4 oversampling
    signal txReq        : std_logic;
    signal clkDiv       : unsigned(31 downto 0) := to_unsigned(5208, 32);
    signal clkDivCtr    : unsigned(31 downto 0);
    signal rxClkDivCtr  : unsigned(31 downto 0);
    signal bitCtr       : unsigned(4 downto 0);
    signal RxD_Q        : std_logic;

    signal outputCache  : std_logic_vector(7 downto 0);
begin

process(clk, rst) begin
    if(rst = '1') then
        outputBuffer    <= "1000000000"; 
        TxD             <= '1';
        RxD_Q           <= '1';
        txReq           <= '0';
        inputBuffer     <= (others => '1');
        outputBuffer    <= "1000000000";
        uartStatus      <= X"0000_0000";
        txCurrent       <= IDLE;
        clkDivCtr       <= to_unsigned(0, 32);
        rxClkDivCtr     <= to_unsigned(0, 32);

    elsif(clk'event and clk='0') then
        RxD_Q           <= RxD;

    elsif(clk'event and clk='1') then
        case txCurrent is
            when IDLE =>
                if(uartStatus(0) = '0' and TxEn = '1') then
                    txCurrent                   <= SENDING;
                    clkDivCtr                   <= clkDiv;
                    bitCtr                      <= to_unsigned(10, 5);
                    uartStatus(0)               <= '1';
                    outputBuffer                <= '1' & inputData & '0';
                end if;

            when SENDING =>
                if(clkDivCtr = X"0000_0000") then
                    -- Reset the prescaler counter
                    clkDivCtr       <= clkDiv;

                    if(bitCtr = to_unsigned(0, 4)) then
                        uartStatus(0)   <= '0';
                        uartStatus(1)   <= '1'; 
                        txCurrent       <= IDLE;
                        TxD             <= '1';
                    else
                        -- Another bit bites the dust (you have to sing this comment line)
                        bitCtr  <= bitCtr - to_unsigned(1, 4);
                        -- Bit away! (Requires pirate voice library)
                        TxD             <= outputBuffer(0);
                        -- Shift register on the outputBuffer (there is nothing funny about this)
                        outputBuffer    <= '0' & outputBuffer(9 downto 1);
                    end if;
                else
                    clkDivCtr   <= clkDivCtr - to_unsigned(1, 32);
                end if; 

            when others =>

        end case;  

        -- RX part
        -- The RX will oversample with a factor of 4 over the baud rate
        if( rxClkDivCtr = X"0000_0000" ) then
            rxClkDivCtr     <= to_unsigned(0, 2) & clkDiv(31 downto 2);
           
            if( inputBuffer(0) = '1' and inputBuffer(1) = '0' ) then
                for i in 0 to 7 loop
                        outputData(i) <= inputBuffer( (i+1)*4 + 2 );
                end loop;
                inputBuffer     <= (others => '1');
                uartStatus(2)   <= '1';
            else 
                inputBuffer     <= RxD_Q & inputBuffer(39 downto 1);
                uartStatus(2)   <= '0';
            end if;
        else
            rxClkDivCtr     <= rxClkDivCtr - to_unsigned(1, 32);
        end if;
    end if;
end process;

end architecture;
