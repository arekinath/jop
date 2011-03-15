--
--
--  This file is a part of JOP, the Java Optimized Processor
--
--  Copyright (C) 2001-2008, Martin Schoeberl (martin@jopdesign.com)
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--


--
--	led_switch.vhd
--
--
--	2010-06-08	created
--


Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.jop_types.all;
use work.sc_pack.all;
use work.jop_config.all;

entity nexys_io is
generic (cpu_id : integer := 0; cpu_cnt : integer := 1);
port (
	clk		: in std_logic;
	reset	: in std_logic;

--
--	SimpCon IO interface
--
	sc_addr  : in std_logic_vector(3 downto 0);
	sc_rd		: in std_logic;
	sc_rd_data	: out std_logic_vector(31 downto 0);
	
	sc_wr		: in std_logic;
	sc_wr_data	: in std_logic_vector(31 downto 0);
	
	sc_rdy_cnt	: out unsigned(1 downto 0);
--
--	LEDs
--
	oLEDR		: out std_logic_vector(17 downto 0);
	ssegAnode : out std_logic_vector(3 downto 0);
	ssegCathode: out std_logic_vector(7 downto 0);
	
--
--	Switches
--
	iSW			: in std_logic_vector(17 downto 0);
	buttons		: in std_logic_vector(3 downto 0)
 );
end nexys_io;


architecture rtl of nexys_io is

	signal local_iSW_Reg	: std_logic_vector(17 downto 0);
	signal local_oLEDR_Reg : std_logic_vector(17 downto 0);
	signal buttons_reg : std_logic_vector(3 downto 0);
	signal btn_rst_reg : std_logic_vector(3 downto 0);
	signal digits : std_logic_vector(15 downto 0);
	signal clockdiv : std_logic_vector(15 downto 0);

	constant GPIO_CAP    : std_logic_vector(3 downto 0) := "0000";
	constant GPIO_LEDS   : std_logic_vector(3 downto 0) := "0001";
	constant GPIO_SWITCH : std_logic_vector(3 downto 0) := "0010";
	constant GPIO_BUTTON : std_logic_vector(3 downto 0) := "0011";
	constant GPIO_SSEG   : std_logic_vector(3 downto 0) := "0100";
	constant GPIO_MISC   : std_logic_vector(3 downto 0) := "0101";

begin

	process (clk)
	begin
		if clk'event and clk = '1' then
			clockdiv <= clockdiv + '1';
		end if;
	end process;
	
	sseg: entity work.ssegDriver port map (
		clk => clockdiv(15),
		rst => reset,
		cathode_p => ssegCathode,
		anode_p => ssegAnode,
		digit4_p => digits(15 downto 12),
		digit3_p => digits(11 downto 8),
		digit2_p => digits(7 downto 4),
		digit1_p => digits(3 downto 0)
	);

	-- Anti metastability
	process(CLK,RESET)
	begin
		if RESET = '1' then
			local_iSW_Reg <= (others => '0');
		elsif rising_edge(CLK) then
			local_iSW_Reg <= iSW;
		end if;
	end process;
	
	process(CLK,RESET)
	begin
		if RESET = '1' then
			buttons_reg <= (others => '0');
		elsif CLK'event and CLK = '1' then
			buttons_reg <= (buttons_reg or buttons) and (not btn_rst_reg);
		end if;
	end process;
	
	process(CLK, RESET)
	begin
		if RESET = '1' then
			btn_rst_reg <= (others => '0');
		elsif rising_edge(CLK) then
			if sc_wr = '1' and sc_addr = GPIO_BUTTON then
				btn_rst_reg <= sc_wr_data(3 downto 0);
			else
				btn_rst_reg <= (others => '0');
			end if;
		end if;
	end process;
	
	process(CLK,RESET)
	begin
		if RESET = '1' then
			sc_rd_data <= (others => '0');
			local_oLEDR_Reg <= (others => '0');
			digits <= (others => '0');
		elsif rising_edge(CLK) then
			if sc_rd = '1' then
				if sc_addr = GPIO_CAP then
					-- nexys2 gpio capabilities
					sc_rd_data(4 downto 0)   <= "01000"; -- 8 leds
					sc_rd_data(9 downto 5)   <= "01000"; -- 8 switches
					sc_rd_data(14 downto 10) <= "00100"; -- 4 buttons
					sc_rd_data(19 downto 15) <= "10100"; -- 4 digit seven seg, as hex digits
					sc_rd_data(24 downto 20) <= "00000"; -- no misc
					
					sc_rd_data(31 downto 25) <= (others => '0');
				elsif sc_addr = GPIO_LEDS then
					sc_rd_data(17 downto 0) <= local_oLEDR_Reg;
					sc_rd_data(31 downto 18) <= (others => '0');
				elsif sc_addr = GPIO_SWITCH then
					sc_rd_data(17 downto 0) <= local_iSW_Reg;
					sc_rd_data(31 downto 18) <= (others => '0');
				elsif sc_addr = GPIO_BUTTON then
					sc_rd_data(3 downto 0) <= buttons_reg;
					sc_rd_data(31 downto 4) <= (others => '0');
				elsif sc_addr = GPIO_SSEG then
					sc_rd_data(15 downto 0) <= digits;
					sc_rd_data(31 downto 16) <= (others => '0');
				else
					sc_rd_data(31 downto 0) <= (others => '0');
				end if;
			end if;
			if sc_wr = '1' then
				if sc_addr = GPIO_LEDS then
					local_oLEDR_Reg <= sc_wr_data(17 downto 0);
				elsif sc_addr = GPIO_SSEG then
					digits <= sc_wr_data(15 downto 0);
				end if;
			end if;
		end if;
	end process;
	
	oLEDR <= local_oLEDR_Reg;

end rtl;

