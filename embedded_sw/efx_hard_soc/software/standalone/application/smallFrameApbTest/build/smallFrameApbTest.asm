
build/smallFrameApbTest.elf:     file format elf32-littleriscv


Disassembly of section .init:

f9000000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
f9000000:	00001197          	auipc	gp,0x1
f9000004:	bf818193          	addi	gp,gp,-1032 # f9000bf8 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
f9000008:	8201a023          	sw	zero,-2016(gp) # f9000418 <smp_lottery_lock>

f900000c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
f900000c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
f9000010:	c515                	beqz	a0,f900003c <init>

f9000012 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
f9000012:	8201a503          	lw	a0,-2016(gp) # f9000418 <smp_lottery_lock>
	beqz a0, smp_slave
f9000016:	dd75                	beqz	a0,f9000012 <smp_slave>

	fence r, r
f9000018:	0220000f          	fence	r,r
f900001c:	0000100f          	fence.i
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
f9000020:	81c1a783          	lw	a5,-2020(gp) # f9000414 <__bss_start>
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
f900002c:	80a1ae23          	sw	a0,-2020(gp) # f9000414 <__bss_start>
	fence w, w
f9000030:	0110000f          	fence	w,w
	li a0, 1
f9000034:	4505                	li	a0,1
	sw a0, smp_lottery_lock, a1
f9000036:	82a1a023          	sw	a0,-2016(gp) # f9000418 <smp_lottery_lock>
    ret
f900003a:	8082                	ret

f900003c <init>:
#endif

init:
	la sp, _sp
f900003c:	02818113          	addi	sp,gp,40 # f9000c20 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
f9000040:	00000517          	auipc	a0,0x0
f9000044:	30450513          	addi	a0,a0,772 # f9000344 <_data>
	la a1, _data
f9000048:	00000597          	auipc	a1,0x0
f900004c:	2fc58593          	addi	a1,a1,764 # f9000344 <_data>
	la a2, _edata
f9000050:	81c18613          	addi	a2,gp,-2020 # f9000414 <__bss_start>
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
f9000068:	81c18513          	addi	a0,gp,-2020 # f9000414 <__bss_start>
	la a1, _end
f900006c:	82818593          	addi	a1,gp,-2008 # f9000420 <_end>
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
f9000080:	2aa1                	jal	f90001d8 <main>

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
f9000090:	2b640413          	addi	s0,s0,694 # f9000342 <__init_array_end>
f9000094:	00000917          	auipc	s2,0x0
f9000098:	2ae90913          	addi	s2,s2,686 # f9000342 <__init_array_end>
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
f90000be:	28840413          	addi	s0,s0,648 # f9000342 <__init_array_end>
f90000c2:	00000917          	auipc	s2,0x0
f90000c6:	28090913          	addi	s2,s2,640 # f9000342 <__init_array_end>
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

f9000192 <reg_read>:
#define CONTROL_RELEASE      (1u << 1)
#define EXPECTED_MAGIC       0x5649534eu

static uint32_t reg_read(uint32_t offset)
{
    return *((volatile uint32_t *)(FRAME_APB_BASE + offset));
f9000192:	e81007b7          	lui	a5,0xe8100
f9000196:	953e                	add	a0,a0,a5
f9000198:	4108                	lw	a0,0(a0)
}
f900019a:	8082                	ret

f900019c <reg_write>:

static void reg_write(uint32_t offset, uint32_t value)
{
    *((volatile uint32_t *)(FRAME_APB_BASE + offset)) = value;
f900019c:	e81007b7          	lui	a5,0xe8100
f90001a0:	953e                	add	a0,a0,a5
f90001a2:	c10c                	sw	a1,0(a0)
}
f90001a4:	8082                	ret

f90001a6 <uart_puts_raw>:

static void uart_puts_raw(const char *text)
{
f90001a6:	1141                	addi	sp,sp,-16
f90001a8:	c606                	sw	ra,12(sp)
f90001aa:	c422                	sw	s0,8(sp)
f90001ac:	842a                	mv	s0,a0
    while (*text) {
f90001ae:	00044583          	lbu	a1,0(s0)
f90001b2:	c591                	beqz	a1,f90001be <uart_puts_raw+0x18>
        uart_write(BSP_UART_TERMINAL, *text++);
f90001b4:	0405                	addi	s0,s0,1
f90001b6:	e8010537          	lui	a0,0xe8010
f90001ba:	3781                	jal	f90000fa <uart_write>
f90001bc:	bfcd                	j	f90001ae <uart_puts_raw+0x8>
    }
}
f90001be:	40b2                	lw	ra,12(sp)
f90001c0:	4422                	lw	s0,8(sp)
f90001c2:	0141                	addi	sp,sp,16
f90001c4:	8082                	ret

f90001c6 <uart_hex>:

static void uart_hex(uint32_t value)
{
f90001c6:	1141                	addi	sp,sp,-16
f90001c8:	c606                	sw	ra,12(sp)
    uart_writeHex(BSP_UART_TERMINAL, (int)value);
f90001ca:	85aa                	mv	a1,a0
f90001cc:	e8010537          	lui	a0,0xe8010
f90001d0:	3785                	jal	f9000130 <uart_writeHex>
}
f90001d2:	40b2                	lw	ra,12(sp)
f90001d4:	0141                	addi	sp,sp,16
f90001d6:	8082                	ret

f90001d8 <main>:

void main(void)
{
f90001d8:	1101                	addi	sp,sp,-32
f90001da:	ce06                	sw	ra,28(sp)
f90001dc:	cc22                	sw	s0,24(sp)
f90001de:	ca26                	sw	s1,20(sp)
f90001e0:	c84a                	sw	s2,16(sp)
f90001e2:	c64e                	sw	s3,12(sp)
f90001e4:	c452                	sw	s4,8(sp)
f90001e6:	c256                	sw	s5,4(sp)
    uint32_t last_seq = 0;

    if ((uint32_t)csr_read(mhartid) != 0u) {
f90001e8:	f1402973          	csrr	s2,mhartid
f90001ec:	00090563          	beqz	s2,f90001f6 <main+0x1e>
        while (1) {
            asm volatile ("wfi");
f90001f0:	10500073          	wfi
f90001f4:	bff5                	j	f90001f0 <main+0x18>
        }
    }

    bsp_init();
f90001f6:	3fb5                	jal	f9000172 <bsp_init>
    uart_puts_raw("\r\nVision 160x90 APB frame test\r\n");
f90001f8:	f9000537          	lui	a0,0xf9000
f90001fc:	34450513          	addi	a0,a0,836 # f9000344 <__freertos_irq_stack_top+0xfffff724>
f9000200:	375d                	jal	f90001a6 <uart_puts_raw>
    uart_puts_raw("base=0x");
f9000202:	f9000537          	lui	a0,0xf9000
f9000206:	36850513          	addi	a0,a0,872 # f9000368 <__freertos_irq_stack_top+0xfffff748>
f900020a:	3f71                	jal	f90001a6 <uart_puts_raw>
    uart_hex(FRAME_APB_BASE);
f900020c:	e8100537          	lui	a0,0xe8100
f9000210:	3f5d                	jal	f90001c6 <uart_hex>
    uart_puts_raw(" magic=0x");
f9000212:	f9000537          	lui	a0,0xf9000
f9000216:	37050513          	addi	a0,a0,880 # f9000370 <__freertos_irq_stack_top+0xfffff750>
f900021a:	3771                	jal	f90001a6 <uart_puts_raw>
    uart_hex(reg_read(REG_MAGIC));
f900021c:	4501                	li	a0,0
f900021e:	3f95                	jal	f9000192 <reg_read>
f9000220:	375d                	jal	f90001c6 <uart_hex>
    uart_puts_raw(" dimensions=0x");
f9000222:	f9000537          	lui	a0,0xf9000
f9000226:	37c50513          	addi	a0,a0,892 # f900037c <__freertos_irq_stack_top+0xfffff75c>
f900022a:	3fb5                	jal	f90001a6 <uart_puts_raw>
    uart_hex(reg_read(REG_DIMENSIONS));
f900022c:	4521                	li	a0,8
f900022e:	3795                	jal	f9000192 <reg_read>
f9000230:	3f59                	jal	f90001c6 <uart_hex>
    uart_puts_raw("\r\n");
f9000232:	f9000537          	lui	a0,0xf9000
f9000236:	3b050513          	addi	a0,a0,944 # f90003b0 <__freertos_irq_stack_top+0xfffff790>
f900023a:	37b5                	jal	f90001a6 <uart_puts_raw>

    if (reg_read(REG_MAGIC) != EXPECTED_MAGIC) {
f900023c:	4501                	li	a0,0
f900023e:	3f91                	jal	f9000192 <reg_read>
f9000240:	564957b7          	lui	a5,0x56495
f9000244:	34e78793          	addi	a5,a5,846 # 5649534e <__stack_size+0x56494b4e>
f9000248:	00f51463          	bne	a0,a5,f9000250 <main+0x78>
    uint32_t last_seq = 0;
f900024c:	84ca                	mv	s1,s2
f900024e:	a05d                	j	f90002f4 <main+0x11c>
        uart_puts_raw("ERROR: APB frame window not detected\r\n");
f9000250:	f9000537          	lui	a0,0xf9000
f9000254:	38c50513          	addi	a0,a0,908 # f900038c <__freertos_irq_stack_top+0xfffff76c>
f9000258:	37b9                	jal	f90001a6 <uart_puts_raw>
        while (1) {
            asm volatile ("wfi");
f900025a:	10500073          	wfi
f900025e:	bff5                	j	f900025a <main+0x82>
            volatile uint32_t *pixels;

            reg_write(REG_CONTROL, CONTROL_CLAIM);
            bank = reg_read(REG_CLAIM_BANK);
            seq = reg_read(REG_CLAIM_SEQ);
            buffer_offset = reg_read(bank ? REG_BUFFER1 : REG_BUFFER0);
f9000260:	4571                	li	a0,28
f9000262:	a0d1                	j	f9000326 <main+0x14e>
            word_count = buffer_bytes >> 2;
            pixels = (volatile uint32_t *)(FRAME_APB_BASE + buffer_offset);

            first_word = pixels[0];
            for (i = 0; i < word_count; ++i) {
                checksum = (checksum << 5) | (checksum >> 27);
f9000264:	00541613          	slli	a2,s0,0x5
f9000268:	01b45693          	srli	a3,s0,0x1b
f900026c:	8ed1                	or	a3,a3,a2
                checksum ^= pixels[i];
f900026e:	00279613          	slli	a2,a5,0x2
f9000272:	963a                	add	a2,a2,a4
f9000274:	4200                	lw	s0,0(a2)
f9000276:	8c35                	xor	s0,s0,a3
            for (i = 0; i < word_count; ++i) {
f9000278:	0785                	addi	a5,a5,1
f900027a:	fea7e5e3          	bltu	a5,a0,f9000264 <main+0x8c>
            }
            last_word = pixels[word_count - 1u];
f900027e:	400007b7          	lui	a5,0x40000
f9000282:	17fd                	addi	a5,a5,-1
f9000284:	953e                	add	a0,a0,a5
f9000286:	050a                	slli	a0,a0,0x2
f9000288:	972a                	add	a4,a4,a0
f900028a:	00072a83          	lw	s5,0(a4)
            reg_write(REG_CONTROL, CONTROL_RELEASE);
f900028e:	4589                	li	a1,2
f9000290:	03000513          	li	a0,48
f9000294:	3721                	jal	f900019c <reg_write>

            uart_puts_raw("frame seq=0x");
f9000296:	f9000537          	lui	a0,0xf9000
f900029a:	3b450513          	addi	a0,a0,948 # f90003b4 <__freertos_irq_stack_top+0xfffff794>
f900029e:	3721                	jal	f90001a6 <uart_puts_raw>
            uart_hex(seq);
f90002a0:	8526                	mv	a0,s1
f90002a2:	3715                	jal	f90001c6 <uart_hex>
            uart_puts_raw(" bank=0x");
f90002a4:	f9000537          	lui	a0,0xf9000
f90002a8:	3c450513          	addi	a0,a0,964 # f90003c4 <__freertos_irq_stack_top+0xfffff7a4>
f90002ac:	3ded                	jal	f90001a6 <uart_puts_raw>
            uart_hex(bank);
f90002ae:	854e                	mv	a0,s3
f90002b0:	3f19                	jal	f90001c6 <uart_hex>
            uart_puts_raw(" first=0x");
f90002b2:	f9000537          	lui	a0,0xf9000
f90002b6:	3d050513          	addi	a0,a0,976 # f90003d0 <__freertos_irq_stack_top+0xfffff7b0>
f90002ba:	35f5                	jal	f90001a6 <uart_puts_raw>
            uart_hex(first_word);
f90002bc:	8552                	mv	a0,s4
f90002be:	3721                	jal	f90001c6 <uart_hex>
            uart_puts_raw(" last=0x");
f90002c0:	f9000537          	lui	a0,0xf9000
f90002c4:	3dc50513          	addi	a0,a0,988 # f90003dc <__freertos_irq_stack_top+0xfffff7bc>
f90002c8:	3df9                	jal	f90001a6 <uart_puts_raw>
            uart_hex(last_word);
f90002ca:	8556                	mv	a0,s5
f90002cc:	3ded                	jal	f90001c6 <uart_hex>
            uart_puts_raw(" checksum=0x");
f90002ce:	f9000537          	lui	a0,0xf9000
f90002d2:	3e850513          	addi	a0,a0,1000 # f90003e8 <__freertos_irq_stack_top+0xfffff7c8>
f90002d6:	3dc1                	jal	f90001a6 <uart_puts_raw>
            uart_hex(checksum);
f90002d8:	8522                	mv	a0,s0
f90002da:	35f5                	jal	f90001c6 <uart_hex>
            uart_puts_raw(" drops=0x");
f90002dc:	80018513          	addi	a0,gp,-2048 # f90003f8 <_data+0xb4>
f90002e0:	35d9                	jal	f90001a6 <uart_puts_raw>
            uart_hex(reg_read(REG_DROP_COUNT));
f90002e2:	02800513          	li	a0,40
f90002e6:	3575                	jal	f9000192 <reg_read>
f90002e8:	3df9                	jal	f90001c6 <uart_hex>
            uart_puts_raw("\r\n");
f90002ea:	f9000537          	lui	a0,0xf9000
f90002ee:	3b050513          	addi	a0,a0,944 # f90003b0 <__freertos_irq_stack_top+0xfffff790>
f90002f2:	3d55                	jal	f90001a6 <uart_puts_raw>
        uint32_t status = reg_read(REG_STATUS);
f90002f4:	4561                	li	a0,24
f90002f6:	3d71                	jal	f9000192 <reg_read>
f90002f8:	842a                	mv	s0,a0
        uint32_t seq = reg_read(REG_FRAME_SEQ);
f90002fa:	4541                	li	a0,16
f90002fc:	3d59                	jal	f9000192 <reg_read>
        if ((status & STATUS_FRAME_VALID) && (seq != last_seq)) {
f90002fe:	8809                	andi	s0,s0,2
f9000300:	d875                	beqz	s0,f90002f4 <main+0x11c>
f9000302:	fea489e3          	beq	s1,a0,f90002f4 <main+0x11c>
            reg_write(REG_CONTROL, CONTROL_CLAIM);
f9000306:	4585                	li	a1,1
f9000308:	03000513          	li	a0,48
f900030c:	3d41                	jal	f900019c <reg_write>
            bank = reg_read(REG_CLAIM_BANK);
f900030e:	03400513          	li	a0,52
f9000312:	3541                	jal	f9000192 <reg_read>
f9000314:	89aa                	mv	s3,a0
            seq = reg_read(REG_CLAIM_SEQ);
f9000316:	03800513          	li	a0,56
f900031a:	3da5                	jal	f9000192 <reg_read>
f900031c:	84aa                	mv	s1,a0
            buffer_offset = reg_read(bank ? REG_BUFFER1 : REG_BUFFER0);
f900031e:	f40981e3          	beqz	s3,f9000260 <main+0x88>
f9000322:	02000513          	li	a0,32
f9000326:	35b5                	jal	f9000192 <reg_read>
f9000328:	842a                	mv	s0,a0
            buffer_bytes = reg_read(REG_BUFFER_BYTES);
f900032a:	02400513          	li	a0,36
f900032e:	3595                	jal	f9000192 <reg_read>
            word_count = buffer_bytes >> 2;
f9000330:	8109                	srli	a0,a0,0x2
            pixels = (volatile uint32_t *)(FRAME_APB_BASE + buffer_offset);
f9000332:	e8100737          	lui	a4,0xe8100
f9000336:	9722                	add	a4,a4,s0
            first_word = pixels[0];
f9000338:	00072a03          	lw	s4,0(a4) # e8100000 <__freertos_irq_stack_top+0xef0ff3e0>
            for (i = 0; i < word_count; ++i) {
f900033c:	87ca                	mv	a5,s2
            uint32_t checksum = 0;
f900033e:	844a                	mv	s0,s2
            for (i = 0; i < word_count; ++i) {
f9000340:	bf2d                	j	f900027a <main+0xa2>
