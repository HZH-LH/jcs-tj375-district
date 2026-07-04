
build/visionUartSelfTest.elf:     file format elf32-littleriscv


Disassembly of section .init:

f9000000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
f9000000:	00001197          	auipc	gp,0x1
f9000004:	bf018193          	addi	gp,gp,-1040 # f9000bf0 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
f9000008:	8201a023          	sw	zero,-2016(gp) # f9000410 <smp_lottery_lock>

f900000c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
f900000c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
f9000010:	c515                	beqz	a0,f900003c <init>

f9000012 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
f9000012:	8201a503          	lw	a0,-2016(gp) # f9000410 <smp_lottery_lock>
	beqz a0, smp_slave
f9000016:	dd75                	beqz	a0,f9000012 <smp_slave>

	fence r, r
f9000018:	0220000f          	fence	r,r
f900001c:	0000100f          	fence.i
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
f9000020:	81c1a783          	lw	a5,-2020(gp) # f900040c <__bss_start>
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
f900002c:	80a1ae23          	sw	a0,-2020(gp) # f900040c <__bss_start>
	fence w, w
f9000030:	0110000f          	fence	w,w
	li a0, 1
f9000034:	4505                	li	a0,1
	sw a0, smp_lottery_lock, a1
f9000036:	82a1a023          	sw	a0,-2016(gp) # f9000410 <smp_lottery_lock>
    ret
f900003a:	8082                	ret

f900003c <init>:
#endif

init:
	la sp, _sp
f900003c:	03018113          	addi	sp,gp,48 # f9000c20 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
f9000040:	00000517          	auipc	a0,0x0
f9000044:	2c850513          	addi	a0,a0,712 # f9000308 <_data>
	la a1, _data
f9000048:	00000597          	auipc	a1,0x0
f900004c:	2c058593          	addi	a1,a1,704 # f9000308 <_data>
	la a2, _edata
f9000050:	81c18613          	addi	a2,gp,-2020 # f900040c <__bss_start>
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
f9000068:	81c18513          	addi	a0,gp,-2020 # f900040c <__bss_start>
	la a1, _end
f900006c:	82818593          	addi	a1,gp,-2008 # f9000418 <_end>
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
f9000080:	2275                	jal	f900022c <main>

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
f9000090:	27a40413          	addi	s0,s0,634 # f9000306 <__init_array_end>
f9000094:	00000917          	auipc	s2,0x0
f9000098:	27290913          	addi	s2,s2,626 # f9000306 <__init_array_end>
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
f90000be:	24c40413          	addi	s0,s0,588 # f9000306 <__init_array_end>
f90000c2:	00000917          	auipc	s2,0x0
f90000c6:	24490913          	addi	s2,s2,580 # f9000306 <__init_array_end>
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

f90000fa <uart_write>:
* @note    The function waits until there is available space in the UART buffer
*          for writing data. Once space is available, it writes the character
*          data to the UART data register.
*
******************************************************************************/
    static void uart_write(u32 reg, char data){
f90000fa:	1141                	addi	sp,sp,-16
f90000fc:	c606                	sw	ra,12(sp)
f90000fe:	c422                	sw	s0,8(sp)
f9000100:	c226                	sw	s1,4(sp)
f9000102:	842a                	mv	s0,a0
f9000104:	84ae                	mv	s1,a1
        while(uart_writeAvailability(reg) == 0);
f9000106:	8522                	mv	a0,s0
f9000108:	37e5                	jal	f90000f0 <uart_writeAvailability>
f900010a:	dd75                	beqz	a0,f9000106 <uart_write+0xc>
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
f900010c:	c004                	sw	s1,0(s0)
        write_u32(data, reg + UART_DATA);
    }
f900010e:	40b2                	lw	ra,12(sp)
f9000110:	4422                	lw	s0,8(sp)
f9000112:	4492                	lw	s1,4(sp)
f9000114:	0141                	addi	sp,sp,16
f9000116:	8082                	ret

f9000118 <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
f9000118:	45dc                	lw	a5,12(a1)
f900011a:	c51c                	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
f900011c:	419c                	lw	a5,0(a1)
f900011e:	17fd                	addi	a5,a5,-1
f9000120:	41d8                	lw	a4,4(a1)
f9000122:	0722                	slli	a4,a4,0x8
f9000124:	8fd9                	or	a5,a5,a4
f9000126:	4598                	lw	a4,8(a1)
f9000128:	0742                	slli	a4,a4,0x10
f900012a:	8fd9                	or	a5,a5,a4
f900012c:	c55c                	sw	a5,12(a0)
    }
f900012e:	8082                	ret

f9000130 <uart_writeHex>:
*          starting from the most significant nibble. It extracts each nibble,
*          converts it to its corresponding hexadecimal character, and writes
*          the character to the UART buffer using the uart_write function.
*
******************************************************************************/
    static void uart_writeHex(u32 reg, int value){
f9000130:	1141                	addi	sp,sp,-16
f9000132:	c606                	sw	ra,12(sp)
f9000134:	c422                	sw	s0,8(sp)
f9000136:	c226                	sw	s1,4(sp)
f9000138:	c04a                	sw	s2,0(sp)
f900013a:	892a                	mv	s2,a0
f900013c:	84ae                	mv	s1,a1
        for(int i = 7; i >= 0; i--){
f900013e:	441d                	li	s0,7
f9000140:	a031                	j	f900014c <uart_writeHex+0x1c>
            int hex = (value >> i*4) & 0xF;
            uart_write(reg, hex > 9 ? 'A' + hex - 10 : '0' + hex);
f9000142:	03058593          	addi	a1,a1,48
f9000146:	854a                	mv	a0,s2
f9000148:	3f4d                	jal	f90000fa <uart_write>
        for(int i = 7; i >= 0; i--){
f900014a:	147d                	addi	s0,s0,-1
f900014c:	00044d63          	bltz	s0,f9000166 <uart_writeHex+0x36>
            int hex = (value >> i*4) & 0xF;
f9000150:	00241593          	slli	a1,s0,0x2
f9000154:	40b4d5b3          	sra	a1,s1,a1
f9000158:	89bd                	andi	a1,a1,15
            uart_write(reg, hex > 9 ? 'A' + hex - 10 : '0' + hex);
f900015a:	47a5                	li	a5,9
f900015c:	feb7d3e3          	bge	a5,a1,f9000142 <uart_writeHex+0x12>
f9000160:	03758593          	addi	a1,a1,55
f9000164:	b7cd                	j	f9000146 <uart_writeHex+0x16>
        }
    }
f9000166:	40b2                	lw	ra,12(sp)
f9000168:	4422                	lw	s0,8(sp)
f900016a:	4492                	lw	s1,4(sp)
f900016c:	4902                	lw	s2,0(sp)
f900016e:	0141                	addi	sp,sp,16
f9000170:	8082                	ret

f9000172 <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
f9000172:	1101                	addi	sp,sp,-32
f9000174:	ce06                	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
f9000176:	47a1                	li	a5,8
f9000178:	c03e                	sw	a5,0(sp)
        uartConfig.parity       = NONE;
f900017a:	c202                	sw	zero,4(sp)
        uartConfig.stop         = ONE;
f900017c:	c402                	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
f900017e:	10e00793          	li	a5,270
f9000182:	c63e                	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
f9000184:	858a                	mv	a1,sp
f9000186:	e8010537          	lui	a0,0xe8010
f900018a:	3779                	jal	f9000118 <uart_applyConfig>
    }
f900018c:	40f2                	lw	ra,28(sp)
f900018e:	6105                	addi	sp,sp,32
f9000190:	8082                	ret

f9000192 <delay_cycles>:
#include <stdint.h>
#include "bsp.h"
#include "riscv.h"

static void delay_cycles(volatile uint32_t loops)
{
f9000192:	1141                	addi	sp,sp,-16
f9000194:	c62a                	sw	a0,12(sp)
    while (loops--) {
f9000196:	47b2                	lw	a5,12(sp)
f9000198:	fff78713          	addi	a4,a5,-1
f900019c:	c63a                	sw	a4,12(sp)
f900019e:	c399                	beqz	a5,f90001a4 <delay_cycles+0x12>
        asm volatile ("nop");
f90001a0:	0001                	nop
f90001a2:	bfd5                	j	f9000196 <delay_cycles+0x4>
    }
}
f90001a4:	0141                	addi	sp,sp,16
f90001a6:	8082                	ret

f90001a8 <uart_puts_raw>:

static void uart_puts_raw(const char *s)
{
f90001a8:	1141                	addi	sp,sp,-16
f90001aa:	c606                	sw	ra,12(sp)
f90001ac:	c422                	sw	s0,8(sp)
f90001ae:	842a                	mv	s0,a0
    while (*s) {
f90001b0:	00044583          	lbu	a1,0(s0)
f90001b4:	c591                	beqz	a1,f90001c0 <uart_puts_raw+0x18>
        uart_write(BSP_UART_TERMINAL, *s++);
f90001b6:	0405                	addi	s0,s0,1
f90001b8:	e8010537          	lui	a0,0xe8010
f90001bc:	3f3d                	jal	f90000fa <uart_write>
f90001be:	bfcd                	j	f90001b0 <uart_puts_raw+0x8>
    }
}
f90001c0:	40b2                	lw	ra,12(sp)
f90001c2:	4422                	lw	s0,8(sp)
f90001c4:	0141                	addi	sp,sp,16
f90001c6:	8082                	ret

f90001c8 <uart_puthex32>:

static void uart_puthex32(uint32_t value)
{
f90001c8:	1141                	addi	sp,sp,-16
f90001ca:	c606                	sw	ra,12(sp)
    uart_writeHex(BSP_UART_TERMINAL, (int)value);
f90001cc:	85aa                	mv	a1,a0
f90001ce:	e8010537          	lui	a0,0xe8010
f90001d2:	3fb9                	jal	f9000130 <uart_writeHex>
}
f90001d4:	40b2                	lw	ra,12(sp)
f90001d6:	0141                	addi	sp,sp,16
f90001d8:	8082                	ret

f90001da <uart_putdec>:

static void uart_putdec(uint32_t value)
{
f90001da:	1101                	addi	sp,sp,-32
f90001dc:	ce06                	sw	ra,28(sp)
f90001de:	cc22                	sw	s0,24(sp)
    char buf[11];
    uint32_t i = 0;

    if (value == 0) {
f90001e0:	c119                	beqz	a0,f90001e6 <uart_putdec+0xc>
    uint32_t i = 0;
f90001e2:	4401                	li	s0,0
f90001e4:	a035                	j	f9000210 <uart_putdec+0x36>
        uart_write(BSP_UART_TERMINAL, '0');
f90001e6:	03000593          	li	a1,48
f90001ea:	e8010537          	lui	a0,0xe8010
f90001ee:	3731                	jal	f90000fa <uart_write>
    }

    while (i) {
        uart_write(BSP_UART_TERMINAL, buf[--i]);
    }
}
f90001f0:	40f2                	lw	ra,28(sp)
f90001f2:	4462                	lw	s0,24(sp)
f90001f4:	6105                	addi	sp,sp,32
f90001f6:	8082                	ret
        buf[i++] = (char)('0' + (value % 10));
f90001f8:	4729                	li	a4,10
f90001fa:	02e577b3          	remu	a5,a0,a4
f90001fe:	03078793          	addi	a5,a5,48
f9000202:	0814                	addi	a3,sp,16
f9000204:	96a2                	add	a3,a3,s0
f9000206:	fef68a23          	sb	a5,-12(a3)
        value /= 10;
f900020a:	02e55533          	divu	a0,a0,a4
        buf[i++] = (char)('0' + (value % 10));
f900020e:	0405                	addi	s0,s0,1
    while (value && i < sizeof(buf)) {
f9000210:	c501                	beqz	a0,f9000218 <uart_putdec+0x3e>
f9000212:	47a9                	li	a5,10
f9000214:	fe87f2e3          	bgeu	a5,s0,f90001f8 <uart_putdec+0x1e>
    while (i) {
f9000218:	dc61                	beqz	s0,f90001f0 <uart_putdec+0x16>
        uart_write(BSP_UART_TERMINAL, buf[--i]);
f900021a:	147d                	addi	s0,s0,-1
f900021c:	081c                	addi	a5,sp,16
f900021e:	97a2                	add	a5,a5,s0
f9000220:	ff47c583          	lbu	a1,-12(a5)
f9000224:	e8010537          	lui	a0,0xe8010
f9000228:	3dc9                	jal	f90000fa <uart_write>
f900022a:	b7fd                	j	f9000218 <uart_putdec+0x3e>

f900022c <main>:

void main(void)
{
f900022c:	1141                	addi	sp,sp,-16
f900022e:	c606                	sw	ra,12(sp)
f9000230:	c422                	sw	s0,8(sp)
f9000232:	c226                	sw	s1,4(sp)
f9000234:	c04a                	sw	s2,0(sp)
    uint32_t hart_id = (uint32_t)csr_read(mhartid);
f9000236:	f1402473          	csrr	s0,mhartid
    uint32_t counter = 0;

    if (hart_id != 0) {
f900023a:	c401                	beqz	s0,f9000242 <main+0x16>
        while (1) {
            asm volatile ("wfi");
f900023c:	10500073          	wfi
f9000240:	bff5                	j	f900023c <main+0x10>
        }
    }

    bsp_init();
f9000242:	3f05                	jal	f9000172 <bsp_init>

    uart_puts_raw("\r\n\r\n");
f9000244:	f9000537          	lui	a0,0xf9000
f9000248:	30850513          	addi	a0,a0,776 # f9000308 <__freertos_irq_stack_top+0xfffff6e8>
f900024c:	3fb1                	jal	f90001a8 <uart_puts_raw>
    uart_puts_raw("========================================\r\n");
f900024e:	f9000937          	lui	s2,0xf9000
f9000252:	31090513          	addi	a0,s2,784 # f9000310 <__freertos_irq_stack_top+0xfffff6f0>
f9000256:	3f89                	jal	f90001a8 <uart_puts_raw>
    uart_puts_raw("Vision hard RISC-V UART self-test\r\n");
f9000258:	f9000537          	lui	a0,0xf9000
f900025c:	33c50513          	addi	a0,a0,828 # f900033c <__freertos_irq_stack_top+0xfffff71c>
f9000260:	37a1                	jal	f90001a8 <uart_puts_raw>
    uart_puts_raw("Build: internal RAM, UART0 only\r\n");
f9000262:	f9000537          	lui	a0,0xf9000
f9000266:	36050513          	addi	a0,a0,864 # f9000360 <__freertos_irq_stack_top+0xfffff740>
f900026a:	3f3d                	jal	f90001a8 <uart_puts_raw>
    uart_puts_raw("UART base: 0x");
f900026c:	f9000537          	lui	a0,0xf9000
f9000270:	38450513          	addi	a0,a0,900 # f9000384 <__freertos_irq_stack_top+0xfffff764>
f9000274:	3f15                	jal	f90001a8 <uart_puts_raw>
    uart_puthex32((uint32_t)BSP_UART_TERMINAL);
f9000276:	e8010537          	lui	a0,0xe8010
f900027a:	37b9                	jal	f90001c8 <uart_puthex32>
    uart_puts_raw("\r\n");
f900027c:	f90004b7          	lui	s1,0xf9000
f9000280:	33848513          	addi	a0,s1,824 # f9000338 <__freertos_irq_stack_top+0xfffff718>
f9000284:	3715                	jal	f90001a8 <uart_puts_raw>
    uart_puts_raw("Internal RAM base: 0x");
f9000286:	f9000537          	lui	a0,0xf9000
f900028a:	39450513          	addi	a0,a0,916 # f9000394 <__freertos_irq_stack_top+0xfffff774>
f900028e:	3f29                	jal	f90001a8 <uart_puts_raw>
    uart_puthex32((uint32_t)SYSTEM_RAM_A_CTRL);
f9000290:	f9000537          	lui	a0,0xf9000
f9000294:	3f15                	jal	f90001c8 <uart_puthex32>
    uart_puts_raw(", size: 0x");
f9000296:	f9000537          	lui	a0,0xf9000
f900029a:	3ac50513          	addi	a0,a0,940 # f90003ac <__freertos_irq_stack_top+0xfffff78c>
f900029e:	3729                	jal	f90001a8 <uart_puts_raw>
    uart_puthex32((uint32_t)SYSTEM_RAM_A_CTRL_SIZE);
f90002a0:	6511                	lui	a0,0x4
f90002a2:	371d                	jal	f90001c8 <uart_puthex32>
    uart_puts_raw("\r\n");
f90002a4:	33848513          	addi	a0,s1,824
f90002a8:	3701                	jal	f90001a8 <uart_puts_raw>
    uart_puts_raw("mhartid: ");
f90002aa:	f9000537          	lui	a0,0xf9000
f90002ae:	3b850513          	addi	a0,a0,952 # f90003b8 <__freertos_irq_stack_top+0xfffff798>
f90002b2:	3ddd                	jal	f90001a8 <uart_puts_raw>
    uart_putdec(hart_id);
f90002b4:	8522                	mv	a0,s0
f90002b6:	3715                	jal	f90001da <uart_putdec>
    uart_puts_raw("\r\n");
f90002b8:	33848513          	addi	a0,s1,824
f90002bc:	35f5                	jal	f90001a8 <uart_puts_raw>
    uart_puts_raw("Expected serial: 115200 8N1\r\n");
f90002be:	f9000537          	lui	a0,0xf9000
f90002c2:	3c450513          	addi	a0,a0,964 # f90003c4 <__freertos_irq_stack_top+0xfffff7a4>
f90002c6:	35cd                	jal	f90001a8 <uart_puts_raw>
    uart_puts_raw("========================================\r\n");
f90002c8:	31090513          	addi	a0,s2,784
f90002cc:	3df1                	jal	f90001a8 <uart_puts_raw>

    while (1) {
        uint32_t cycle_low = (uint32_t)csr_read(mcycle);
f90002ce:	b0002973          	csrr	s2,mcycle

        uart_puts_raw("[alive] count=");
f90002d2:	f9000537          	lui	a0,0xf9000
f90002d6:	3e450513          	addi	a0,a0,996 # f90003e4 <__freertos_irq_stack_top+0xfffff7c4>
f90002da:	35f9                	jal	f90001a8 <uart_puts_raw>
        uart_putdec(counter++);
f90002dc:	00140493          	addi	s1,s0,1
f90002e0:	8522                	mv	a0,s0
f90002e2:	3de5                	jal	f90001da <uart_putdec>
        uart_puts_raw(" mcycle=0x");
f90002e4:	80418513          	addi	a0,gp,-2044 # f90003f4 <_data+0xec>
f90002e8:	35c1                	jal	f90001a8 <uart_puts_raw>
        uart_puthex32(cycle_low);
f90002ea:	854a                	mv	a0,s2
f90002ec:	3df1                	jal	f90001c8 <uart_puthex32>
        uart_puts_raw("\r\n");
f90002ee:	f9000537          	lui	a0,0xf9000
f90002f2:	33850513          	addi	a0,a0,824 # f9000338 <__freertos_irq_stack_top+0xfffff718>
f90002f6:	3d4d                	jal	f90001a8 <uart_puts_raw>

        delay_cycles(20000000u);
f90002f8:	01313537          	lui	a0,0x1313
f90002fc:	d0050513          	addi	a0,a0,-768 # 1312d00 <__stack_size+0x1312500>
f9000300:	3d49                	jal	f9000192 <delay_cycles>
        uart_putdec(counter++);
f9000302:	8426                	mv	s0,s1
f9000304:	b7e9                	j	f90002ce <main+0xa2>
