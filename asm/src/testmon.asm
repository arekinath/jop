//
//	testmon.asm
//
//	Test monitor.
//

//
//	io address
//
io_cnt		=	0
io_wd		=	3
io_status	=	4
io_uart		=	5

ua_rdrf		= 	2
ua_tdre		= 	1

//
//	first vars for start
//
	mp		?			// pointer to method struct (two words in cpool)
	cp		?			// pointer to constants
	heap		?			// start of heap

	extbc		?			// flag if bc load is neccessary

//
//	local vars
//
	a		?
	b		?
	c		?

	addr		?			// address used for bc load from flash
	
	kchar		?
	mema		?
	wval		?
	jbc_flag	?


//
//	special byte codes
//	but starts with pc=0!!! (so init bc is not really necassary)
//
			nop			// this gets never executed
			nop			// for shure during reset (perhaps two times executed)
sys_init:
			ldi	127
			nop			// written in adr/read stage!
			stsp			// someting strange in stack.vhd A->B !!!

			ldi	0
			stm	mema
			
			ldi	0
			stm	jbc_flag

new_line:
			ldm	jbc_flag
			nop
			bnz	do_jbc_mem
			nop
			nop
			
			ldm	mema
			stmra			// read ext. mem, mem_bsy comes one cycle later
			nop
			wait
			wait
			ldmrd		 	// read ext. mem

			stm	wval
			
			ldi	0
			ldi	62		// >
			
			ldi	1
			nop
			bnz	make_prompt
			nop
			nop

do_jbc_mem:
			
			ldm	mema
			stjpc			// get first byte code
			nop			// ???
			nop	opd		// bytecode is in operand register, autoincrement jpc
			ld_opd_8s		// should be 8u (ld_opd_8s does sign extension)
			ldi	255
			and
			stm	wval

			ldi	0
			ldi	62		// >
			ldi	67		// C
			ldi	66		// B
			ldi	74		// J
			ldi	58		// :

make_prompt:
			ldi	0
			stm	c
wval_loop:
			ldm	wval
			ldm	c
			shr
			ldi	15
			and
			ldi	48
			add
			dup
			ldi	58
			sub
			ldi	-2147483648 //  0x80000000
			and
			nop
			bnz	skip1
			nop
			nop
			ldi	7
			add
skip1:
			ldm	c
			ldi	4
			add
			dup
			stm	c
			ldi	32
			sub
			nop
			bnz	wval_loop
			nop
			nop
			
			ldi	61

			ldi	0
			stm	c
mema_loop:
			ldm	mema
			ldm	c
			shr
			ldi	15
			and
			ldi	48
			add
			dup
			ldi	58
			sub
			ldi	-2147483648 //  0x80000000
			and
			nop
			bnz	skip2
			nop
			nop
			ldi	7
			add
skip2:
			ldm	c
			ldi	4
			add
			dup
			stm	c
			ldi	32
			sub
			nop
			bnz	mema_loop
			nop
			nop
			
			ldi	10
			ldi	13

prompt_loop:
			ldi	io_status
			stioa
			ldi	ua_tdre
			ldiod
			and
			nop
			bz	prompt_loop
			nop
			nop
			
			ldi	io_uart
			stioa
			nop
			stiod
			
			dup
			nop
			bnz	prompt_loop
			nop
			nop

			pop
			ldi	0
			stm	wval
			
key_loop:
			ldi	io_status
			stioa
			ldi	ua_rdrf
			ldiod
			and
			nop
			bz	key_loop			
			nop
			nop
			
			ldi io_uart 		// read byte from uart
			stioa
			nop
			ldiod
			dup 			// echo
			nop
			nop
			nop
			stiod

			dup
			stm	kchar
			ldi	13		// CR key
			sub
			nop
			bz	new_line
			nop
			nop
			
			ldm	kchar
			ldi	95
			and
			ldi	74		// J key
			sub
			nop
			bnz	chk_addr_key
			nop
			nop
			
			ldm	jbc_flag
			ldi	1
			xor
			stm	jbc_flag	
			
			ldi	1
			nop
			bnz	new_line
			nop
			nop

chk_addr_key:
			ldm	kchar
			ldi	61		// = (equals) key
			sub
			nop
			bnz	chk_write_key
			nop
			nop
			
			ldm	wval
			stm	mema
			
			ldi	0
			stm	wval
			
			ldi	1
			nop
			bnz	key_loop
			nop
			nop
			
chk_write_key:
			ldm	kchar
			ldi	59		// ; (semicolon) key
			sub
			nop
			bnz	do_digit_key
			nop
			nop
			
			ldm	jbc_flag
			nop
			bnz	do_jbc_write
			nop
			nop
			
			ldm	mema
			stmwa			// write ext. mem address
			ldm	wval
			stmwd			// write ext. mem data
			nop
			wait
			wait
			
			ldi	0
			stm	wval
			
			ldi	1
			nop
			bnz	key_loop
			nop
			nop
			

do_jbc_write:
			ldm	mema
			stjpc
			ldm	wval
			stbc			// one 32 bit word takes four cycles
			nop
			nop
			nop

			ldi	0
			stm	wval
			
			ldi	1
			nop
			bnz	key_loop
			nop
			nop
			

do_digit_key:
			ldm	kchar
			dup
			ldi	64
			and
			nop
			bz	st_nibble
			nop
			nop
			
			ldi	9
			add
			
st_nibble:
			ldi	15
			and
			ldm	wval
			ldi	4
			shl

			or
			stm	wval
			
			ldi	1
			nop
			bnz	key_loop
			nop
			nop
