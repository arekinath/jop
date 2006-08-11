//
//	memser.asm
//
//		memory test, write memory content to serial line
//

//
//	io address
//
io_cnt		=	-128
io_wd		=	-125
io_status	=	-112
io_uart		=	-111

ua_rdrf		= 	2
ua_tdre		= 	1

//
//	first vars for start
//
	mp		?		// pointer to method struct (two words in cpool)
	cp		?		// pointer to constants
	heap	?		// start of heap

	extbc	?		// flag if bc load is neccessary

//
//	local vars
//
a			?
b			?
c			?


//
//	but starts with pc=0!!! (so init bc is not really necassary)
//
			nop
			nop
			ldi	127
			nop			// written in adr/read stage!
			stsp




loop_cnt	= 32768

loop:
			ldi 0
			stm	a

// ldi 1
// nop
// bnz rd_loop
// nop
// nop

			ldi	io_wd
			stmwa
			ldi	1
			stmwd
			wait
			wait
wr_loop:

sys_wr_mem:
			ldm	a
			stmwa				// write ext. mem address
			ldm a
			stmwd				// write ext. mem data
			wait
			wait

			ldm	a
			ldi	1
			add
			stm	a

			ldm	a
			ldi	loop_cnt
			xor
			nop
			bnz	wr_loop
			nop
			nop


			ldi 0
			stm	a

			ldi	io_wd
			stmwa
			ldi	0
			stmwd
			wait
			wait

rd_loop:


sys_rd_mem:
			ldm	a
			stmra
			wait
			wait
			ldmrd		 		// read ext. mem

			stm	b

ser0:
			ldi	io_status
			stmra
			ldi	ua_tdre
			wait
			wait
			ldmrd
			and
			nop
			bz	ser0			
			nop
			nop
			
			ldi	io_uart
			stmwa
			ldm	b
			stmwd
			wait
			wait


			ldm	a
			ldi	1
			add
			stm	a

			ldm	a
			ldi	loop_cnt
			xor
			nop
			bnz	rd_loop
			nop
			nop

			ldi	1
			nop
			bnz	loop
			nop
			nop
