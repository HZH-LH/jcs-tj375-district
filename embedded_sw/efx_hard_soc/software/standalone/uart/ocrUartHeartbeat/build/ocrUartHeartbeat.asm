
build/ocrUartHeartbeat.elf:     file format elf32-littleriscv


Disassembly of section .init:

f9000000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
f9000000:	00001197          	auipc	gp,0x1
f9000004:	9e018193          	addi	gp,gp,-1568 # f90009e0 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
f9000008:	8201a023          	sw	zero,-2016(gp) # f9000200 <smp_lottery_lock>

f900000c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
f900000c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
f9000010:	c515                	beqz	a0,f900003c <init>

f9000012 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
f9000012:	8201a503          	lw	a0,-2016(gp) # f9000200 <smp_lottery_lock>
	beqz a0, smp_slave
f9000016:	dd75                	beqz	a0,f9000012 <smp_slave>

	fence r, r
f9000018:	0220000f          	fence	r,r
f900001c:	0000100f          	fence.i
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
f9000020:	81c1a783          	lw	a5,-2020(gp) # f90001fc <__bss_start>
	li a0, 0
f9000024:	4501                	li	a0,0
	li a1, 0
f9000026:	4581                	li	a1,0
	li a2, 0
f9000028:	4601                	li	a2,0
	jr a5
f900002a:	8782                	jr	a5

f900002c <smp_unlock>:

.global   smp_unlock
.type    smp_unlock,%function
smp_unlock:
	sw a0, smp_lottery_target, a1
f900002c:	80a1ae23          	sw	a0,-2020(gp) # f90001fc <__bss_start>
	fence w, w
f9000030:	0110000f          	fence	w,w
	li a0, 1
f9000034:	4505                	li	a0,1
	sw a0, smp_lottery_lock, a1
f9000036:	82a1a023          	sw	a0,-2016(gp) # f9000200 <smp_lottery_lock>
    ret
f900003a:	8082                	ret

f900003c <init>:
#endif

init:
	la sp, _sp
f900003c:	93018113          	addi	sp,gp,-1744 # f9000310 <_sp>

	/* Load data section */
	la a0, _data_lma
f9000040:	00000517          	auipc	a0,0x0
f9000044:	18850513          	addi	a0,a0,392 # f90001c8 <_data>
	la a1, _data
f9000048:	00000597          	auipc	a1,0x0
f900004c:	18058593          	addi	a1,a1,384 # f90001c8 <_data>
	la a2, _edata
f9000050:	81c18613          	addi	a2,gp,-2020 # f90001fc <__bss_start>
	bgeu a1, a2, 2f
f9000054:	00c5fa63          	bgeu	a1,a2,f9000068 <init+0x2c>
1:
	lw t0, (a0)
f9000058:	00052283          	lw	t0,0(a0)
	sw t0, (a1)
f900005c:	0055a023          	sw	t0,0(a1)
	addi a0, a0, 4
f9000060:	0511                	addi	a0,a0,4
	addi a1, a1, 4
f9000062:	0591                	addi	a1,a1,4
	bltu a1, a2, 1b
f9000064:	fec5eae3          	bltu	a1,a2,f9000058 <init+0x1c>
2:

	/* Clear bss section */
	la a0, __bss_start
f9000068:	81c18513          	addi	a0,gp,-2020 # f90001fc <__bss_start>
	la a1, _end
f900006c:	82818593          	addi	a1,gp,-2008 # f9000208 <_end>
	bgeu a0, a1, 2f
f9000070:	00b57763          	bgeu	a0,a1,f900007e <init+0x42>
1:
	sw zero, (a0)
f9000074:	00052023          	sw	zero,0(a0)
	addi a0, a0, 4
f9000078:	0511                	addi	a0,a0,4
	bltu a0, a1, 1b
f900007a:	feb56de3          	bltu	a0,a1,f9000074 <init+0x38>
2:

#ifndef NO_LIBC_INIT_ARRAY
	call __libc_init_array
f900007e:	20c5                	jal	f900015e <__libc_init_array>
#endif

	call main
f9000080:	2075                	jal	f900012c <main>

f9000082 <mainDone>:
mainDone:
    j mainDone
f9000082:	a001                	j	f9000082 <mainDone>

f9000084 <_init>:


	.globl _init
_init:
    ret
f9000084:	8082                	ret

Disassembly of section .text:

f9000086 <uart_writeAvailability>:
#include "type.h"
#include "soc.h"


    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
f9000086:	4148                	lw	a0,4(a0)
*          of available spaces for writing data from bits 23 to 16. It then
*          returns this value after masking with 0xFF.
*
******************************************************************************/
    static u32 uart_writeAvailability(u32 reg){
        return (read_u32(reg + UART_STATUS) >> 16) & 0xFF;
f9000088:	8141                	srli	a0,a0,0x10
    }
f900008a:	0ff57513          	andi	a0,a0,255
f900008e:	8082                	ret

f9000090 <uart_write>:
* @note    The function waits until there is available space in the UART buffer
*          for writing data. Once space is available, it writes the character
*          data to the UART data register.
*
******************************************************************************/
    static void uart_write(u32 reg, char data){
f9000090:	1141                	addi	sp,sp,-16
f9000092:	c606                	sw	ra,12(sp)
f9000094:	c422                	sw	s0,8(sp)
f9000096:	c226                	sw	s1,4(sp)
f9000098:	842a                	mv	s0,a0
f900009a:	84ae                	mv	s1,a1
        while(uart_writeAvailability(reg) == 0);
f900009c:	8522                	mv	a0,s0
f900009e:	37e5                	jal	f9000086 <uart_writeAvailability>
f90000a0:	dd75                	beqz	a0,f900009c <uart_write+0xc>
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
f90000a2:	c004                	sw	s1,0(s0)
        write_u32(data, reg + UART_DATA);
    }
f90000a4:	40b2                	lw	ra,12(sp)
f90000a6:	4422                	lw	s0,8(sp)
f90000a8:	4492                	lw	s1,4(sp)
f90000aa:	0141                	addi	sp,sp,16
f90000ac:	8082                	ret

f90000ae <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
f90000ae:	45dc                	lw	a5,12(a1)
f90000b0:	c51c                	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
f90000b2:	419c                	lw	a5,0(a1)
f90000b4:	17fd                	addi	a5,a5,-1
f90000b6:	41d8                	lw	a4,4(a1)
f90000b8:	0722                	slli	a4,a4,0x8
f90000ba:	8fd9                	or	a5,a5,a4
f90000bc:	4598                	lw	a4,8(a1)
f90000be:	0742                	slli	a4,a4,0x10
f90000c0:	8fd9                	or	a5,a5,a4
f90000c2:	c55c                	sw	a5,12(a0)
    }
f90000c4:	8082                	ret

f90000c6 <clint_uDelay>:
*          and the time limit is non-negative, indicating that the delay has
*          not yet elapsed.
*
******************************************************************************/
    static void clint_uDelay(u32 usec, u32 hz, u32 reg){
        u32 mTimePerUsec = hz/1000000;
f90000c6:	000f47b7          	lui	a5,0xf4
f90000ca:	24078793          	addi	a5,a5,576 # f4240 <__stack_size+0xf4140>
f90000ce:	02f5d5b3          	divu	a1,a1,a5
    readReg_u32 (clint_getTimeLow , CLINT_TIME_ADDR)
f90000d2:	67b1                	lui	a5,0xc
f90000d4:	17e1                	addi	a5,a5,-8
f90000d6:	963e                	add	a2,a2,a5
        return *((volatile u32*) address);
f90000d8:	421c                	lw	a5,0(a2)
        u32 limit = clint_getTimeLow(reg) + usec*mTimePerUsec;
f90000da:	02a58533          	mul	a0,a1,a0
f90000de:	953e                	add	a0,a0,a5
f90000e0:	421c                	lw	a5,0(a2)
        while((int32_t)(limit-(clint_getTimeLow(reg))) >= 0);
f90000e2:	40f507b3          	sub	a5,a0,a5
f90000e6:	fe07dde3          	bgez	a5,f90000e0 <clint_uDelay+0x1a>
f90000ea:	8082                	ret

f90000ec <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
f90000ec:	1101                	addi	sp,sp,-32
f90000ee:	ce06                	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
f90000f0:	47a1                	li	a5,8
f90000f2:	c03e                	sw	a5,0(sp)
        uartConfig.parity       = NONE;
f90000f4:	c202                	sw	zero,4(sp)
        uartConfig.stop         = ONE;
f90000f6:	c402                	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
f90000f8:	10e00793          	li	a5,270
f90000fc:	c63e                	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
f90000fe:	858a                	mv	a1,sp
f9000100:	e8010537          	lui	a0,0xe8010
f9000104:	376d                	jal	f90000ae <uart_applyConfig>
    }
f9000106:	40f2                	lw	ra,28(sp)
f9000108:	6105                	addi	sp,sp,32
f900010a:	8082                	ret

f900010c <uart_puts>:
#include "bsp.h"

static void uart_puts(const char *text)
{
f900010c:	1141                	addi	sp,sp,-16
f900010e:	c606                	sw	ra,12(sp)
f9000110:	c422                	sw	s0,8(sp)
f9000112:	842a                	mv	s0,a0
    while (*text) {
f9000114:	00044583          	lbu	a1,0(s0)
f9000118:	c591                	beqz	a1,f9000124 <uart_puts+0x18>
        uart_write(BSP_UART_TERMINAL, *text++);
f900011a:	0405                	addi	s0,s0,1
f900011c:	e8010537          	lui	a0,0xe8010
f9000120:	3f85                	jal	f9000090 <uart_write>
f9000122:	bfcd                	j	f9000114 <uart_puts+0x8>
    }
}
f9000124:	40b2                	lw	ra,12(sp)
f9000126:	4422                	lw	s0,8(sp)
f9000128:	0141                	addi	sp,sp,16
f900012a:	8082                	ret

f900012c <main>:

void main(void)
{
f900012c:	1141                	addi	sp,sp,-16
f900012e:	c606                	sw	ra,12(sp)
    bsp_init();
f9000130:	3f75                	jal	f90000ec <bsp_init>
    uart_puts("RISCV_OCR_BOOT\r\n");
f9000132:	f9000537          	lui	a0,0xf9000
f9000136:	1c850513          	addi	a0,a0,456 # f90001c8 <__global_pointer$+0xfffff7e8>
f900013a:	3fc9                	jal	f900010c <uart_puts>

    while (1) {
        uart_puts("RISCV_OCR_ALIVE\r\n");
f900013c:	f9000537          	lui	a0,0xf9000
f9000140:	1dc50513          	addi	a0,a0,476 # f90001dc <__global_pointer$+0xfffff7fc>
f9000144:	37e1                	jal	f900010c <uart_puts>
        bsp_uDelay(1000000);
f9000146:	f8b00637          	lui	a2,0xf8b00
f900014a:	0ee6b5b7          	lui	a1,0xee6b
f900014e:	28058593          	addi	a1,a1,640 # ee6b280 <__stack_size+0xee6b180>
f9000152:	000f4537          	lui	a0,0xf4
f9000156:	24050513          	addi	a0,a0,576 # f4240 <__stack_size+0xf4140>
f900015a:	37b5                	jal	f90000c6 <clint_uDelay>
f900015c:	b7c5                	j	f900013c <main+0x10>

f900015e <__libc_init_array>:
f900015e:	1141                	addi	sp,sp,-16
f9000160:	c422                	sw	s0,8(sp)
f9000162:	c04a                	sw	s2,0(sp)
f9000164:	00000417          	auipc	s0,0x0
f9000168:	06440413          	addi	s0,s0,100 # f90001c8 <_data>
f900016c:	00000917          	auipc	s2,0x0
f9000170:	05c90913          	addi	s2,s2,92 # f90001c8 <_data>
f9000174:	40890933          	sub	s2,s2,s0
f9000178:	c606                	sw	ra,12(sp)
f900017a:	c226                	sw	s1,4(sp)
f900017c:	40295913          	srai	s2,s2,0x2
f9000180:	00090963          	beqz	s2,f9000192 <__libc_init_array+0x34>
f9000184:	4481                	li	s1,0
f9000186:	401c                	lw	a5,0(s0)
f9000188:	0485                	addi	s1,s1,1
f900018a:	0411                	addi	s0,s0,4
f900018c:	9782                	jalr	a5
f900018e:	fe991ce3          	bne	s2,s1,f9000186 <__libc_init_array+0x28>
f9000192:	00000417          	auipc	s0,0x0
f9000196:	03640413          	addi	s0,s0,54 # f90001c8 <_data>
f900019a:	00000917          	auipc	s2,0x0
f900019e:	02e90913          	addi	s2,s2,46 # f90001c8 <_data>
f90001a2:	40890933          	sub	s2,s2,s0
f90001a6:	40295913          	srai	s2,s2,0x2
f90001aa:	00090963          	beqz	s2,f90001bc <__libc_init_array+0x5e>
f90001ae:	4481                	li	s1,0
f90001b0:	401c                	lw	a5,0(s0)
f90001b2:	0485                	addi	s1,s1,1
f90001b4:	0411                	addi	s0,s0,4
f90001b6:	9782                	jalr	a5
f90001b8:	fe991ce3          	bne	s2,s1,f90001b0 <__libc_init_array+0x52>
f90001bc:	40b2                	lw	ra,12(sp)
f90001be:	4422                	lw	s0,8(sp)
f90001c0:	4492                	lw	s1,4(sp)
f90001c2:	4902                	lw	s2,0(sp)
f90001c4:	0141                	addi	sp,sp,16
f90001c6:	8082                	ret
