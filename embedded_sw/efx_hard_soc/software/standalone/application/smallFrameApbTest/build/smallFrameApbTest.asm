
build/smallFrameApbTest.elf:     file format elf32-littleriscv


Disassembly of section .init:

f9000000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
f9000000:	00001197          	auipc	gp,0x1
f9000004:	c5018193          	addi	gp,gp,-944 # f9000c50 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
f9000008:	8201a023          	sw	zero,-2016(gp) # f9000470 <smp_lottery_lock>

f900000c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
f900000c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
f9000010:	c515                	beqz	a0,f900003c <init>

f9000012 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
f9000012:	8201a503          	lw	a0,-2016(gp) # f9000470 <smp_lottery_lock>
	beqz a0, smp_slave
f9000016:	dd75                	beqz	a0,f9000012 <smp_slave>

	fence r, r
f9000018:	0220000f          	fence	r,r
f900001c:	0000100f          	fence.i
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
f9000020:	81c1a783          	lw	a5,-2020(gp) # f900046c <__bss_start>
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
f900002c:	80a1ae23          	sw	a0,-2020(gp) # f900046c <__bss_start>
	fence w, w
f9000030:	0110000f          	fence	w,w
	li a0, 1
f9000034:	4505                	li	a0,1
	sw a0, smp_lottery_lock, a1
f9000036:	82a1a023          	sw	a0,-2016(gp) # f9000470 <smp_lottery_lock>
    ret
f900003a:	8082                	ret

f900003c <init>:
#endif

init:
	la sp, _sp
f900003c:	03018113          	addi	sp,gp,48 # f9000c80 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
f9000040:	00000517          	auipc	a0,0x0
f9000044:	40850513          	addi	a0,a0,1032 # f9000448 <_data>
	la a1, _data
f9000048:	00000597          	auipc	a1,0x0
f900004c:	40058593          	addi	a1,a1,1024 # f9000448 <_data>
	la a2, _edata
f9000050:	81c18613          	addi	a2,gp,-2020 # f900046c <__bss_start>
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
f9000068:	81c18513          	addi	a0,gp,-2020 # f900046c <__bss_start>
	la a1, _end
f900006c:	82818593          	addi	a1,gp,-2008 # f9000478 <_end>
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
f900007e:	2021                	jal	f9000086 <__libc_init_array>
#endif

	call main
f9000080:	2c7d                	jal	f900033e <main>

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

f9000086 <__libc_init_array>:
f9000086:	1141                	addi	sp,sp,-16
f9000088:	c422                	sw	s0,8(sp)
f900008a:	c04a                	sw	s2,0(sp)
f900008c:	00000417          	auipc	s0,0x0
f9000090:	3bc40413          	addi	s0,s0,956 # f9000448 <_data>
f9000094:	00000917          	auipc	s2,0x0
f9000098:	3b490913          	addi	s2,s2,948 # f9000448 <_data>
f900009c:	40890933          	sub	s2,s2,s0
f90000a0:	c606                	sw	ra,12(sp)
f90000a2:	c226                	sw	s1,4(sp)
f90000a4:	40295913          	srai	s2,s2,0x2
f90000a8:	00090963          	beqz	s2,f90000ba <__libc_init_array+0x34>
f90000ac:	4481                	li	s1,0
f90000ae:	401c                	lw	a5,0(s0)
f90000b0:	0485                	addi	s1,s1,1
f90000b2:	0411                	addi	s0,s0,4
f90000b4:	9782                	jalr	a5
f90000b6:	fe991ce3          	bne	s2,s1,f90000ae <__libc_init_array+0x28>
f90000ba:	00000417          	auipc	s0,0x0
f90000be:	38e40413          	addi	s0,s0,910 # f9000448 <_data>
f90000c2:	00000917          	auipc	s2,0x0
f90000c6:	38690913          	addi	s2,s2,902 # f9000448 <_data>
f90000ca:	40890933          	sub	s2,s2,s0
f90000ce:	40295913          	srai	s2,s2,0x2
f90000d2:	00090963          	beqz	s2,f90000e4 <__libc_init_array+0x5e>
f90000d6:	4481                	li	s1,0
f90000d8:	401c                	lw	a5,0(s0)
f90000da:	0485                	addi	s1,s1,1
f90000dc:	0411                	addi	s0,s0,4
f90000de:	9782                	jalr	a5
f90000e0:	fe991ce3          	bne	s2,s1,f90000d8 <__libc_init_array+0x52>
f90000e4:	40b2                	lw	ra,12(sp)
f90000e6:	4422                	lw	s0,8(sp)
f90000e8:	4492                	lw	s1,4(sp)
f90000ea:	4902                	lw	s2,0(sp)
f90000ec:	0141                	addi	sp,sp,16
f90000ee:	8082                	ret

f90000f0 <uart_writeAvailability>:
#include "type.h"
#include "soc.h"


    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
f90000f0:	4148                	lw	a0,4(a0)
*          of available spaces for writing data from bits 23 to 16. It then
*          returns this value after masking with 0xFF.
*
******************************************************************************/
    static u32 uart_writeAvailability(u32 reg){
        return (read_u32(reg + UART_STATUS) >> 16) & 0xFF;
f90000f2:	8141                	srli	a0,a0,0x10
    }
f90000f4:	0ff57513          	andi	a0,a0,255
f90000f8:	8082                	ret

f90000fa <uart_readOccupancy>:
f90000fa:	4148                	lw	a0,4(a0)
*          of occupied spaces for reading data from bits 31 to 24.
*
******************************************************************************/
    static u32 uart_readOccupancy(u32 reg){
        return read_u32(reg + UART_STATUS) >> 24;
    }
f90000fc:	8161                	srli	a0,a0,0x18
f90000fe:	8082                	ret

f9000100 <uart_write>:
* @note    The function waits until there is available space in the UART buffer
*          for writing data. Once space is available, it writes the character
*          data to the UART data register.
*
******************************************************************************/
    static void uart_write(u32 reg, char data){
f9000100:	1141                	addi	sp,sp,-16
f9000102:	c606                	sw	ra,12(sp)
f9000104:	c422                	sw	s0,8(sp)
f9000106:	c226                	sw	s1,4(sp)
f9000108:	842a                	mv	s0,a0
f900010a:	84ae                	mv	s1,a1
        while(uart_writeAvailability(reg) == 0);
f900010c:	8522                	mv	a0,s0
f900010e:	37cd                	jal	f90000f0 <uart_writeAvailability>
f9000110:	dd75                	beqz	a0,f900010c <uart_write+0xc>
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
f9000112:	c004                	sw	s1,0(s0)
        write_u32(data, reg + UART_DATA);
    }
f9000114:	40b2                	lw	ra,12(sp)
f9000116:	4422                	lw	s0,8(sp)
f9000118:	4492                	lw	s1,4(sp)
f900011a:	0141                	addi	sp,sp,16
f900011c:	8082                	ret

f900011e <uart_writeStr>:
*
* @note    The function iterates through each character of the string and writes
*          them one by one to the UART buffer using the uart_write function.
*
******************************************************************************/
    static void uart_writeStr(u32 reg, const char* str){
f900011e:	1141                	addi	sp,sp,-16
f9000120:	c606                	sw	ra,12(sp)
f9000122:	c422                	sw	s0,8(sp)
f9000124:	c226                	sw	s1,4(sp)
f9000126:	84aa                	mv	s1,a0
f9000128:	842e                	mv	s0,a1
        while(*str) uart_write(reg, *str++);
f900012a:	00044583          	lbu	a1,0(s0)
f900012e:	c589                	beqz	a1,f9000138 <uart_writeStr+0x1a>
f9000130:	0405                	addi	s0,s0,1
f9000132:	8526                	mv	a0,s1
f9000134:	37f1                	jal	f9000100 <uart_write>
f9000136:	bfd5                	j	f900012a <uart_writeStr+0xc>
    }
f9000138:	40b2                	lw	ra,12(sp)
f900013a:	4422                	lw	s0,8(sp)
f900013c:	4492                	lw	s1,4(sp)
f900013e:	0141                	addi	sp,sp,16
f9000140:	8082                	ret

f9000142 <uart_read>:
* @note    The function waits until there is data available in the UART buffer
*          for reading. Once data is available, it reads the character data from
*          the UART data register and returns it.
*
******************************************************************************/
    static char uart_read(u32 reg){
f9000142:	1141                	addi	sp,sp,-16
f9000144:	c606                	sw	ra,12(sp)
f9000146:	c422                	sw	s0,8(sp)
f9000148:	842a                	mv	s0,a0
        while(uart_readOccupancy(reg) == 0);
f900014a:	8522                	mv	a0,s0
f900014c:	377d                	jal	f90000fa <uart_readOccupancy>
f900014e:	dd75                	beqz	a0,f900014a <uart_read+0x8>
        return *((volatile u32*) address);
f9000150:	4008                	lw	a0,0(s0)
        return read_u32(reg + UART_DATA);
    }
f9000152:	0ff57513          	andi	a0,a0,255
f9000156:	40b2                	lw	ra,12(sp)
f9000158:	4422                	lw	s0,8(sp)
f900015a:	0141                	addi	sp,sp,16
f900015c:	8082                	ret

f900015e <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
f900015e:	45dc                	lw	a5,12(a1)
        *((volatile u32*) address) = data;
f9000160:	c51c                	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
f9000162:	419c                	lw	a5,0(a1)
f9000164:	17fd                	addi	a5,a5,-1
f9000166:	41d8                	lw	a4,4(a1)
f9000168:	0722                	slli	a4,a4,0x8
f900016a:	8fd9                	or	a5,a5,a4
f900016c:	4598                	lw	a4,8(a1)
f900016e:	0742                	slli	a4,a4,0x10
f9000170:	8fd9                	or	a5,a5,a4
f9000172:	c55c                	sw	a5,12(a0)
    }
f9000174:	8082                	ret

f9000176 <clint_uDelay>:
*          and the time limit is non-negative, indicating that the delay has
*          not yet elapsed.
*
******************************************************************************/
    static void clint_uDelay(u32 usec, u32 hz, u32 reg){
        u32 mTimePerUsec = hz/1000000;
f9000176:	000f47b7          	lui	a5,0xf4
f900017a:	24078793          	addi	a5,a5,576 # f4240 <__stack_size+0xf3a40>
f900017e:	02f5d5b3          	divu	a1,a1,a5
    readReg_u32 (clint_getTimeLow , CLINT_TIME_ADDR)
f9000182:	67b1                	lui	a5,0xc
f9000184:	17e1                	addi	a5,a5,-8
f9000186:	963e                	add	a2,a2,a5
        return *((volatile u32*) address);
f9000188:	421c                	lw	a5,0(a2)
        u32 limit = clint_getTimeLow(reg) + usec*mTimePerUsec;
f900018a:	02a58533          	mul	a0,a1,a0
f900018e:	953e                	add	a0,a0,a5
f9000190:	421c                	lw	a5,0(a2)
        while((int32_t)(limit-(clint_getTimeLow(reg))) >= 0);
f9000192:	40f507b3          	sub	a5,a0,a5
f9000196:	fe07dde3          	bgez	a5,f9000190 <clint_uDelay+0x1a>
f900019a:	8082                	ret

f900019c <reg_read>:
#define STREAM_RISCV         1u
#define STREAM_FPGA          2u

static uint32_t reg_read(uint32_t offset)
{
    return *((volatile uint32_t *)(FRAME_APB_BASE + offset));
f900019c:	e81007b7          	lui	a5,0xe8100
f90001a0:	953e                	add	a0,a0,a5
f90001a2:	4108                	lw	a0,0(a0)
}
f90001a4:	8082                	ret

f90001a6 <reg_write>:

static void reg_write(uint32_t offset, uint32_t value)
{
    *((volatile uint32_t *)(FRAME_APB_BASE + offset)) = value;
f90001a6:	e81007b7          	lui	a5,0xe8100
f90001aa:	953e                	add	a0,a0,a5
f90001ac:	c10c                	sw	a1,0(a0)
}
f90001ae:	8082                	ret

f90001b0 <uart_config_debug_baud>:

static void uart_config_debug_baud(uint32_t uart)
{
f90001b0:	1101                	addi	sp,sp,-32
f90001b2:	ce06                	sw	ra,28(sp)
    Uart_Config config;

    config.dataLength = BITS_8;
f90001b4:	47a1                	li	a5,8
f90001b6:	c03e                	sw	a5,0(sp)
    config.parity = NONE;
f90001b8:	c202                	sw	zero,4(sp)
    config.stop = ONE;
f90001ba:	c402                	sw	zero,8(sp)
    config.clockDivider = BSP_CLINT_HZ /
f90001bc:	03d00793          	li	a5,61
f90001c0:	c63e                	sw	a5,12(sp)
                          (UART_BAUDRATE * UART_SAMPLE_PER_BIT) - 1u;
    uart_applyConfig(uart, &config);
f90001c2:	858a                	mv	a1,sp
f90001c4:	3f69                	jal	f900015e <uart_applyConfig>
}
f90001c6:	40f2                	lw	ra,28(sp)
f90001c8:	6105                	addi	sp,sp,32
f90001ca:	8082                	ret

f90001cc <uart0_write_byte_blocking>:
static void uart0_write_byte_blocking(uint8_t value)
{
    volatile uint32_t *status = (volatile uint32_t *)(DEBUG_UART + UART_STATUS_OFFSET);
    volatile uint32_t *data = (volatile uint32_t *)(DEBUG_UART + UART_DATA_OFFSET);

    while (((*status >> UART_TX_AVAIL_SHIFT) & UART_TX_AVAIL_MASK) == 0u) {
f90001cc:	e80107b7          	lui	a5,0xe8010
f90001d0:	43dc                	lw	a5,4(a5)
f90001d2:	83c1                	srli	a5,a5,0x10
f90001d4:	0ff7f793          	andi	a5,a5,255
f90001d8:	dbf5                	beqz	a5,f90001cc <uart0_write_byte_blocking>
    }
    *data = value;
f90001da:	e80107b7          	lui	a5,0xe8010
f90001de:	c388                	sw	a0,0(a5)
}
f90001e0:	8082                	ret

f90001e2 <uart0_write_u16>:

static void uart0_write_u16(uint16_t value)
{
f90001e2:	1141                	addi	sp,sp,-16
f90001e4:	c606                	sw	ra,12(sp)
f90001e6:	c422                	sw	s0,8(sp)
f90001e8:	842a                	mv	s0,a0
    uart0_write_byte_blocking((uint8_t)(value & 0xffu));
f90001ea:	0ff57513          	andi	a0,a0,255
f90001ee:	3ff9                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking((uint8_t)(value >> 8));
f90001f0:	00845513          	srli	a0,s0,0x8
f90001f4:	3fe1                	jal	f90001cc <uart0_write_byte_blocking>
}
f90001f6:	40b2                	lw	ra,12(sp)
f90001f8:	4422                	lw	s0,8(sp)
f90001fa:	0141                	addi	sp,sp,16
f90001fc:	8082                	ret

f90001fe <uart0_write_u32>:

static void uart0_write_u32(uint32_t value)
{
f90001fe:	1141                	addi	sp,sp,-16
f9000200:	c606                	sw	ra,12(sp)
f9000202:	c422                	sw	s0,8(sp)
f9000204:	842a                	mv	s0,a0
    uart0_write_byte_blocking((uint8_t)(value & 0xffu));
f9000206:	0ff57513          	andi	a0,a0,255
f900020a:	37c9                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking((uint8_t)((value >> 8) & 0xffu));
f900020c:	00845513          	srli	a0,s0,0x8
f9000210:	0ff57513          	andi	a0,a0,255
f9000214:	3f65                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking((uint8_t)((value >> 16) & 0xffu));
f9000216:	01045513          	srli	a0,s0,0x10
f900021a:	0ff57513          	andi	a0,a0,255
f900021e:	377d                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking((uint8_t)(value >> 24));
f9000220:	01845513          	srli	a0,s0,0x18
f9000224:	3765                	jal	f90001cc <uart0_write_byte_blocking>
}
f9000226:	40b2                	lw	ra,12(sp)
f9000228:	4422                	lw	s0,8(sp)
f900022a:	0141                	addi	sp,sp,16
f900022c:	8082                	ret

f900022e <uart0_write_frame_word_rgb565_be>:

static void uart0_write_frame_word_rgb565_be(uint32_t value)
{
f900022e:	1141                	addi	sp,sp,-16
f9000230:	c606                	sw	ra,12(sp)
f9000232:	c422                	sw	s0,8(sp)
f9000234:	c226                	sw	s1,4(sp)
f9000236:	c04a                	sw	s2,0(sp)
f9000238:	842a                	mv	s0,a0
    uint16_t pixel0 = (uint16_t)(value & 0xffffu);
f900023a:	0542                	slli	a0,a0,0x10
f900023c:	8141                	srli	a0,a0,0x10
    uint16_t pixel1 = (uint16_t)(value >> 16);
f900023e:	01045493          	srli	s1,s0,0x10
f9000242:	01049913          	slli	s2,s1,0x10
f9000246:	01095913          	srli	s2,s2,0x10

    uart0_write_byte_blocking((uint8_t)(pixel0 >> 8));
f900024a:	8121                	srli	a0,a0,0x8
f900024c:	3741                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking((uint8_t)(pixel0 & 0xffu));
f900024e:	0ff47513          	andi	a0,s0,255
f9000252:	3fad                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking((uint8_t)(pixel1 >> 8));
f9000254:	00895513          	srli	a0,s2,0x8
f9000258:	3f95                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking((uint8_t)(pixel1 & 0xffu));
f900025a:	0ff4f513          	andi	a0,s1,255
f900025e:	37bd                	jal	f90001cc <uart0_write_byte_blocking>
}
f9000260:	40b2                	lw	ra,12(sp)
f9000262:	4422                	lw	s0,8(sp)
f9000264:	4492                	lw	s1,4(sp)
f9000266:	4902                	lw	s2,0(sp)
f9000268:	0141                	addi	sp,sp,16
f900026a:	8082                	ret

f900026c <checksum_update>:

static uint32_t checksum_update(uint32_t checksum, uint32_t word)
{
    return ((checksum << 5) | (checksum >> 27)) ^ word;
f900026c:	00551793          	slli	a5,a0,0x5
f9000270:	816d                	srli	a0,a0,0x1b
f9000272:	8d5d                	or	a0,a0,a5
}
f9000274:	8d2d                	xor	a0,a0,a1
f9000276:	8082                	ret

f9000278 <uart0_write_frame_header>:

static void uart0_write_frame_header(uint32_t seq, uint32_t payload_bytes,
                                     uint32_t bank)
{
f9000278:	1141                	addi	sp,sp,-16
f900027a:	c606                	sw	ra,12(sp)
f900027c:	c422                	sw	s0,8(sp)
f900027e:	c226                	sw	s1,4(sp)
f9000280:	c04a                	sw	s2,0(sp)
f9000282:	892a                	mv	s2,a0
f9000284:	84ae                	mv	s1,a1
f9000286:	8432                	mv	s0,a2
    uart0_write_byte_blocking('V');
f9000288:	05600513          	li	a0,86
f900028c:	3781                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking('F');
f900028e:	04600513          	li	a0,70
f9000292:	3f2d                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking('R');
f9000294:	05200513          	li	a0,82
f9000298:	3f15                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking('M');
f900029a:	04d00513          	li	a0,77
f900029e:	373d                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking(1);                /* protocol version */
f90002a0:	4505                	li	a0,1
f90002a2:	372d                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking(FRAME_FORMAT_RGB565);
f90002a4:	4505                	li	a0,1
f90002a6:	371d                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_u16(FRAME_WIDTH);
f90002a8:	0a000513          	li	a0,160
f90002ac:	3f1d                	jal	f90001e2 <uart0_write_u16>
    uart0_write_u16(FRAME_HEIGHT);
f90002ae:	05a00513          	li	a0,90
f90002b2:	3f05                	jal	f90001e2 <uart0_write_u16>
    uart0_write_u32(seq);
f90002b4:	854a                	mv	a0,s2
f90002b6:	37a1                	jal	f90001fe <uart0_write_u32>
    uart0_write_u32(payload_bytes);
f90002b8:	8526                	mv	a0,s1
f90002ba:	3791                	jal	f90001fe <uart0_write_u32>
    uart0_write_u32(0);                         /* checksum follows payload */
f90002bc:	4501                	li	a0,0
f90002be:	3781                	jal	f90001fe <uart0_write_u32>
    uart0_write_byte_blocking((uint8_t)bank);
f90002c0:	0ff47513          	andi	a0,s0,255
f90002c4:	3721                	jal	f90001cc <uart0_write_byte_blocking>
    uart0_write_byte_blocking(1);                /* flags: footer checksum */
f90002c6:	4505                	li	a0,1
f90002c8:	3711                	jal	f90001cc <uart0_write_byte_blocking>
}
f90002ca:	40b2                	lw	ra,12(sp)
f90002cc:	4422                	lw	s0,8(sp)
f90002ce:	4492                	lw	s1,4(sp)
f90002d0:	4902                	lw	s2,0(sp)
f90002d2:	0141                	addi	sp,sp,16
f90002d4:	8082                	ret

f90002d6 <uart0_poll_command>:

static uint32_t uart0_poll_command(uint32_t current_mode)
{
f90002d6:	1141                	addi	sp,sp,-16
f90002d8:	c606                	sw	ra,12(sp)
f90002da:	c422                	sw	s0,8(sp)
f90002dc:	842a                	mv	s0,a0
    while (uart_readOccupancy(DEBUG_UART) != 0u) {
f90002de:	a011                	j	f90002e2 <uart0_poll_command+0xc>
        char cmd = uart_read(DEBUG_UART);
        if ((cmd == 'R') || (cmd == 'r')) {
            current_mode = STREAM_RISCV;
f90002e0:	4405                	li	s0,1
    while (uart_readOccupancy(DEBUG_UART) != 0u) {
f90002e2:	e8010537          	lui	a0,0xe8010
f90002e6:	3d11                	jal	f90000fa <uart_readOccupancy>
f90002e8:	c531                	beqz	a0,f9000334 <uart0_poll_command+0x5e>
        char cmd = uart_read(DEBUG_UART);
f90002ea:	e8010537          	lui	a0,0xe8010
f90002ee:	3d91                	jal	f9000142 <uart_read>
        if ((cmd == 'R') || (cmd == 'r')) {
f90002f0:	05200793          	li	a5,82
f90002f4:	fef506e3          	beq	a0,a5,f90002e0 <uart0_poll_command+0xa>
f90002f8:	07200793          	li	a5,114
f90002fc:	02f50463          	beq	a0,a5,f9000324 <uart0_poll_command+0x4e>
        } else if ((cmd == 'F') || (cmd == 'f')) {
f9000300:	04600793          	li	a5,70
f9000304:	02f50263          	beq	a0,a5,f9000328 <uart0_poll_command+0x52>
f9000308:	06600793          	li	a5,102
f900030c:	02f50063          	beq	a0,a5,f900032c <uart0_poll_command+0x56>
            current_mode = STREAM_FPGA;
        } else if ((cmd == 'S') || (cmd == 's')) {
f9000310:	05300793          	li	a5,83
f9000314:	00f50e63          	beq	a0,a5,f9000330 <uart0_poll_command+0x5a>
f9000318:	07300793          	li	a5,115
f900031c:	fcf513e3          	bne	a0,a5,f90002e2 <uart0_poll_command+0xc>
            current_mode = STREAM_STOP;
f9000320:	4401                	li	s0,0
f9000322:	b7c1                	j	f90002e2 <uart0_poll_command+0xc>
            current_mode = STREAM_RISCV;
f9000324:	4405                	li	s0,1
f9000326:	bf75                	j	f90002e2 <uart0_poll_command+0xc>
            current_mode = STREAM_FPGA;
f9000328:	4409                	li	s0,2
f900032a:	bf65                	j	f90002e2 <uart0_poll_command+0xc>
f900032c:	4409                	li	s0,2
f900032e:	bf55                	j	f90002e2 <uart0_poll_command+0xc>
            current_mode = STREAM_STOP;
f9000330:	4401                	li	s0,0
f9000332:	bf45                	j	f90002e2 <uart0_poll_command+0xc>
        }
    }
    return current_mode;
}
f9000334:	8522                	mv	a0,s0
f9000336:	40b2                	lw	ra,12(sp)
f9000338:	4422                	lw	s0,8(sp)
f900033a:	0141                	addi	sp,sp,16
f900033c:	8082                	ret

f900033e <main>:

void main(void)
{
f900033e:	7179                	addi	sp,sp,-48
f9000340:	d606                	sw	ra,44(sp)
f9000342:	d422                	sw	s0,40(sp)
f9000344:	d226                	sw	s1,36(sp)
f9000346:	d04a                	sw	s2,32(sp)
f9000348:	ce4e                	sw	s3,28(sp)
f900034a:	cc52                	sw	s4,24(sp)
f900034c:	ca56                	sw	s5,20(sp)
f900034e:	c85a                	sw	s6,16(sp)
f9000350:	c65e                	sw	s7,12(sp)
    uint32_t last_seq = 0;
    uint32_t stream_mode = STREAM_RISCV;

    if ((uint32_t)csr_read(mhartid) != 0u) {
f9000352:	f1402b73          	csrr	s6,mhartid
f9000356:	000b0563          	beqz	s6,f9000360 <main+0x22>
        while (1) {
            asm volatile ("wfi");
f900035a:	10500073          	wfi
f900035e:	bff5                	j	f900035a <main+0x1c>
        }
    }

    uart_config_debug_baud(DEBUG_UART);
f9000360:	e8010537          	lui	a0,0xe8010
f9000364:	35b1                	jal	f90001b0 <uart_config_debug_baud>
    uart_config_debug_baud(ROBOT_UART);
f9000366:	e8011537          	lui	a0,0xe8011
f900036a:	3599                	jal	f90001b0 <uart_config_debug_baud>

    if (reg_read(REG_MAGIC) != EXPECTED_MAGIC) {
f900036c:	4501                	li	a0,0
f900036e:	353d                	jal	f900019c <reg_read>
f9000370:	564957b7          	lui	a5,0x56495
f9000374:	34e78793          	addi	a5,a5,846 # 5649534e <__stack_size+0x56494b4e>
f9000378:	00f51563          	bne	a0,a5,f9000382 <main+0x44>
    uint32_t last_seq = 0;
f900037c:	8ada                	mv	s5,s6
    uint32_t stream_mode = STREAM_RISCV;
f900037e:	4985                	li	s3,1
f9000380:	a0a5                	j	f90003e8 <main+0xaa>
        uart_writeStr(DEBUG_UART, "VISION APB ERROR\r\n");
f9000382:	f90005b7          	lui	a1,0xf9000
f9000386:	44858593          	addi	a1,a1,1096 # f9000448 <__freertos_irq_stack_top+0xfffff7c8>
f900038a:	e8010537          	lui	a0,0xe8010
f900038e:	3b41                	jal	f900011e <uart_writeStr>
        while (1) {
            asm volatile ("wfi");
f9000390:	10500073          	wfi
f9000394:	bff5                	j	f9000390 <main+0x52>
            volatile uint32_t *pixels;

            reg_write(REG_CONTROL, CONTROL_CLAIM);
            bank = reg_read(REG_CLAIM_BANK);
            seq = reg_read(REG_CLAIM_SEQ);
            buffer_offset = reg_read(bank ? REG_BUFFER1 : REG_BUFFER0);
f9000396:	4571                	li	a0,28
f9000398:	a079                	j	f9000426 <main+0xe8>
            word_count = buffer_bytes >> 2;
            pixels = (volatile uint32_t *)(FRAME_APB_BASE + buffer_offset);

            uart0_write_frame_header(seq, buffer_bytes, bank);
            for (i = 0; i < word_count; ++i) {
                uint32_t word = pixels[i];
f900039a:	00241793          	slli	a5,s0,0x2
f900039e:	97d2                	add	a5,a5,s4
f90003a0:	4384                	lw	s1,0(a5)
                checksum = checksum_update(checksum, word);
f90003a2:	85a6                	mv	a1,s1
f90003a4:	854a                	mv	a0,s2
f90003a6:	35d9                	jal	f900026c <checksum_update>
f90003a8:	892a                	mv	s2,a0
                uart0_write_frame_word_rgb565_be(word);
f90003aa:	8526                	mv	a0,s1
f90003ac:	3549                	jal	f900022e <uart0_write_frame_word_rgb565_be>
            for (i = 0; i < word_count; ++i) {
f90003ae:	0405                	addi	s0,s0,1
f90003b0:	ff7465e3          	bltu	s0,s7,f900039a <main+0x5c>
            }
            uart0_write_u32(checksum);
f90003b4:	854a                	mv	a0,s2
f90003b6:	35a1                	jal	f90001fe <uart0_write_u32>

            reg_write(REG_CONTROL, CONTROL_RELEASE);
f90003b8:	4589                	li	a1,2
f90003ba:	03000513          	li	a0,48
f90003be:	33e5                	jal	f90001a6 <reg_write>
            last_seq = seq;
            bsp_uDelay(FRAME_GAP_US);
f90003c0:	f8b00637          	lui	a2,0xf8b00
f90003c4:	0ee6b5b7          	lui	a1,0xee6b
f90003c8:	28058593          	addi	a1,a1,640 # ee6b280 <__stack_size+0xee6aa80>
f90003cc:	6531                	lui	a0,0xc
f90003ce:	35050513          	addi	a0,a0,848 # c350 <__stack_size+0xbb50>
f90003d2:	3355                	jal	f9000176 <clint_uDelay>
            (status & STATUS_FRAME_VALID) && (seq != last_seq)) {
f90003d4:	a811                	j	f90003e8 <main+0xaa>
        } else {
            bsp_uDelay(1000u);
f90003d6:	f8b00637          	lui	a2,0xf8b00
f90003da:	0ee6b5b7          	lui	a1,0xee6b
f90003de:	28058593          	addi	a1,a1,640 # ee6b280 <__stack_size+0xee6aa80>
f90003e2:	3e800513          	li	a0,1000
f90003e6:	3b41                	jal	f9000176 <clint_uDelay>
        uint32_t status = reg_read(REG_STATUS);
f90003e8:	4561                	li	a0,24
f90003ea:	3b4d                	jal	f900019c <reg_read>
f90003ec:	842a                	mv	s0,a0
        uint32_t seq = reg_read(REG_FRAME_SEQ);
f90003ee:	4541                	li	a0,16
f90003f0:	3375                	jal	f900019c <reg_read>
f90003f2:	84aa                	mv	s1,a0
        stream_mode = uart0_poll_command(stream_mode);
f90003f4:	854e                	mv	a0,s3
f90003f6:	35c5                	jal	f90002d6 <uart0_poll_command>
f90003f8:	89aa                	mv	s3,a0
        if ((stream_mode == STREAM_RISCV) &&
f90003fa:	4785                	li	a5,1
f90003fc:	fcf51de3          	bne	a0,a5,f90003d6 <main+0x98>
            (status & STATUS_FRAME_VALID) && (seq != last_seq)) {
f9000400:	8809                	andi	s0,s0,2
        if ((stream_mode == STREAM_RISCV) &&
f9000402:	d871                	beqz	s0,f90003d6 <main+0x98>
            (status & STATUS_FRAME_VALID) && (seq != last_seq)) {
f9000404:	fc9a89e3          	beq	s5,s1,f90003d6 <main+0x98>
            reg_write(REG_CONTROL, CONTROL_CLAIM);
f9000408:	4585                	li	a1,1
f900040a:	03000513          	li	a0,48
f900040e:	3b61                	jal	f90001a6 <reg_write>
            bank = reg_read(REG_CLAIM_BANK);
f9000410:	03400513          	li	a0,52
f9000414:	3361                	jal	f900019c <reg_read>
f9000416:	842a                	mv	s0,a0
            seq = reg_read(REG_CLAIM_SEQ);
f9000418:	03800513          	li	a0,56
f900041c:	3341                	jal	f900019c <reg_read>
f900041e:	8aaa                	mv	s5,a0
            buffer_offset = reg_read(bank ? REG_BUFFER1 : REG_BUFFER0);
f9000420:	d83d                	beqz	s0,f9000396 <main+0x58>
f9000422:	02000513          	li	a0,32
f9000426:	3b9d                	jal	f900019c <reg_read>
f9000428:	8a2a                	mv	s4,a0
            buffer_bytes = reg_read(REG_BUFFER_BYTES);
f900042a:	02400513          	li	a0,36
f900042e:	33bd                	jal	f900019c <reg_read>
f9000430:	85aa                	mv	a1,a0
            word_count = buffer_bytes >> 2;
f9000432:	00255b93          	srli	s7,a0,0x2
            pixels = (volatile uint32_t *)(FRAME_APB_BASE + buffer_offset);
f9000436:	e81007b7          	lui	a5,0xe8100
f900043a:	9a3e                	add	s4,s4,a5
            uart0_write_frame_header(seq, buffer_bytes, bank);
f900043c:	8622                	mv	a2,s0
f900043e:	8556                	mv	a0,s5
f9000440:	3d25                	jal	f9000278 <uart0_write_frame_header>
            for (i = 0; i < word_count; ++i) {
f9000442:	845a                	mv	s0,s6
            uint32_t checksum = 0;
f9000444:	895a                	mv	s2,s6
            for (i = 0; i < word_count; ++i) {
f9000446:	b7ad                	j	f90003b0 <main+0x72>
