--
--	jopsc.vhd
--
--	top level for cycore borad
--
--	2002-03-28	creation
--	2002-06-27	isa bus for CS8900
--	2002-07-27	io for baseio
--	2002-08-02	second uart (use first for download and debug)
--	2002-11-01	removed second uart
--	2002-12-01	split memio
--	2002-12-07	disable clkout
--	2003-02-21	adapt for new Cyclone board with EP1C6
--	2003-07-08	invertion of cts, rts to uart
--	2004-09-11	new extension module
--	2004-10-08	mul operands from a and b, single instruction
--	2005-05-12	added the bsy routing through extension
--	2005-08-15	sp_ov can be used to show a stoack overflow on the wd pin
--
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.jop_types.all;
use work.wb_pack.all;


entity jop is

generic (
	exta_width	: integer := 3;		-- address bits of internal io
	ram_cnt		: integer := 2;		-- clock cycles for external ram
--	rom_cnt		: integer := 3;		-- clock cycles for external rom OK for 20 MHz
	rom_cnt		: integer := 15;	-- clock cycles for external rom for 100 MHz
	jpc_width	: integer := 12;	-- address bits of java bytecode pc = cache size
	block_bits	: integer := 4		-- 2*block_bits is number of cache blocks
);

port (
	clk		: in std_logic;
--
--	serial interface
--
	ser_txd			: out std_logic;
	ser_rxd			: in std_logic;
	ser_ncts		: in std_logic;
	ser_nrts		: out std_logic;

--
--	watchdog
--
	wd		: out std_logic;
	freeio	: out std_logic;

--
--	two ram banks
--
	rama_a		: out std_logic_vector(17 downto 0);
	rama_d		: inout std_logic_vector(15 downto 0);
	rama_ncs	: out std_logic;
	rama_noe	: out std_logic;
	rama_nlb	: out std_logic;
	rama_nub	: out std_logic;
	rama_nwe	: out std_logic;
	ramb_a		: out std_logic_vector(17 downto 0);
	ramb_d		: inout std_logic_vector(15 downto 0);
	ramb_ncs	: out std_logic;
	ramb_noe	: out std_logic;
	ramb_nlb	: out std_logic;
	ramb_nub	: out std_logic;
	ramb_nwe	: out std_logic;

--
--	config/program flash and big nand flash
--
	fl_a	: out std_logic_vector(18 downto 0);
	fl_d	: inout std_logic_vector(7 downto 0);
	fl_ncs	: out std_logic;
	fl_ncsb	: out std_logic;
	fl_noe	: out std_logic;
	fl_nwe	: out std_logic;
	fl_rdy	: in std_logic;

--
--	I/O pins of board
--
	io_b	: inout std_logic_vector(10 downto 1);
	io_l	: inout std_logic_vector(20 downto 1);
	io_r	: inout std_logic_vector(20 downto 1);
	io_t	: inout std_logic_vector(6 downto 1);
--
--	dummy input pins for EP1C6 on board with EP1C12 pinout
--	EP1C12 has additional GND and VCCINT pins.
--
	dummy_gnd		: out std_logic_vector(5 downto 0);
	dummy_vccint	: out std_logic_vector(5 downto 0)
);
end jop;

architecture rtl of jop is

--
--	components:
--

component pll is
generic (multiply_by : natural; divide_by : natural);
port (
	inclk0		: in std_logic;
	c0			: out std_logic
);
end component;

component core is
generic(jpc_width	: integer);			-- address bits of java bytecode pc
port (
	clk, reset	: in std_logic;

-- memio connection

	bsy			: in std_logic;
	din			: in std_logic_vector(31 downto 0);
	ext_addr	: out std_logic_vector(exta_width-1 downto 0);
	rd, wr		: out std_logic;

-- jbc connections

	jbc_addr	: out std_logic_vector(jpc_width-1 downto 0);
	jbc_data	: in std_logic_vector(7 downto 0);

-- interrupt from io

	irq			: in std_logic;
	irq_ena		: in std_logic;

	sp_ov		: out std_logic;

	aout		: out std_logic_vector(31 downto 0);
	bout		: out std_logic_vector(31 downto 0)
);
end component;

component extension is
generic (exta_width : integer);
port (
	clk, reset	: in std_logic;

-- core interface

	ain			: in std_logic_vector(31 downto 0);		-- from stack
	bin			: in std_logic_vector(31 downto 0);		-- from stack
	ext_addr	: in std_logic_vector(exta_width-1 downto 0);
	rd, wr		: in std_logic;
	bsy			: out std_logic;
	dout		: out std_logic_vector(31 downto 0);	-- to stack

-- mem interface

	mem_rd		: out std_logic;
	mem_wr		: out std_logic;
	mem_addr_wr	: out std_logic;
	mem_bc_rd	: out std_logic;
	mem_data	: in std_logic_vector(31 downto 0); 	-- output of memory module
	mem_bcstart	: in std_logic_vector(31 downto 0); 	-- start of method in bc cache
	mem_bsy		: in std_logic;
	
-- io interface

	io_rd		: out std_logic;
	io_wr		: out std_logic;
	io_addr_wr	: out std_logic;
	io_data		: in std_logic_vector(31 downto 0);		-- output of io module

-- io ports that go to the wishbone interface

	wb_io	: inout io_ports

);
end component;


component io is
generic (clk_freq : integer);
port (

-- jop interface

	clk, reset	: in std_logic;

	din			: in std_logic_vector(31 downto 0);

-- interface to mem

	rd, wr		: in std_logic;
	addr_wr		: in std_logic;

	dout		: out std_logic_vector(31 downto 0);

-- interrupt

	irq			: out std_logic;
	irq_ena		: out std_logic;

-- serial interface

	txd			: out std_logic;
	rxd			: in std_logic;
	ncts		: in std_logic;
	nrts		: out std_logic;

-- watch dog

	wd			: out std_logic;

--	I/O pins of board

	b		: inout std_logic_vector(10 downto 1);
	l		: inout std_logic_vector(20 downto 1);
	r		: inout std_logic_vector(20 downto 1);
	t		: inout std_logic_vector(6 downto 1)
);
end component;

--
--	Signals
--
	signal clk_int			: std_logic;

	signal stack_tos		: std_logic_vector(31 downto 0);
	signal stack_nos		: std_logic_vector(31 downto 0);
	signal rd, wr			: std_logic;
	signal ext_addr			: std_logic_vector(exta_width-1 downto 0);
	signal stack_din		: std_logic_vector(31 downto 0);

	signal mem_rd			: std_logic;
	signal mem_wr			: std_logic;
	signal mem_addr_wr		: std_logic;
	signal mem_bc_rd		: std_logic;
	signal mem_dout			: std_logic_vector(31 downto 0);
	signal mem_bcstart		: std_logic_vector(31 downto 0);
	signal mem_bsy			: std_logic;
	signal bsy				: std_logic;

	signal jbc_addr			: std_logic_vector(jpc_width-1 downto 0);
	signal jbc_data			: std_logic_vector(7 downto 0);

	signal sc_addr			: std_logic_vector(17 downto 0);
	signal sc_wr_data		: std_logic_vector(31 downto 0);
	signal sc_rd, sc_wr		: std_logic;
	signal sc_rd_data		: std_logic_vector(31 downto 0);
	signal sc_bsy_cnt		: unsigned(1 downto 0);

-- memory interface

	signal ram_addr			: std_logic_vector(17 downto 0);
	signal ram_dout			: std_logic_vector(31 downto 0);
	signal ram_din			: std_logic_vector(31 downto 0);
	signal ram_dout_en		: std_logic;
	signal ram_ncs			: std_logic;
	signal ram_noe			: std_logic;
	signal ram_nwe			: std_logic;

	signal io_rd			: std_logic;
	signal io_wr			: std_logic;
	signal io_addr_wr		: std_logic;
	signal io_dout			: std_logic_vector(31 downto 0);
	signal io_irq			: std_logic;
	signal io_irq_ena		: std_logic;

	signal int_res			: std_logic;
	signal res_cnt			: unsigned(2 downto 0) := "000";	-- for the simulation

	signal wd_out, sp_ov	: std_logic;

	-- for generation of internal reset
	attribute altera_attribute : string;
	attribute altera_attribute of res_cnt : signal is "POWER_UP_LEVEL=LOW";

begin

--
--	intern reset
--	no extern reset, epm7064 has too less pins
--

process(clk_int)
begin
	if rising_edge(clk_int) then
		if (res_cnt/="111") then
			res_cnt <= res_cnt+1;
		end if;

		int_res <= not res_cnt(0) or not res_cnt(1) or not res_cnt(2);
	end if;
end process;

--
--	components of jop
--
	pll_inst : pll generic map(
		multiply_by => pll_mult,
		divide_by => pll_div
	)
	port map (
		inclk0	 => clk,
		c0	 => clk_int
	);
-- clk_int <= clk;

	-- sp_ov indicates stack overflow
	-- We can use the wd LED
	-- wd <= sp_ov;
	wd <= wd_out;

	cmp_core: core generic map(jpc_width)
		port map (clk_int, int_res,
			bsy,
			stack_din, ext_addr,
			rd, wr,
			jbc_addr, jbc_data,
			io_irq, io_irq_ena,
			sp_ov,
			stack_tos, stack_nos
		);

	cmp_ext: extension generic map (exta_width)
		port map (clk_int, int_res, stack_tos, stack_nos,
			ext_addr, rd, wr, bsy, stack_din,
			mem_rd, mem_wr, mem_addr_wr, mem_bc_rd,
			mem_dout, mem_bcstart, mem_bsy,
			io_rd, io_wr, io_addr_wr, io_dout,
			wb_io.b => io_b,
			wb_io.l => io_l,
			wb_io.r => io_r,
			wb_io.t => io_t
		);

	cmp_mem: entity work.mem_sc
		generic map (
			jpc_width => jpc_width,
			block_bits => block_bits,
			addr_bits => 18
		)
		port map (
			clk => clk_int,
			reset => int_res,
			din => stack_tos,

			mem_rd => mem_rd,
			mem_wr => mem_wr,
			mem_addr_wr => mem_addr_wr,
			mem_bc_rd => mem_bc_rd,
			dout => mem_dout,
			bcstart => mem_bcstart,
			bsy => mem_bsy,

			jbc_addr => jbc_addr,
			jbc_data => jbc_data,

			addr => sc_addr,
			wr_data => sc_wr_data,
			rd => sc_rd,
			wr => sc_wr,
			rd_data => sc_rd_data,
			bsy_cnt => sc_bsy_cnt
		);

	cmp_scm: entity work.sc_mem_if
		generic map (
			ram_ws => ram_cnt-1,
			rom_cnt => rom_cnt,
			addr_bits => 18
		)
		port map (
			clk => clk_int,
			reset => int_res,

			addr => sc_addr,
			wr_data => sc_wr_data,
			rd => sc_rd,
			wr => sc_wr,
			rd_data => sc_rd_data,
			bsy_cnt => sc_bsy_cnt,

			ram_addr => ram_addr,
			ram_dout => ram_dout,
			ram_din => ram_din,
			ram_dout_en	=> ram_dout_en,
			ram_ncs => ram_ncs,
			ram_noe => ram_noe,
			ram_nwe => ram_nwe,

			fl_a => fl_a,
			fl_d => fl_d,
			fl_ncs => fl_ncs,
			fl_ncsb => fl_ncsb,
			fl_noe => fl_noe,
			fl_nwe => fl_nwe,
			fl_rdy => fl_rdy

		);

	process(ram_dout_en, ram_dout)
	begin
		if ram_dout_en='1' then
			rama_d <= ram_dout(15 downto 0);
			ramb_d <= ram_dout(31 downto 16);
		else
			rama_d <= (others => 'Z');
			ramb_d <= (others => 'Z');
		end if;
	end process;

	ram_din <= ramb_d & rama_d;

--
--	To put this RAM address in an output register
--	we have to make an assignment (FAST_OUTPUT_REGISTER)
--
	rama_a <= ram_addr;
	rama_ncs <= ram_ncs;
	rama_noe <= ram_noe;
	rama_nwe <= ram_nwe;
	rama_nlb <= '0';
	rama_nub <= '0';

	ramb_a <= ram_addr;
	ramb_ncs <= ram_ncs;
	ramb_noe <= ram_noe;
	ramb_nwe <= ram_nwe;
	ramb_nlb <= '0';
	ramb_nub <= '0';


	cmp_io: io generic map (clk_freq)
		port map (clk_int, int_res, stack_tos,
			io_rd, io_wr, io_addr_wr, io_dout,
			io_irq, io_irq_ena,
			ser_txd, ser_rxd, ser_ncts, ser_nrts,
			wd_out,
			io_b, io_l, io_r, io_t
		);



--
--	EP1C12 additional power pins as tristatet output on EP1C6
--
	dummy_gnd <= (others => 'Z');
	dummy_vccint <= (others => 'Z');
	freeio <= 'Z';

end rtl;
