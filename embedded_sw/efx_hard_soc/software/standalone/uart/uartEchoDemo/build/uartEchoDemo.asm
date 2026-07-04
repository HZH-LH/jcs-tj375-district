
build/uartEchoDemo.elf:     file format elf32-littleriscv


Disassembly of section .init:

00001000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
    1000:	00002197          	auipc	gp,0x2
    1004:	11018193          	addi	gp,gp,272 # 3110 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
    1008:	8201ac23          	sw	zero,-1992(gp) # 2948 <smp_lottery_lock>

0000100c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
    100c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
    1010:	c515                	beqz	a0,103c <init>

00001012 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
    1012:	8381a503          	lw	a0,-1992(gp) # 2948 <smp_lottery_lock>
	beqz a0, smp_slave
    1016:	dd75                	beqz	a0,1012 <smp_slave>

	fence r, r
    1018:	0220000f          	fence	r,r
    101c:	0000100f          	fence.i
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
    1020:	8341a783          	lw	a5,-1996(gp) # 2944 <__bss_start>
	li a0, 0
    1024:	4501                	li	a0,0
	li a1, 0
    1026:	4581                	li	a1,0
	li a2, 0
    1028:	4601                	li	a2,0
	jr a5
    102a:	8782                	jr	a5

0000102c <smp_unlock>:

.global   smp_unlock
.type    smp_unlock,%function
smp_unlock:
	sw a0, smp_lottery_target, a1
    102c:	82a1aa23          	sw	a0,-1996(gp) # 2944 <__bss_start>
	fence w, w
    1030:	0110000f          	fence	w,w
	li a0, 1
    1034:	4505                	li	a0,1
	sw a0, smp_lottery_lock, a1
    1036:	82a1ac23          	sw	a0,-1992(gp) # 2948 <smp_lottery_lock>
    ret
    103a:	8082                	ret

0000103c <init>:
#endif

init:
	la sp, _sp
    103c:	00003117          	auipc	sp,0x3
    1040:	91410113          	addi	sp,sp,-1772 # 3950 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
    1044:	00001517          	auipc	a0,0x1
    1048:	2d050513          	addi	a0,a0,720 # 2314 <_data>
	la a1, _data
    104c:	00001597          	auipc	a1,0x1
    1050:	2c858593          	addi	a1,a1,712 # 2314 <_data>
	la a2, _edata
    1054:	83418613          	addi	a2,gp,-1996 # 2944 <__bss_start>
	bgeu a1, a2, 2f
    1058:	00c5fa63          	bgeu	a1,a2,106c <init+0x30>
1:
	lw t0, (a0)
    105c:	00052283          	lw	t0,0(a0)
	sw t0, (a1)
    1060:	0055a023          	sw	t0,0(a1)
	addi a0, a0, 4
    1064:	0511                	addi	a0,a0,4
	addi a1, a1, 4
    1066:	0591                	addi	a1,a1,4
	bltu a1, a2, 1b
    1068:	fec5eae3          	bltu	a1,a2,105c <init+0x20>
2:

	/* Clear bss section */
	la a0, __bss_start
    106c:	83418513          	addi	a0,gp,-1996 # 2944 <__bss_start>
	la a1, _end
    1070:	84018593          	addi	a1,gp,-1984 # 2950 <_end>
	bgeu a0, a1, 2f
    1074:	00b57763          	bgeu	a0,a1,1082 <init+0x46>
1:
	sw zero, (a0)
    1078:	00052023          	sw	zero,0(a0)
	addi a0, a0, 4
    107c:	0511                	addi	a0,a0,4
	bltu a0, a1, 1b
    107e:	feb56de3          	bltu	a0,a1,1078 <init+0x3c>
2:

#ifndef NO_LIBC_INIT_ARRAY
	call __libc_init_array
    1082:	2049                	jal	1104 <__libc_init_array>
#endif

	call main
    1084:	2d39                	jal	16a2 <main>

00001086 <mainDone>:
mainDone:
    j mainDone
    1086:	a001                	j	1086 <mainDone>

00001088 <_init>:


	.globl _init
_init:
    ret
    1088:	8082                	ret

Disassembly of section .text:

0000108a <strcpy>:
    108a:	00b567b3          	or	a5,a0,a1
    108e:	8b8d                	andi	a5,a5,3
    1090:	efb9                	bnez	a5,10ee <strcpy+0x64>
    1092:	4198                	lw	a4,0(a1)
    1094:	7f7f86b7          	lui	a3,0x7f7f8
    1098:	f7f68693          	addi	a3,a3,-129 # 7f7f7f7f <__freertos_irq_stack_top+0x7f7f462f>
    109c:	00d777b3          	and	a5,a4,a3
    10a0:	97b6                	add	a5,a5,a3
    10a2:	8fd9                	or	a5,a5,a4
    10a4:	8fd5                	or	a5,a5,a3
    10a6:	567d                	li	a2,-1
    10a8:	04c79c63          	bne	a5,a2,1100 <strcpy+0x76>
    10ac:	862a                	mv	a2,a0
    10ae:	587d                	li	a6,-1
    10b0:	0611                	addi	a2,a2,4
    10b2:	0591                	addi	a1,a1,4
    10b4:	fee62e23          	sw	a4,-4(a2)
    10b8:	4198                	lw	a4,0(a1)
    10ba:	00d777b3          	and	a5,a4,a3
    10be:	97b6                	add	a5,a5,a3
    10c0:	8fd9                	or	a5,a5,a4
    10c2:	8fd5                	or	a5,a5,a3
    10c4:	ff0786e3          	beq	a5,a6,10b0 <strcpy+0x26>
    10c8:	0005c783          	lbu	a5,0(a1)
    10cc:	0015c703          	lbu	a4,1(a1)
    10d0:	0025c683          	lbu	a3,2(a1)
    10d4:	00f60023          	sb	a5,0(a2)
    10d8:	c799                	beqz	a5,10e6 <strcpy+0x5c>
    10da:	00e600a3          	sb	a4,1(a2)
    10de:	c701                	beqz	a4,10e6 <strcpy+0x5c>
    10e0:	00d60123          	sb	a3,2(a2)
    10e4:	e291                	bnez	a3,10e8 <strcpy+0x5e>
    10e6:	8082                	ret
    10e8:	000601a3          	sb	zero,3(a2)
    10ec:	8082                	ret
    10ee:	87aa                	mv	a5,a0
    10f0:	0005c703          	lbu	a4,0(a1)
    10f4:	0785                	addi	a5,a5,1
    10f6:	0585                	addi	a1,a1,1
    10f8:	fee78fa3          	sb	a4,-1(a5)
    10fc:	fb75                	bnez	a4,10f0 <strcpy+0x66>
    10fe:	8082                	ret
    1100:	862a                	mv	a2,a0
    1102:	b7d9                	j	10c8 <strcpy+0x3e>

00001104 <__libc_init_array>:
    1104:	1141                	addi	sp,sp,-16
    1106:	c422                	sw	s0,8(sp)
    1108:	c04a                	sw	s2,0(sp)
    110a:	00001417          	auipc	s0,0x1
    110e:	20a40413          	addi	s0,s0,522 # 2314 <_data>
    1112:	00001917          	auipc	s2,0x1
    1116:	20290913          	addi	s2,s2,514 # 2314 <_data>
    111a:	40890933          	sub	s2,s2,s0
    111e:	c606                	sw	ra,12(sp)
    1120:	c226                	sw	s1,4(sp)
    1122:	40295913          	srai	s2,s2,0x2
    1126:	00090963          	beqz	s2,1138 <__libc_init_array+0x34>
    112a:	4481                	li	s1,0
    112c:	401c                	lw	a5,0(s0)
    112e:	0485                	addi	s1,s1,1
    1130:	0411                	addi	s0,s0,4
    1132:	9782                	jalr	a5
    1134:	fe991ce3          	bne	s2,s1,112c <__libc_init_array+0x28>
    1138:	00001417          	auipc	s0,0x1
    113c:	1dc40413          	addi	s0,s0,476 # 2314 <_data>
    1140:	00001917          	auipc	s2,0x1
    1144:	1d490913          	addi	s2,s2,468 # 2314 <_data>
    1148:	40890933          	sub	s2,s2,s0
    114c:	40295913          	srai	s2,s2,0x2
    1150:	00090963          	beqz	s2,1162 <__libc_init_array+0x5e>
    1154:	4481                	li	s1,0
    1156:	401c                	lw	a5,0(s0)
    1158:	0485                	addi	s1,s1,1
    115a:	0411                	addi	s0,s0,4
    115c:	9782                	jalr	a5
    115e:	fe991ce3          	bne	s2,s1,1156 <__libc_init_array+0x52>
    1162:	40b2                	lw	ra,12(sp)
    1164:	4422                	lw	s0,8(sp)
    1166:	4492                	lw	s1,4(sp)
    1168:	4902                	lw	s2,0(sp)
    116a:	0141                	addi	sp,sp,16
    116c:	8082                	ret

0000116e <strcat>:
    116e:	1141                	addi	sp,sp,-16
    1170:	c422                	sw	s0,8(sp)
    1172:	c606                	sw	ra,12(sp)
    1174:	00357793          	andi	a5,a0,3
    1178:	842a                	mv	s0,a0
    117a:	e7a9                	bnez	a5,11c4 <strcat+0x56>
    117c:	4118                	lw	a4,0(a0)
    117e:	feff0637          	lui	a2,0xfeff0
    1182:	eff60613          	addi	a2,a2,-257 # fefefeff <__freertos_irq_stack_top+0xfefec5af>
    1186:	00c707b3          	add	a5,a4,a2
    118a:	808086b7          	lui	a3,0x80808
    118e:	fff74713          	not	a4,a4
    1192:	08068693          	addi	a3,a3,128 # 80808080 <__freertos_irq_stack_top+0x80804730>
    1196:	8ff9                	and	a5,a5,a4
    1198:	8ff5                	and	a5,a5,a3
    119a:	e78d                	bnez	a5,11c4 <strcat+0x56>
    119c:	0511                	addi	a0,a0,4
    119e:	4118                	lw	a4,0(a0)
    11a0:	00c707b3          	add	a5,a4,a2
    11a4:	fff74713          	not	a4,a4
    11a8:	8ff9                	and	a5,a5,a4
    11aa:	8ff5                	and	a5,a5,a3
    11ac:	ef81                	bnez	a5,11c4 <strcat+0x56>
    11ae:	0511                	addi	a0,a0,4
    11b0:	4118                	lw	a4,0(a0)
    11b2:	00c707b3          	add	a5,a4,a2
    11b6:	fff74713          	not	a4,a4
    11ba:	8ff9                	and	a5,a5,a4
    11bc:	8ff5                	and	a5,a5,a3
    11be:	dff9                	beqz	a5,119c <strcat+0x2e>
    11c0:	a011                	j	11c4 <strcat+0x56>
    11c2:	0505                	addi	a0,a0,1
    11c4:	00054783          	lbu	a5,0(a0)
    11c8:	ffed                	bnez	a5,11c2 <strcat+0x54>
    11ca:	35c1                	jal	108a <strcpy>
    11cc:	8522                	mv	a0,s0
    11ce:	40b2                	lw	ra,12(sp)
    11d0:	4422                	lw	s0,8(sp)
    11d2:	0141                	addi	sp,sp,16
    11d4:	8082                	ret

000011d6 <strlen>:
    11d6:	00357793          	andi	a5,a0,3
    11da:	872a                	mv	a4,a0
    11dc:	e3a1                	bnez	a5,121c <strlen+0x46>
    11de:	7f7f86b7          	lui	a3,0x7f7f8
    11e2:	f7f68693          	addi	a3,a3,-129 # 7f7f7f7f <__freertos_irq_stack_top+0x7f7f462f>
    11e6:	55fd                	li	a1,-1
    11e8:	0711                	addi	a4,a4,4
    11ea:	ffc72603          	lw	a2,-4(a4)
    11ee:	00d677b3          	and	a5,a2,a3
    11f2:	97b6                	add	a5,a5,a3
    11f4:	8fd1                	or	a5,a5,a2
    11f6:	8fd5                	or	a5,a5,a3
    11f8:	feb788e3          	beq	a5,a1,11e8 <strlen+0x12>
    11fc:	ffc74683          	lbu	a3,-4(a4)
    1200:	40a707b3          	sub	a5,a4,a0
    1204:	ffd74603          	lbu	a2,-3(a4)
    1208:	ffe74503          	lbu	a0,-2(a4)
    120c:	c68d                	beqz	a3,1236 <strlen+0x60>
    120e:	c20d                	beqz	a2,1230 <strlen+0x5a>
    1210:	00a03533          	snez	a0,a0
    1214:	953e                	add	a0,a0,a5
    1216:	1579                	addi	a0,a0,-2
    1218:	8082                	ret
    121a:	d2f1                	beqz	a3,11de <strlen+0x8>
    121c:	00074783          	lbu	a5,0(a4)
    1220:	0705                	addi	a4,a4,1
    1222:	00377693          	andi	a3,a4,3
    1226:	fbf5                	bnez	a5,121a <strlen+0x44>
    1228:	8f09                	sub	a4,a4,a0
    122a:	fff70513          	addi	a0,a4,-1
    122e:	8082                	ret
    1230:	ffd78513          	addi	a0,a5,-3
    1234:	8082                	ret
    1236:	ffc78513          	addi	a0,a5,-4
    123a:	8082                	ret

0000123c <uart_writeAvailability>:
#include "type.h"
#include "soc.h"


    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
    123c:	4148                	lw	a0,4(a0)
*          of available spaces for writing data from bits 23 to 16. It then
*          returns this value after masking with 0xFF.
*
******************************************************************************/
    static u32 uart_writeAvailability(u32 reg){
        return (read_u32(reg + UART_STATUS) >> 16) & 0xFF;
    123e:	8141                	srli	a0,a0,0x10
    }
    1240:	0ff57513          	andi	a0,a0,255
    1244:	8082                	ret

00001246 <uart_readOccupancy>:
    1246:	4148                	lw	a0,4(a0)
*          of occupied spaces for reading data from bits 31 to 24.
*
******************************************************************************/
    static u32 uart_readOccupancy(u32 reg){
        return read_u32(reg + UART_STATUS) >> 24;
    }
    1248:	8161                	srli	a0,a0,0x18
    124a:	8082                	ret

0000124c <uart_write>:
* @note    The function waits until there is available space in the UART buffer
*          for writing data. Once space is available, it writes the character
*          data to the UART data register.
*
******************************************************************************/
    static void uart_write(u32 reg, char data){
    124c:	1141                	addi	sp,sp,-16
    124e:	c606                	sw	ra,12(sp)
    1250:	c422                	sw	s0,8(sp)
    1252:	c226                	sw	s1,4(sp)
    1254:	842a                	mv	s0,a0
    1256:	84ae                	mv	s1,a1
        while(uart_writeAvailability(reg) == 0);
    1258:	8522                	mv	a0,s0
    125a:	37cd                	jal	123c <uart_writeAvailability>
    125c:	dd75                	beqz	a0,1258 <uart_write+0xc>
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
    125e:	c004                	sw	s1,0(s0)
        write_u32(data, reg + UART_DATA);
    }
    1260:	40b2                	lw	ra,12(sp)
    1262:	4422                	lw	s0,8(sp)
    1264:	4492                	lw	s1,4(sp)
    1266:	0141                	addi	sp,sp,16
    1268:	8082                	ret

0000126a <uart_read>:
* @note    The function waits until there is data available in the UART buffer
*          for reading. Once data is available, it reads the character data from
*          the UART data register and returns it.
*
******************************************************************************/
    static char uart_read(u32 reg){
    126a:	1141                	addi	sp,sp,-16
    126c:	c606                	sw	ra,12(sp)
    126e:	c422                	sw	s0,8(sp)
    1270:	842a                	mv	s0,a0
        while(uart_readOccupancy(reg) == 0);
    1272:	8522                	mv	a0,s0
    1274:	3fc9                	jal	1246 <uart_readOccupancy>
    1276:	dd75                	beqz	a0,1272 <uart_read+0x8>
        return *((volatile u32*) address);
    1278:	4008                	lw	a0,0(s0)
        return read_u32(reg + UART_DATA);
    }
    127a:	0ff57513          	andi	a0,a0,255
    127e:	40b2                	lw	ra,12(sp)
    1280:	4422                	lw	s0,8(sp)
    1282:	0141                	addi	sp,sp,16
    1284:	8082                	ret

00001286 <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    1286:	45dc                	lw	a5,12(a1)
        *((volatile u32*) address) = data;
    1288:	c51c                	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    128a:	419c                	lw	a5,0(a1)
    128c:	17fd                	addi	a5,a5,-1
    128e:	41d8                	lw	a4,4(a1)
    1290:	0722                	slli	a4,a4,0x8
    1292:	8fd9                	or	a5,a5,a4
    1294:	4598                	lw	a4,8(a1)
    1296:	0742                	slli	a4,a4,0x10
    1298:	8fd9                	or	a5,a5,a4
    129a:	c55c                	sw	a5,12(a0)
    }
    129c:	8082                	ret

0000129e <_putchar>:
#include <math.h>
#include <string.h>
#include "bsp.h"

#if (ENABLE_BSP_PRINTF)
    static void _putchar(char character){
    129e:	1141                	addi	sp,sp,-16
    12a0:	c606                	sw	ra,12(sp)
        #if (ENABLE_SEMIHOSTING_PRINT == 1)
            sh_writec(character);
        #else
            bsp_putChar(character);
    12a2:	85aa                	mv	a1,a0
    12a4:	e8010537          	lui	a0,0xe8010
    12a8:	3755                	jal	124c <uart_write>
        #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    12aa:	40b2                	lw	ra,12(sp)
    12ac:	0141                	addi	sp,sp,16
    12ae:	8082                	ret

000012b0 <_putchar_s>:

    static void _putchar_s(char *p)
    {
    12b0:	1141                	addi	sp,sp,-16
    12b2:	c606                	sw	ra,12(sp)
    12b4:	c422                	sw	s0,8(sp)
    12b6:	842a                	mv	s0,a0
    #if (ENABLE_SEMIHOSTING_PRINT == 1)
        sh_write0(p);
    #else
        while (*p)
    12b8:	00044503          	lbu	a0,0(s0)
    12bc:	c501                	beqz	a0,12c4 <_putchar_s+0x14>
            _putchar(*(p++));
    12be:	0405                	addi	s0,s0,1
    12c0:	3ff9                	jal	129e <_putchar>
    12c2:	bfdd                	j	12b8 <_putchar_s+0x8>
    #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    12c4:	40b2                	lw	ra,12(sp)
    12c6:	4422                	lw	s0,8(sp)
    12c8:	0141                	addi	sp,sp,16
    12ca:	8082                	ret

000012cc <bsp_printHex>:

        static void bsp_printHex(uint32_t val)
    {
    12cc:	1141                	addi	sp,sp,-16
    12ce:	c606                	sw	ra,12(sp)
    12d0:	c422                	sw	s0,8(sp)
    12d2:	c226                	sw	s1,4(sp)
    12d4:	84aa                	mv	s1,a0
        uint32_t digits;
        digits =8;

        for (int i = (4*digits)-4; i >= 0; i -= 4) {
    12d6:	4471                	li	s0,28
    12d8:	a829                	j	12f2 <bsp_printHex+0x26>
            _putchar("0123456789ABCDEF"[(val >> i) % 16]);
    12da:	0084d7b3          	srl	a5,s1,s0
    12de:	00f7f713          	andi	a4,a5,15
    12e2:	6789                	lui	a5,0x2
    12e4:	31878793          	addi	a5,a5,792 # 2318 <_data+0x4>
    12e8:	97ba                	add	a5,a5,a4
    12ea:	0007c503          	lbu	a0,0(a5)
    12ee:	3f45                	jal	129e <_putchar>
        for (int i = (4*digits)-4; i >= 0; i -= 4) {
    12f0:	1471                	addi	s0,s0,-4
    12f2:	fe0454e3          	bgez	s0,12da <bsp_printHex+0xe>
        }
    }
    12f6:	40b2                	lw	ra,12(sp)
    12f8:	4422                	lw	s0,8(sp)
    12fa:	4492                	lw	s1,4(sp)
    12fc:	0141                	addi	sp,sp,16
    12fe:	8082                	ret

00001300 <bsp_printHex_lower>:

    static void bsp_printHex_lower(uint32_t val)
    {
    1300:	1141                	addi	sp,sp,-16
    1302:	c606                	sw	ra,12(sp)
    1304:	c422                	sw	s0,8(sp)
    1306:	c226                	sw	s1,4(sp)
    1308:	84aa                	mv	s1,a0
        uint32_t digits;
        digits =8;

        for (int i = (4*digits)-4; i >= 0; i -= 4) {
    130a:	4471                	li	s0,28
    130c:	a829                	j	1326 <bsp_printHex_lower+0x26>
            _putchar("0123456789abcdef"[(val >> i) % 16]);
    130e:	0084d7b3          	srl	a5,s1,s0
    1312:	00f7f713          	andi	a4,a5,15
    1316:	6789                	lui	a5,0x2
    1318:	32c78793          	addi	a5,a5,812 # 232c <_data+0x18>
    131c:	97ba                	add	a5,a5,a4
    131e:	0007c503          	lbu	a0,0(a5)
    1322:	3fb5                	jal	129e <_putchar>
        for (int i = (4*digits)-4; i >= 0; i -= 4) {
    1324:	1471                	addi	s0,s0,-4
    1326:	fe0454e3          	bgez	s0,130e <bsp_printHex_lower+0xe>

        }
    }
    132a:	40b2                	lw	ra,12(sp)
    132c:	4422                	lw	s0,8(sp)
    132e:	4492                	lw	s1,4(sp)
    1330:	0141                	addi	sp,sp,16
    1332:	8082                	ret

00001334 <bsp_printf_c>:
*
* @param c: The character to be output.
*
******************************************************************************/
    static void bsp_printf_c(int c)
    {
    1334:	1141                	addi	sp,sp,-16
    1336:	c606                	sw	ra,12(sp)
        _putchar(c);
    1338:	0ff57513          	andi	a0,a0,255
    133c:	378d                	jal	129e <_putchar>
    }
    133e:	40b2                	lw	ra,12(sp)
    1340:	0141                	addi	sp,sp,16
    1342:	8082                	ret

00001344 <bsp_printf_s>:
*
* @param s: A pointer to the null-terminated string to be output.
*
*******************************************************************************/
    static void bsp_printf_s(char *p)
    {
    1344:	1141                	addi	sp,sp,-16
    1346:	c606                	sw	ra,12(sp)
        _putchar_s(p);
    1348:	37a5                	jal	12b0 <_putchar_s>
    }
    134a:	40b2                	lw	ra,12(sp)
    134c:	0141                	addi	sp,sp,16
    134e:	8082                	ret

00001350 <bsp_printf_d>:
* - Handles negative numbers by printing a '-' sign.
* - Uses the 'bsp_printf_c' function to print each character.
*
******************************************************************************/
    static void bsp_printf_d(int val)
    {
    1350:	7179                	addi	sp,sp,-48
    1352:	d606                	sw	ra,44(sp)
    1354:	d422                	sw	s0,40(sp)
    1356:	d226                	sw	s1,36(sp)
    1358:	84aa                	mv	s1,a0
        char buffer[32];
        char *p = buffer;
        if (val < 0) {
    135a:	00054463          	bltz	a0,1362 <bsp_printf_d+0x12>
    {
    135e:	840a                	mv	s0,sp
    1360:	a00d                	j	1382 <bsp_printf_d+0x32>
            bsp_printf_c('-');
    1362:	02d00513          	li	a0,45
    1366:	37f9                	jal	1334 <bsp_printf_c>
            val = -val;
    1368:	409004b3          	neg	s1,s1
    136c:	bfcd                	j	135e <bsp_printf_d+0xe>
        }
        while (val || p == buffer) {
            *(p++) = '0' + val % 10;
    136e:	4729                	li	a4,10
    1370:	02e4e7b3          	rem	a5,s1,a4
    1374:	03078793          	addi	a5,a5,48
    1378:	00f40023          	sb	a5,0(s0)
            val = val / 10;
    137c:	02e4c4b3          	div	s1,s1,a4
            *(p++) = '0' + val % 10;
    1380:	0405                	addi	s0,s0,1
        while (val || p == buffer) {
    1382:	f4f5                	bnez	s1,136e <bsp_printf_d+0x1e>
    1384:	878a                	mv	a5,sp
    1386:	fef404e3          	beq	s0,a5,136e <bsp_printf_d+0x1e>
    138a:	a029                	j	1394 <bsp_printf_d+0x44>
        }
        while (p != buffer)
            bsp_printf_c(*(--p));
    138c:	147d                	addi	s0,s0,-1
    138e:	00044503          	lbu	a0,0(s0)
    1392:	374d                	jal	1334 <bsp_printf_c>
        while (p != buffer)
    1394:	878a                	mv	a5,sp
    1396:	fef41be3          	bne	s0,a5,138c <bsp_printf_d+0x3c>
    }
    139a:	50b2                	lw	ra,44(sp)
    139c:	5422                	lw	s0,40(sp)
    139e:	5492                	lw	s1,36(sp)
    13a0:	6145                	addi	sp,sp,48
    13a2:	8082                	ret

000013a4 <bsp_printf_x>:
* - Calls 'bsp_printHex_lower' to print the hexadecimal representation.
* - Determines the number of leading zeros to be printed based on the value.
*
******************************************************************************/
    static void bsp_printf_x(int val)
    {
    13a4:	1141                	addi	sp,sp,-16
    13a6:	c606                	sw	ra,12(sp)
        int i,digi=2;

        for(i=0;i<8;i++)
    13a8:	4701                	li	a4,0
    13aa:	479d                	li	a5,7
    13ac:	00e7cb63          	blt	a5,a4,13c2 <bsp_printf_x+0x1e>
        {
            if((val & (0xFFFFFFF0 <<(4*i))) == 0)
    13b0:	00271693          	slli	a3,a4,0x2
    13b4:	57c1                	li	a5,-16
    13b6:	00d797b3          	sll	a5,a5,a3
    13ba:	8fe9                	and	a5,a5,a0
    13bc:	c399                	beqz	a5,13c2 <bsp_printf_x+0x1e>
        for(i=0;i<8;i++)
    13be:	0705                	addi	a4,a4,1
    13c0:	b7ed                	j	13aa <bsp_printf_x+0x6>
            {
                digi=i+1;
                break;
            }
        }
        bsp_printHex_lower(val);
    13c2:	3f3d                	jal	1300 <bsp_printHex_lower>
    }
    13c4:	40b2                	lw	ra,12(sp)
    13c6:	0141                	addi	sp,sp,16
    13c8:	8082                	ret

000013ca <bsp_printf_X>:
* - Calls 'bsp_printHex' to print the uppercase hexadecimal representation.
* - Determines the number of leading zeros to be printed based on the value.
*
******************************************************************************/
    static void bsp_printf_X(int val)
        {
    13ca:	1141                	addi	sp,sp,-16
    13cc:	c606                	sw	ra,12(sp)
            int i,digi=2;

            for(i=0;i<8;i++)
    13ce:	4701                	li	a4,0
    13d0:	479d                	li	a5,7
    13d2:	00e7cb63          	blt	a5,a4,13e8 <bsp_printf_X+0x1e>
            {
                if((val & (0xFFFFFFF0 <<(4*i))) == 0)
    13d6:	00271693          	slli	a3,a4,0x2
    13da:	57c1                	li	a5,-16
    13dc:	00d797b3          	sll	a5,a5,a3
    13e0:	8fe9                	and	a5,a5,a0
    13e2:	c399                	beqz	a5,13e8 <bsp_printf_X+0x1e>
            for(i=0;i<8;i++)
    13e4:	0705                	addi	a4,a4,1
    13e6:	b7ed                	j	13d0 <bsp_printf_X+0x6>
                {
                    digi=i+1;
                    break;
                }
            }
            bsp_printHex(val);
    13e8:	35d5                	jal	12cc <bsp_printHex>
        }
    13ea:	40b2                	lw	ra,12(sp)
    13ec:	0141                	addi	sp,sp,16
    13ee:	8082                	ret

000013f0 <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
    13f0:	1101                	addi	sp,sp,-32
    13f2:	ce06                	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
    13f4:	47a1                	li	a5,8
    13f6:	c03e                	sw	a5,0(sp)
        uartConfig.parity       = NONE;
    13f8:	c202                	sw	zero,4(sp)
        uartConfig.stop         = ONE;
    13fa:	c402                	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
    13fc:	10e00793          	li	a5,270
    1400:	c63e                	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
    1402:	858a                	mv	a1,sp
    1404:	e8010537          	lui	a0,0xe8010
    1408:	3dbd                	jal	1286 <uart_applyConfig>
    }
    140a:	40f2                	lw	ra,28(sp)
    140c:	6105                	addi	sp,sp,32
    140e:	8082                	ret

00001410 <reverse>:
     {
    1410:	1141                	addi	sp,sp,-16
    1412:	c606                	sw	ra,12(sp)
    1414:	c422                	sw	s0,8(sp)
    1416:	842a                	mv	s0,a0
          for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
    1418:	3b7d                	jal	11d6 <strlen>
    141a:	157d                	addi	a0,a0,-1
    141c:	4781                	li	a5,0
    141e:	02a7d163          	bge	a5,a0,1440 <reverse+0x30>
              c = s[i];
    1422:	00f406b3          	add	a3,s0,a5
    1426:	0006c603          	lbu	a2,0(a3)
              s[i] = s[j];
    142a:	00a40733          	add	a4,s0,a0
    142e:	00074583          	lbu	a1,0(a4)
    1432:	00b68023          	sb	a1,0(a3)
              s[j] = c;
    1436:	00c70023          	sb	a2,0(a4)
          for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
    143a:	0785                	addi	a5,a5,1
    143c:	157d                	addi	a0,a0,-1
    143e:	b7c5                	j	141e <reverse+0xe>
     }
    1440:	40b2                	lw	ra,12(sp)
    1442:	4422                	lw	s0,8(sp)
    1444:	0141                	addi	sp,sp,16
    1446:	8082                	ret

00001448 <itos>:
     {
    1448:	1141                	addi	sp,sp,-16
    144a:	c606                	sw	ra,12(sp)
         if ((sign = n) < 0)  /* record sign */
    144c:	00054563          	bltz	a0,1456 <itos+0xe>
    1450:	862a                	mv	a2,a0
    1452:	4801                	li	a6,0
    1454:	a031                	j	1460 <itos+0x18>
             n = -n;          /* make n positive */
    1456:	40a00633          	neg	a2,a0
    145a:	bfe5                	j	1452 <itos+0xa>
             s[i++] = n % 10 + '0';   /* get next digit */
    145c:	8846                	mv	a6,a7
         } while ((n /= 10) > 0);     /* delete it */
    145e:	863e                	mv	a2,a5
             s[i++] = n % 10 + '0';   /* get next digit */
    1460:	47a9                	li	a5,10
    1462:	02f666b3          	rem	a3,a2,a5
    1466:	00180893          	addi	a7,a6,1
    146a:	01058733          	add	a4,a1,a6
    146e:	03068693          	addi	a3,a3,48
    1472:	00d70023          	sb	a3,0(a4)
         } while ((n /= 10) > 0);     /* delete it */
    1476:	02f647b3          	div	a5,a2,a5
    147a:	4725                	li	a4,9
    147c:	fec740e3          	blt	a4,a2,145c <itos+0x14>
         if (sign < 0)
    1480:	00054a63          	bltz	a0,1494 <itos+0x4c>
         s[i] = '\0';
    1484:	98ae                	add	a7,a7,a1
    1486:	00088023          	sb	zero,0(a7)
         reverse(s);
    148a:	852e                	mv	a0,a1
    148c:	3751                	jal	1410 <reverse>
    }
    148e:	40b2                	lw	ra,12(sp)
    1490:	0141                	addi	sp,sp,16
    1492:	8082                	ret
             s[i++] = '-';
    1494:	98ae                	add	a7,a7,a1
    1496:	02d00793          	li	a5,45
    149a:	00f88023          	sb	a5,0(a7)
    149e:	00280893          	addi	a7,a6,2
    14a2:	b7cd                	j	1484 <itos+0x3c>

000014a4 <ftoa>:
    {
    14a4:	1101                	addi	sp,sp,-32
    14a6:	ce06                	sw	ra,28(sp)
    14a8:	cc22                	sw	s0,24(sp)
    14aa:	ca26                	sw	s1,20(sp)
    14ac:	a422                	fsd	fs0,8(sp)
    14ae:	a026                	fsd	fs1,0(sp)
    14b0:	842e                	mv	s0,a1
        int ipart = (int)n;
    14b2:	c20517d3          	fcvt.w.d	a5,fa0,rtz
        double fpart = n - (double)ipart;
    14b6:	d2078453          	fcvt.d.w	fs0,a5
    14ba:	0a857453          	fsub.d	fs0,fa0,fs0
        itos(n, res1);
    14be:	85aa                	mv	a1,a0
    14c0:	853e                	mv	a0,a5
    14c2:	3759                	jal	1448 <itos>
        *res2 = '.';
    14c4:	02e00793          	li	a5,46
    14c8:	00f40023          	sb	a5,0(s0)
        res2++;
    14cc:	00140493          	addi	s1,s0,1
        fpart_f = (float)fpart * pow(10, afterpoint);
    14d0:	40147453          	fcvt.s.d	fs0,fs0
    14d4:	420404d3          	fcvt.d.s	fs1,fs0
    14d8:	8181b407          	fld	fs0,-2024(gp) # 2928 <_impure_ptr+0x4>
    14dc:	1284f4d3          	fmul.d	fs1,fs1,fs0
    14e0:	4014f4d3          	fcvt.s.d	fs1,fs1
        if (fpart_f<0)
    14e4:	f00007d3          	fmv.w.x	fa5,zero
    14e8:	a0f497d3          	flt.s	a5,fs1,fa5
    14ec:	eb95                	bnez	a5,1520 <ftoa+0x7c>
        for (int i=afterpoint; i>0; i--)
    14ee:	4411                	li	s0,4
    14f0:	04805163          	blez	s0,1532 <ftoa+0x8e>
            if ((fpart_f<(1 * pow(10, i-1))) && (fpart_f>0))
    14f4:	42048453          	fcvt.d.s	fs0,fs1
    14f8:	147d                	addi	s0,s0,-1
    14fa:	d20405d3          	fcvt.d.w	fa1,s0
    14fe:	8201b507          	fld	fa0,-2016(gp) # 2930 <_impure_ptr+0xc>
    1502:	2ac9                	jal	16d4 <pow>
    1504:	a2a417d3          	flt.d	a5,fs0,fa0
    1508:	d7e5                	beqz	a5,14f0 <ftoa+0x4c>
    150a:	f00007d3          	fmv.w.x	fa5,zero
    150e:	a09797d3          	flt.s	a5,fa5,fs1
    1512:	dff9                	beqz	a5,14f0 <ftoa+0x4c>
                *res2='0';
    1514:	03000793          	li	a5,48
    1518:	00f48023          	sb	a5,0(s1)
                res2++;
    151c:	0485                	addi	s1,s1,1
    151e:	bfc9                	j	14f0 <ftoa+0x4c>
            *res2 = '-';
    1520:	02d00793          	li	a5,45
    1524:	00f400a3          	sb	a5,1(s0)
            res2++;
    1528:	00240493          	addi	s1,s0,2
            fpart_f = -(fpart_f);
    152c:	209494d3          	fneg.s	fs1,fs1
    1530:	bf7d                	j	14ee <ftoa+0x4a>
        itos((int)fpart_f, res2);
    1532:	85a6                	mv	a1,s1
    1534:	c0049553          	fcvt.w.s	a0,fs1,rtz
    1538:	3f01                	jal	1448 <itos>
    }
    153a:	40f2                	lw	ra,28(sp)
    153c:	4462                	lw	s0,24(sp)
    153e:	44d2                	lw	s1,20(sp)
    1540:	2422                	fld	fs0,8(sp)
    1542:	2482                	fld	fs1,0(sp)
    1544:	6105                	addi	sp,sp,32
    1546:	8082                	ret

00001548 <print_float>:
    {
    1548:	7139                	addi	sp,sp,-64
    154a:	de06                	sw	ra,60(sp)
    154c:	dc22                	sw	s0,56(sp)
        ftoa(val, sval, fval);
    154e:	006c                	addi	a1,sp,12
    1550:	0828                	addi	a0,sp,24
    1552:	3f89                	jal	14a4 <ftoa>
        if (fval[1] == '-')
    1554:	00d14703          	lbu	a4,13(sp)
    1558:	02d00793          	li	a5,45
    155c:	04f70363          	beq	a4,a5,15a2 <print_float+0x5a>
        neg=0;
    1560:	4401                	li	s0,0
        strcat(sval, fval);
    1562:	006c                	addi	a1,sp,12
    1564:	0828                	addi	a0,sp,24
    1566:	3121                	jal	116e <strcat>
        if ((sval[0] != '-') && (neg == 1))
    1568:	01814703          	lbu	a4,24(sp)
    156c:	02d00793          	li	a5,45
    1570:	00f70363          	beq	a4,a5,1576 <print_float+0x2e>
    1574:	e839                	bnez	s0,15ca <print_float+0x82>
        _putchar_s(sval);
    1576:	0828                	addi	a0,sp,24
    1578:	3b25                	jal	12b0 <_putchar_s>
    }
    157a:	50f2                	lw	ra,60(sp)
    157c:	5462                	lw	s0,56(sp)
    157e:	6121                	addi	sp,sp,64
    1580:	8082                	ret
                fval[i-1] = fval[i];
    1582:	fff78713          	addi	a4,a5,-1
    1586:	1814                	addi	a3,sp,48
    1588:	96be                	add	a3,a3,a5
    158a:	fdc6c683          	lbu	a3,-36(a3)
    158e:	1810                	addi	a2,sp,48
    1590:	9732                	add	a4,a4,a2
    1592:	fcd70e23          	sb	a3,-36(a4)
                i++;
    1596:	0785                	addi	a5,a5,1
            while (i<10)
    1598:	4725                	li	a4,9
    159a:	fef754e3          	bge	a4,a5,1582 <print_float+0x3a>
            neg = 1;
    159e:	4405                	li	s0,1
    15a0:	b7c9                	j	1562 <print_float+0x1a>
        i=2;
    15a2:	4789                	li	a5,2
    15a4:	bfd5                	j	1598 <print_float+0x50>
                sval[j+1] = sval[j];
    15a6:	00178713          	addi	a4,a5,1
    15aa:	1814                	addi	a3,sp,48
    15ac:	96be                	add	a3,a3,a5
    15ae:	fe86c683          	lbu	a3,-24(a3)
    15b2:	1810                	addi	a2,sp,48
    15b4:	9732                	add	a4,a4,a2
    15b6:	fed70423          	sb	a3,-24(a4)
                j--;
    15ba:	17fd                	addi	a5,a5,-1
            while (j>=0)
    15bc:	fe07d5e3          	bgez	a5,15a6 <print_float+0x5e>
            sval[0] = '-';
    15c0:	02d00793          	li	a5,45
    15c4:	00f10c23          	sb	a5,24(sp)
    15c8:	b77d                	j	1576 <print_float+0x2e>
        j=19;
    15ca:	47cd                	li	a5,19
    15cc:	bfc5                	j	15bc <print_float+0x74>

000015ce <bsp_printf>:
* - Handles each format specifier by calling the appropriate helper function.
* - If floating-point support is disabled, prints a warning for the 'f' specifier.
*
******************************************************************************/
    static void bsp_printf(const char *format, ...)
    {
    15ce:	7139                	addi	sp,sp,-64
    15d0:	ce06                	sw	ra,28(sp)
    15d2:	cc22                	sw	s0,24(sp)
    15d4:	ca26                	sw	s1,20(sp)
    15d6:	84aa                	mv	s1,a0
    15d8:	d22e                	sw	a1,36(sp)
    15da:	d432                	sw	a2,40(sp)
    15dc:	d636                	sw	a3,44(sp)
    15de:	d83a                	sw	a4,48(sp)
    15e0:	da3e                	sw	a5,52(sp)
    15e2:	dc42                	sw	a6,56(sp)
    15e4:	de46                	sw	a7,60(sp)
        int i;
        va_list ap;

        va_start(ap, format);
    15e6:	105c                	addi	a5,sp,36
    15e8:	c63e                	sw	a5,12(sp)

        for (i = 0; format[i]; i++)
    15ea:	4401                	li	s0,0
    15ec:	a801                	j	15fc <bsp_printf+0x2e>
            if (format[i] == '%') {
                while (format[++i]) {
                    if (format[i] == 'c') {
                        bsp_printf_c(va_arg(ap,int));
    15ee:	47b2                	lw	a5,12(sp)
    15f0:	00478713          	addi	a4,a5,4
    15f4:	c63a                	sw	a4,12(sp)
    15f6:	4388                	lw	a0,0(a5)
    15f8:	3b35                	jal	1334 <bsp_printf_c>
        for (i = 0; format[i]; i++)
    15fa:	0405                	addi	s0,s0,1
    15fc:	008487b3          	add	a5,s1,s0
    1600:	0007c503          	lbu	a0,0(a5)
    1604:	c951                	beqz	a0,1698 <bsp_printf+0xca>
            if (format[i] == '%') {
    1606:	02500793          	li	a5,37
    160a:	04f50063          	beq	a0,a5,164a <bsp_printf+0x7c>
                        break;
                    }
#endif //#if (ENABLE_FLOATING_POINT_SUPPORT)
                }
            } else
                bsp_printf_c(format[i]);
    160e:	331d                	jal	1334 <bsp_printf_c>
    1610:	b7ed                	j	15fa <bsp_printf+0x2c>
                        bsp_printf_s(va_arg(ap,char*));
    1612:	47b2                	lw	a5,12(sp)
    1614:	00478713          	addi	a4,a5,4
    1618:	c63a                	sw	a4,12(sp)
    161a:	4388                	lw	a0,0(a5)
    161c:	3325                	jal	1344 <bsp_printf_s>
                        break;
    161e:	bff1                	j	15fa <bsp_printf+0x2c>
                        bsp_printf_d(va_arg(ap,int));
    1620:	47b2                	lw	a5,12(sp)
    1622:	00478713          	addi	a4,a5,4
    1626:	c63a                	sw	a4,12(sp)
    1628:	4388                	lw	a0,0(a5)
    162a:	331d                	jal	1350 <bsp_printf_d>
                        break;
    162c:	b7f9                	j	15fa <bsp_printf+0x2c>
                        bsp_printf_X(va_arg(ap,int));
    162e:	47b2                	lw	a5,12(sp)
    1630:	00478713          	addi	a4,a5,4
    1634:	c63a                	sw	a4,12(sp)
    1636:	4388                	lw	a0,0(a5)
    1638:	3b49                	jal	13ca <bsp_printf_X>
                        break;
    163a:	b7c1                	j	15fa <bsp_printf+0x2c>
                        bsp_printf_x(va_arg(ap,int));
    163c:	47b2                	lw	a5,12(sp)
    163e:	00478713          	addi	a4,a5,4
    1642:	c63a                	sw	a4,12(sp)
    1644:	4388                	lw	a0,0(a5)
    1646:	3bb9                	jal	13a4 <bsp_printf_x>
                        break;
    1648:	bf4d                	j	15fa <bsp_printf+0x2c>
                while (format[++i]) {
    164a:	0405                	addi	s0,s0,1
    164c:	008487b3          	add	a5,s1,s0
    1650:	0007c783          	lbu	a5,0(a5)
    1654:	d3dd                	beqz	a5,15fa <bsp_printf+0x2c>
                    if (format[i] == 'c') {
    1656:	06300713          	li	a4,99
    165a:	f8e78ae3          	beq	a5,a4,15ee <bsp_printf+0x20>
                    else if (format[i] == 's') {
    165e:	07300713          	li	a4,115
    1662:	fae788e3          	beq	a5,a4,1612 <bsp_printf+0x44>
                    else if (format[i] == 'd') {
    1666:	06400713          	li	a4,100
    166a:	fae78be3          	beq	a5,a4,1620 <bsp_printf+0x52>
                    else if (format[i] == 'X') {
    166e:	05800713          	li	a4,88
    1672:	fae78ee3          	beq	a5,a4,162e <bsp_printf+0x60>
                    else if (format[i] == 'x') {
    1676:	07800713          	li	a4,120
    167a:	fce781e3          	beq	a5,a4,163c <bsp_printf+0x6e>
                    else if (format[i] == 'f') {
    167e:	06600713          	li	a4,102
    1682:	fce794e3          	bne	a5,a4,164a <bsp_printf+0x7c>
                        print_float(va_arg(ap,double));
    1686:	47b2                	lw	a5,12(sp)
    1688:	079d                	addi	a5,a5,7
    168a:	9be1                	andi	a5,a5,-8
    168c:	00878713          	addi	a4,a5,8
    1690:	c63a                	sw	a4,12(sp)
    1692:	2388                	fld	fa0,0(a5)
    1694:	3d55                	jal	1548 <print_float>
                        break;
    1696:	b795                	j	15fa <bsp_printf+0x2c>

        va_end(ap);
    }
    1698:	40f2                	lw	ra,28(sp)
    169a:	4462                	lw	s0,24(sp)
    169c:	44d2                	lw	s1,20(sp)
    169e:	6121                	addi	sp,sp,64
    16a0:	8082                	ret

000016a2 <main>:
*
* @brief This function capture the character that user asserted on keyboard and 
*        printed on the terminal. 
*
******************************************************************************/
void main() {
    16a2:	1141                	addi	sp,sp,-16
    16a4:	c606                	sw	ra,12(sp)
    uint8_t dat;

    bsp_init();
    16a6:	33a9                	jal	13f0 <bsp_init>
    
    bsp_printf("***Starting Uart Echo Demo*** \r\n");
    16a8:	6509                	lui	a0,0x2
    16aa:	34050513          	addi	a0,a0,832 # 2340 <_data+0x2c>
    16ae:	3705                	jal	15ce <bsp_printf>
    bsp_printf("Start typing on terminal to send character... \r\n");
    16b0:	6509                	lui	a0,0x2
    16b2:	36450513          	addi	a0,a0,868 # 2364 <_data+0x50>
    16b6:	3f21                	jal	15ce <bsp_printf>
    16b8:	a809                	j	16ca <main+0x28>
    while(1)
    {
        while(uart_readOccupancy(BSP_UART_TERMINAL)){
            dat=uart_read(BSP_UART_TERMINAL);
    16ba:	e8010537          	lui	a0,0xe8010
    16be:	3675                	jal	126a <uart_read>
            bsp_printf("Echo character: %c \r\n", dat);
    16c0:	85aa                	mv	a1,a0
    16c2:	6509                	lui	a0,0x2
    16c4:	39850513          	addi	a0,a0,920 # 2398 <_data+0x84>
    16c8:	3719                	jal	15ce <bsp_printf>
        while(uart_readOccupancy(BSP_UART_TERMINAL)){
    16ca:	e8010537          	lui	a0,0xe8010
    16ce:	3ea5                	jal	1246 <uart_readOccupancy>
    16d0:	dd6d                	beqz	a0,16ca <main+0x28>
    16d2:	b7e5                	j	16ba <main+0x18>

000016d4 <pow>:
    16d4:	7179                	addi	sp,sp,-48
    16d6:	ac22                	fsd	fs0,24(sp)
    16d8:	a826                	fsd	fs1,16(sp)
    16da:	a44a                	fsd	fs2,8(sp)
    16dc:	d606                	sw	ra,44(sp)
    16de:	a04e                	fsd	fs3,0(sp)
    16e0:	22a504d3          	fmv.d	fs1,fa0
    16e4:	22b58453          	fmv.d	fs0,fa1
    16e8:	2a21                	jal	1800 <__ieee754_pow>
    16ea:	81018793          	addi	a5,gp,-2032 # 2920 <__fdlib_version>
    16ee:	4398                	lw	a4,0(a5)
    16f0:	57fd                	li	a5,-1
    16f2:	22a50953          	fmv.d	fs2,fa0
    16f6:	02f70863          	beq	a4,a5,1726 <pow+0x52>
    16fa:	a28427d3          	feq.d	a5,fs0,fs0
    16fe:	c785                	beqz	a5,1726 <pow+0x52>
    1700:	a294a7d3          	feq.d	a5,fs1,fs1
    1704:	c7a5                	beqz	a5,176c <pow+0x98>
    1706:	d20009d3          	fcvt.d.w	fs3,zero
    170a:	a334a7d3          	feq.d	a5,fs1,fs3
    170e:	c78d                	beqz	a5,1738 <pow+0x64>
    1710:	a33427d3          	feq.d	a5,fs0,fs3
    1714:	e3ad                	bnez	a5,1776 <pow+0xa2>
    1716:	22840553          	fmv.d	fa0,fs0
    171a:	187000ef          	jal	ra,20a0 <finite>
    171e:	c501                	beqz	a0,1726 <pow+0x52>
    1720:	a33417d3          	flt.d	a5,fs0,fs3
    1724:	e3c5                	bnez	a5,17c4 <pow+0xf0>
    1726:	50b2                	lw	ra,44(sp)
    1728:	23290553          	fmv.d	fa0,fs2
    172c:	2462                	fld	fs0,24(sp)
    172e:	24c2                	fld	fs1,16(sp)
    1730:	2922                	fld	fs2,8(sp)
    1732:	2982                	fld	fs3,0(sp)
    1734:	6145                	addi	sp,sp,48
    1736:	8082                	ret
    1738:	169000ef          	jal	ra,20a0 <finite>
    173c:	c931                	beqz	a0,1790 <pow+0xbc>
    173e:	d20007d3          	fcvt.d.w	fa5,zero
    1742:	a2f927d3          	feq.d	a5,fs2,fa5
    1746:	d3e5                	beqz	a5,1726 <pow+0x52>
    1748:	22948553          	fmv.d	fa0,fs1
    174c:	155000ef          	jal	ra,20a0 <finite>
    1750:	d979                	beqz	a0,1726 <pow+0x52>
    1752:	22840553          	fmv.d	fa0,fs0
    1756:	14b000ef          	jal	ra,20a0 <finite>
    175a:	d571                	beqz	a0,1726 <pow+0x52>
    175c:	3ad000ef          	jal	ra,2308 <__errno>
    1760:	02200793          	li	a5,34
    1764:	c11c                	sw	a5,0(a0)
    1766:	d2000953          	fcvt.d.w	fs2,zero
    176a:	bf75                	j	1726 <pow+0x52>
    176c:	d20007d3          	fcvt.d.w	fa5,zero
    1770:	a2f427d3          	feq.d	a5,fs0,fa5
    1774:	dbcd                	beqz	a5,1726 <pow+0x52>
    1776:	50b2                	lw	ra,44(sp)
    1778:	00001797          	auipc	a5,0x1
    177c:	c387b907          	fld	fs2,-968(a5) # 23b0 <_data+0x9c>
    1780:	23290553          	fmv.d	fa0,fs2
    1784:	2462                	fld	fs0,24(sp)
    1786:	24c2                	fld	fs1,16(sp)
    1788:	2922                	fld	fs2,8(sp)
    178a:	2982                	fld	fs3,0(sp)
    178c:	6145                	addi	sp,sp,48
    178e:	8082                	ret
    1790:	22948553          	fmv.d	fa0,fs1
    1794:	10d000ef          	jal	ra,20a0 <finite>
    1798:	d15d                	beqz	a0,173e <pow+0x6a>
    179a:	22840553          	fmv.d	fa0,fs0
    179e:	103000ef          	jal	ra,20a0 <finite>
    17a2:	dd51                	beqz	a0,173e <pow+0x6a>
    17a4:	a32927d3          	feq.d	a5,fs2,fs2
    17a8:	c7a1                	beqz	a5,17f0 <pow+0x11c>
    17aa:	35f000ef          	jal	ra,2308 <__errno>
    17ae:	a33497d3          	flt.d	a5,fs1,fs3
    17b2:	02200713          	li	a4,34
    17b6:	c118                	sw	a4,0(a0)
    17b8:	e385                	bnez	a5,17d8 <pow+0x104>
    17ba:	00001797          	auipc	a5,0x1
    17be:	c067b907          	fld	fs2,-1018(a5) # 23c0 <_data+0xac>
    17c2:	b795                	j	1726 <pow+0x52>
    17c4:	345000ef          	jal	ra,2308 <__errno>
    17c8:	02100793          	li	a5,33
    17cc:	c11c                	sw	a5,0(a0)
    17ce:	00001797          	auipc	a5,0x1
    17d2:	bea7b907          	fld	fs2,-1046(a5) # 23b8 <_data+0xa4>
    17d6:	bf81                	j	1726 <pow+0x52>
    17d8:	22840553          	fmv.d	fa0,fs0
    17dc:	0e5000ef          	jal	ra,20c0 <rint>
    17e0:	a28527d3          	feq.d	a5,fa0,fs0
    17e4:	fbf9                	bnez	a5,17ba <pow+0xe6>
    17e6:	00001797          	auipc	a5,0x1
    17ea:	bd27b907          	fld	fs2,-1070(a5) # 23b8 <_data+0xa4>
    17ee:	bf25                	j	1726 <pow+0x52>
    17f0:	319000ef          	jal	ra,2308 <__errno>
    17f4:	02100793          	li	a5,33
    17f8:	c11c                	sw	a5,0(a0)
    17fa:	1b39f953          	fdiv.d	fs2,fs3,fs3
    17fe:	b725                	j	1726 <pow+0x52>

00001800 <__ieee754_pow>:
    1800:	7159                	addi	sp,sp,-112
    1802:	a42e                	fsd	fa1,8(sp)
    1804:	47b2                	lw	a5,12(sp)
    1806:	4722                	lw	a4,8(sp)
    1808:	800006b7          	lui	a3,0x80000
    180c:	fff6c693          	not	a3,a3
    1810:	d2a6                	sw	s1,100(sp)
    1812:	00f6f4b3          	and	s1,a3,a5
    1816:	a42a                	fsd	fa0,8(sp)
    1818:	d686                	sw	ra,108(sp)
    181a:	d4a2                	sw	s0,104(sp)
    181c:	d0ca                	sw	s2,96(sp)
    181e:	cece                	sw	s3,92(sp)
    1820:	ccd2                	sw	s4,88(sp)
    1822:	cad6                	sw	s5,84(sp)
    1824:	a4a2                	fsd	fs0,72(sp)
    1826:	00e4e633          	or	a2,s1,a4
    182a:	4522                	lw	a0,8(sp)
    182c:	45b2                	lw	a1,12(sp)
    182e:	c241                	beqz	a2,18ae <__ieee754_pow+0xae>
    1830:	00b6f433          	and	s0,a3,a1
    1834:	7ff006b7          	lui	a3,0x7ff00
    1838:	8a2e                	mv	s4,a1
    183a:	89aa                	mv	s3,a0
    183c:	0686c463          	blt	a3,s0,18a4 <__ieee754_pow+0xa4>
    1840:	893e                	mv	s2,a5
    1842:	883a                	mv	a6,a4
    1844:	08d40563          	beq	s0,a3,18ce <__ieee754_pow+0xce>
    1848:	0496ce63          	blt	a3,s1,18a4 <__ieee754_pow+0xa4>
    184c:	7ff006b7          	lui	a3,0x7ff00
    1850:	04d48863          	beq	s1,a3,18a0 <__ieee754_pow+0xa0>
    1854:	c82a                	sw	a0,16(sp)
    1856:	ca2e                	sw	a1,20(sp)
    1858:	cc3a                	sw	a4,24(sp)
    185a:	ce3e                	sw	a5,28(sp)
    185c:	4a81                	li	s5,0
    185e:	080a4963          	bltz	s4,18f0 <__ieee754_pow+0xf0>
    1862:	0c081763          	bnez	a6,1930 <__ieee754_pow+0x130>
    1866:	7ff007b7          	lui	a5,0x7ff00
    186a:	14f48363          	beq	s1,a5,19b0 <__ieee754_pow+0x1b0>
    186e:	3ff007b7          	lui	a5,0x3ff00
    1872:	16f48163          	beq	s1,a5,19d4 <__ieee754_pow+0x1d4>
    1876:	400007b7          	lui	a5,0x40000
    187a:	5cf90c63          	beq	s2,a5,1e52 <__ieee754_pow+0x652>
    187e:	3fe007b7          	lui	a5,0x3fe00
    1882:	0af91763          	bne	s2,a5,1930 <__ieee754_pow+0x130>
    1886:	0a0a4563          	bltz	s4,1930 <__ieee754_pow+0x130>
    188a:	5426                	lw	s0,104(sp)
    188c:	2542                	fld	fa0,16(sp)
    188e:	50b6                	lw	ra,108(sp)
    1890:	5496                	lw	s1,100(sp)
    1892:	5906                	lw	s2,96(sp)
    1894:	49f6                	lw	s3,92(sp)
    1896:	4a66                	lw	s4,88(sp)
    1898:	4ad6                	lw	s5,84(sp)
    189a:	2426                	fld	fs0,72(sp)
    189c:	6165                	addi	sp,sp,112
    189e:	a581                	j	1ede <__ieee754_sqrt>
    18a0:	fa080ae3          	beqz	a6,1854 <__ieee754_pow+0x54>
    18a4:	c01006b7          	lui	a3,0xc0100
    18a8:	96a2                	add	a3,a3,s0
    18aa:	8d55                	or	a0,a0,a3
    18ac:	e505                	bnez	a0,18d4 <__ieee754_pow+0xd4>
    18ae:	00001797          	auipc	a5,0x1
    18b2:	b027b787          	fld	fa5,-1278(a5) # 23b0 <_data+0x9c>
    18b6:	a43e                	fsd	fa5,8(sp)
    18b8:	50b6                	lw	ra,108(sp)
    18ba:	5426                	lw	s0,104(sp)
    18bc:	2522                	fld	fa0,8(sp)
    18be:	5496                	lw	s1,100(sp)
    18c0:	5906                	lw	s2,96(sp)
    18c2:	49f6                	lw	s3,92(sp)
    18c4:	4a66                	lw	s4,88(sp)
    18c6:	4ad6                	lw	s5,84(sp)
    18c8:	2426                	fld	fs0,72(sp)
    18ca:	6165                	addi	sp,sp,112
    18cc:	8082                	ret
    18ce:	e119                	bnez	a0,18d4 <__ieee754_pow+0xd4>
    18d0:	f6945ee3          	bge	s0,s1,184c <__ieee754_pow+0x4c>
    18d4:	5426                	lw	s0,104(sp)
    18d6:	50b6                	lw	ra,108(sp)
    18d8:	5496                	lw	s1,100(sp)
    18da:	5906                	lw	s2,96(sp)
    18dc:	49f6                	lw	s3,92(sp)
    18de:	4a66                	lw	s4,88(sp)
    18e0:	4ad6                	lw	s5,84(sp)
    18e2:	2426                	fld	fs0,72(sp)
    18e4:	00001517          	auipc	a0,0x1
    18e8:	a7c50513          	addi	a0,a0,-1412 # 2360 <_data+0x4c>
    18ec:	6165                	addi	sp,sp,112
    18ee:	a7e1                	j	20b6 <nan>
    18f0:	434007b7          	lui	a5,0x43400
    18f4:	10f4d963          	bge	s1,a5,1a06 <__ieee754_pow+0x206>
    18f8:	3ff007b7          	lui	a5,0x3ff00
    18fc:	02f4c863          	blt	s1,a5,192c <__ieee754_pow+0x12c>
    1900:	4144d793          	srai	a5,s1,0x14
    1904:	c0178793          	addi	a5,a5,-1023 # 3feffc01 <__freertos_irq_stack_top+0x3fefc2b1>
    1908:	4751                	li	a4,20
    190a:	54f75963          	bge	a4,a5,1e5c <__ieee754_pow+0x65c>
    190e:	03400713          	li	a4,52
    1912:	40f707b3          	sub	a5,a4,a5
    1916:	4762                	lw	a4,24(sp)
    1918:	00f75733          	srl	a4,a4,a5
    191c:	00f717b3          	sll	a5,a4,a5
    1920:	01079663          	bne	a5,a6,192c <__ieee754_pow+0x12c>
    1924:	8b05                	andi	a4,a4,1
    1926:	4a89                	li	s5,2
    1928:	40ea8ab3          	sub	s5,s5,a4
    192c:	f40801e3          	beqz	a6,186e <__ieee754_pow+0x6e>
    1930:	2542                	fld	fa0,16(sp)
    1932:	2fb1                	jal	208e <fabs>
    1934:	a42a                	fsd	fa0,8(sp)
    1936:	04098363          	beqz	s3,197c <__ieee754_pow+0x17c>
    193a:	47d2                	lw	a5,20(sp)
    193c:	83fd                	srli	a5,a5,0x1f
    193e:	17fd                	addi	a5,a5,-1
    1940:	00fae733          	or	a4,s5,a5
    1944:	c379                	beqz	a4,1a0a <__ieee754_pow+0x20a>
    1946:	41e00737          	lui	a4,0x41e00
    194a:	0c975763          	bge	a4,s1,1a18 <__ieee754_pow+0x218>
    194e:	43f00737          	lui	a4,0x43f00
    1952:	46975f63          	bge	a4,s1,1dd0 <__ieee754_pow+0x5d0>
    1956:	3ff007b7          	lui	a5,0x3ff00
    195a:	08f45a63          	bge	s0,a5,19ee <__ieee754_pow+0x1ee>
    195e:	06095863          	bgez	s2,19ce <__ieee754_pow+0x1ce>
    1962:	00001797          	auipc	a5,0x1
    1966:	a867b787          	fld	fa5,-1402(a5) # 23e8 <_data+0xd4>
    196a:	12f7f7d3          	fmul.d	fa5,fa5,fa5
    196e:	a43e                	fsd	fa5,8(sp)
    1970:	b7a1                	j	18b8 <__ieee754_pow+0xb8>
    1972:	2542                	fld	fa0,16(sp)
    1974:	2f29                	jal	208e <fabs>
    1976:	a42a                	fsd	fa0,8(sp)
    1978:	08099963          	bnez	s3,1a0a <__ieee754_pow+0x20a>
    197c:	c801                	beqz	s0,198c <__ieee754_pow+0x18c>
    197e:	47d2                	lw	a5,20(sp)
    1980:	3ff00737          	lui	a4,0x3ff00
    1984:	078a                	slli	a5,a5,0x2
    1986:	8389                	srli	a5,a5,0x2
    1988:	fae799e3          	bne	a5,a4,193a <__ieee754_pow+0x13a>
    198c:	06094463          	bltz	s2,19f4 <__ieee754_pow+0x1f4>
    1990:	f20a54e3          	bgez	s4,18b8 <__ieee754_pow+0xb8>
    1994:	c01007b7          	lui	a5,0xc0100
    1998:	97a2                	add	a5,a5,s0
    199a:	0157e7b3          	or	a5,a5,s5
    199e:	50079163          	bnez	a5,1ea0 <__ieee754_pow+0x6a0>
    19a2:	27a2                	fld	fa5,8(sp)
    19a4:	0af7f7d3          	fsub.d	fa5,fa5,fa5
    19a8:	1af7f7d3          	fdiv.d	fa5,fa5,fa5
    19ac:	a43e                	fsd	fa5,8(sp)
    19ae:	b729                	j	18b8 <__ieee754_pow+0xb8>
    19b0:	4742                	lw	a4,16(sp)
    19b2:	c01007b7          	lui	a5,0xc0100
    19b6:	97a2                	add	a5,a5,s0
    19b8:	8fd9                	or	a5,a5,a4
    19ba:	ee078ae3          	beqz	a5,18ae <__ieee754_pow+0xae>
    19be:	3ff007b7          	lui	a5,0x3ff00
    19c2:	3ef44463          	blt	s0,a5,1daa <__ieee754_pow+0x5aa>
    19c6:	27e2                	fld	fa5,24(sp)
    19c8:	a43e                	fsd	fa5,8(sp)
    19ca:	ee0957e3          	bgez	s2,18b8 <__ieee754_pow+0xb8>
    19ce:	c402                	sw	zero,8(sp)
    19d0:	c602                	sw	zero,12(sp)
    19d2:	b5dd                	j	18b8 <__ieee754_pow+0xb8>
    19d4:	27c2                	fld	fa5,16(sp)
    19d6:	a43e                	fsd	fa5,8(sp)
    19d8:	ee0950e3          	bgez	s2,18b8 <__ieee754_pow+0xb8>
    19dc:	2722                	fld	fa4,8(sp)
    19de:	00001797          	auipc	a5,0x1
    19e2:	9d27b787          	fld	fa5,-1582(a5) # 23b0 <_data+0x9c>
    19e6:	1ae7f7d3          	fdiv.d	fa5,fa5,fa4
    19ea:	a43e                	fsd	fa5,8(sp)
    19ec:	b5f1                	j	18b8 <__ieee754_pow+0xb8>
    19ee:	f7204ae3          	bgtz	s2,1962 <__ieee754_pow+0x162>
    19f2:	bff1                	j	19ce <__ieee754_pow+0x1ce>
    19f4:	2722                	fld	fa4,8(sp)
    19f6:	00001797          	auipc	a5,0x1
    19fa:	9ba7b787          	fld	fa5,-1606(a5) # 23b0 <_data+0x9c>
    19fe:	1ae7f7d3          	fdiv.d	fa5,fa5,fa4
    1a02:	a43e                	fsd	fa5,8(sp)
    1a04:	b771                	j	1990 <__ieee754_pow+0x190>
    1a06:	4a89                	li	s5,2
    1a08:	bda9                	j	1862 <__ieee754_pow+0x62>
    1a0a:	27c2                	fld	fa5,16(sp)
    1a0c:	0af7f7d3          	fsub.d	fa5,fa5,fa5
    1a10:	1af7f7d3          	fdiv.d	fa5,fa5,fa5
    1a14:	a43e                	fsd	fa5,8(sp)
    1a16:	b54d                	j	18b8 <__ieee754_pow+0xb8>
    1a18:	46d2                	lw	a3,20(sp)
    1a1a:	7ff00737          	lui	a4,0x7ff00
    1a1e:	4501                	li	a0,0
    1a20:	8f75                	and	a4,a4,a3
    1a22:	ef01                	bnez	a4,1a3a <__ieee754_pow+0x23a>
    1a24:	2722                	fld	fa4,8(sp)
    1a26:	00001717          	auipc	a4,0x1
    1a2a:	9fa73787          	fld	fa5,-1542(a4) # 2420 <_data+0x10c>
    1a2e:	fcb00513          	li	a0,-53
    1a32:	12f777d3          	fmul.d	fa5,fa4,fa5
    1a36:	a43e                	fsd	fa5,8(sp)
    1a38:	4432                	lw	s0,12(sp)
    1a3a:	00100837          	lui	a6,0x100
    1a3e:	41445593          	srai	a1,s0,0x14
    1a42:	fff80693          	addi	a3,a6,-1 # fffff <__freertos_irq_stack_top+0xfc6af>
    1a46:	0003a637          	lui	a2,0x3a
    1a4a:	c0158593          	addi	a1,a1,-1023
    1a4e:	8ee1                	and	a3,a3,s0
    1a50:	3ff00737          	lui	a4,0x3ff00
    1a54:	88e60613          	addi	a2,a2,-1906 # 3988e <__freertos_irq_stack_top+0x35f3e>
    1a58:	95aa                	add	a1,a1,a0
    1a5a:	8f55                	or	a4,a4,a3
    1a5c:	34d65e63          	bge	a2,a3,1db8 <__ieee754_pow+0x5b8>
    1a60:	000bb637          	lui	a2,0xbb
    1a64:	67960613          	addi	a2,a2,1657 # bb679 <__freertos_irq_stack_top+0xb7d29>
    1a68:	44d65463          	bge	a2,a3,1eb0 <__ieee754_pow+0x6b0>
    1a6c:	d20001d3          	fcvt.d.w	ft3,zero
    1a70:	00001697          	auipc	a3,0x1
    1a74:	9406b607          	fld	fa2,-1728(a3) # 23b0 <_data+0x9c>
    1a78:	22c607d3          	fmv.d	fa5,fa2
    1a7c:	223182d3          	fmv.d	ft5,ft3
    1a80:	0585                	addi	a1,a1,1
    1a82:	41070733          	sub	a4,a4,a6
    1a86:	4501                	li	a0,0
    1a88:	46a2                	lw	a3,8(sp)
    1a8a:	ca3a                	sw	a4,20(sp)
    1a8c:	8705                	srai	a4,a4,0x1
    1a8e:	c836                	sw	a3,16(sp)
    1a90:	2742                	fld	fa4,16(sp)
    1a92:	200006b7          	lui	a3,0x20000
    1a96:	8f55                	or	a4,a4,a3
    1a98:	02e7f153          	fadd.d	ft2,fa5,fa4
    1a9c:	0af770d3          	fsub.d	ft1,fa4,fa5
    1aa0:	000806b7          	lui	a3,0x80
    1aa4:	9736                	add	a4,a4,a3
    1aa6:	00a706b3          	add	a3,a4,a0
    1aaa:	4601                	li	a2,0
    1aac:	c432                	sw	a2,8(sp)
    1aae:	1a267153          	fdiv.d	ft2,fa2,ft2
    1ab2:	c636                	sw	a3,12(sp)
    1ab4:	26a2                	fld	fa3,8(sp)
    1ab6:	00001717          	auipc	a4,0x1
    1aba:	97a73587          	fld	fa1,-1670(a4) # 2430 <_data+0x11c>
    1abe:	00001717          	auipc	a4,0x1
    1ac2:	99a73007          	fld	ft0,-1638(a4) # 2458 <_data+0x144>
    1ac6:	0af6f7d3          	fsub.d	fa5,fa3,fa5
    1aca:	26c2                	fld	fa3,16(sp)
    1acc:	00001717          	auipc	a4,0x1
    1ad0:	9a473207          	fld	ft4,-1628(a4) # 2470 <_data+0x15c>
    1ad4:	00001717          	auipc	a4,0x1
    1ad8:	95473707          	fld	fa4,-1708(a4) # 2428 <_data+0x114>
    1adc:	00001717          	auipc	a4,0x1
    1ae0:	95c73f87          	fld	ft11,-1700(a4) # 2438 <_data+0x124>
    1ae4:	00001717          	auipc	a4,0x1
    1ae8:	95c73f07          	fld	ft10,-1700(a4) # 2440 <_data+0x12c>
    1aec:	00001717          	auipc	a4,0x1
    1af0:	95c73e87          	fld	ft9,-1700(a4) # 2448 <_data+0x134>
    1af4:	00001717          	auipc	a4,0x1
    1af8:	95c73e07          	fld	ft8,-1700(a4) # 2450 <_data+0x13c>
    1afc:	00001717          	auipc	a4,0x1
    1b00:	96473807          	fld	fa6,-1692(a4) # 2460 <_data+0x14c>
    1b04:	0af6f7d3          	fsub.d	fa5,fa3,fa5
    1b08:	00001717          	auipc	a4,0x1
    1b0c:	96073687          	fld	fa3,-1696(a4) # 2468 <_data+0x154>
    1b10:	c402                	sw	zero,8(sp)
    1b12:	c802                	sw	zero,16(sp)
    1b14:	d002                	sw	zero,32(sp)
    1b16:	d402                	sw	zero,40(sp)
    1b18:	1220f553          	fmul.d	fa0,ft1,ft2
    1b1c:	dc32                	sw	a2,56(sp)
    1b1e:	d2058353          	fcvt.d.w	ft6,a1
    1b22:	b82a                	fsd	fa0,48(sp)
    1b24:	12a57553          	fmul.d	fa0,fa0,fa0
    1b28:	5752                	lw	a4,52(sp)
    1b2a:	c63a                	sw	a4,12(sp)
    1b2c:	2422                	fld	fs0,8(sp)
    1b2e:	de36                	sw	a3,60(sp)
    1b30:	5ae57743          	fmadd.d	fa4,fa0,fa4,fa1
    1b34:	33e2                	fld	ft7,56(sp)
    1b36:	12a575d3          	fmul.d	fa1,fa0,fa0
    1b3a:	0a7470cb          	fnmsub.d	ft1,fs0,ft7,ft1
    1b3e:	3442                	fld	fs0,48(sp)
    1b40:	23a2                	fld	ft7,8(sp)
    1b42:	faa77743          	fmadd.d	fa4,fa4,fa0,ft11
    1b46:	027473d3          	fadd.d	ft7,fs0,ft7
    1b4a:	2422                	fld	fs0,8(sp)
    1b4c:	0af477cb          	fnmsub.d	fa5,fs0,fa5,ft1
    1b50:	f2a77743          	fmadd.d	fa4,fa4,fa0,ft10
    1b54:	028478c3          	fmadd.d	fa7,fs0,fs0,ft0
    1b58:	1227f7d3          	fmul.d	fa5,fa5,ft2
    1b5c:	eaa77743          	fmadd.d	fa4,fa4,fa0,ft9
    1b60:	12f3f0d3          	fmul.d	ft1,ft7,fa5
    1b64:	e2a77743          	fmadd.d	fa4,fa4,fa0,ft8
    1b68:	0ae5f743          	fmadd.d	fa4,fa1,fa4,ft1
    1b6c:	02e8f5d3          	fadd.d	fa1,fa7,fa4
    1b70:	bc2e                	fsd	fa1,56(sp)
    1b72:	5772                	lw	a4,60(sp)
    1b74:	ca3a                	sw	a4,20(sp)
    1b76:	25c2                	fld	fa1,16(sp)
    1b78:	0a05f5d3          	fsub.d	fa1,fa1,ft0
    1b7c:	5a8475cb          	fnmsub.d	fa1,fs0,fs0,fa1
    1b80:	0ab77753          	fsub.d	fa4,fa4,fa1
    1b84:	35c2                	fld	fa1,48(sp)
    1b86:	12b77753          	fmul.d	fa4,fa4,fa1
    1b8a:	25c2                	fld	fa1,16(sp)
    1b8c:	72b7f7c3          	fmadd.d	fa5,fa5,fa1,fa4
    1b90:	22b58753          	fmv.d	fa4,fa1
    1b94:	25c2                	fld	fa1,16(sp)
    1b96:	7a877743          	fmadd.d	fa4,fa4,fs0,fa5
    1b9a:	b83a                	fsd	fa4,48(sp)
    1b9c:	5752                	lw	a4,52(sp)
    1b9e:	d23a                	sw	a4,36(sp)
    1ba0:	3502                	fld	fa0,32(sp)
    1ba2:	52b4774b          	fnmsub.d	fa4,fs0,fa1,fa0
    1ba6:	0ae7f7d3          	fsub.d	fa5,fa5,fa4
    1baa:	1307f7d3          	fmul.d	fa5,fa5,fa6
    1bae:	7aa6f7c3          	fmadd.d	fa5,fa3,fa0,fa5
    1bb2:	0257f753          	fadd.d	fa4,fa5,ft5
    1bb6:	72a277c3          	fmadd.d	fa5,ft4,fa0,fa4
    1bba:	0237f7d3          	fadd.d	fa5,fa5,ft3
    1bbe:	0267f7d3          	fadd.d	fa5,fa5,ft6
    1bc2:	a43e                	fsd	fa5,8(sp)
    1bc4:	4732                	lw	a4,12(sp)
    1bc6:	d63a                	sw	a4,44(sp)
    1bc8:	37a2                	fld	fa5,40(sp)
    1bca:	35a2                	fld	fa1,40(sp)
    1bcc:	0a67f7d3          	fsub.d	fa5,fa5,ft6
    1bd0:	0a37f7d3          	fsub.d	fa5,fa5,ft3
    1bd4:	7a4577cb          	fnmsub.d	fa5,fa0,ft4,fa5
    1bd8:	0af77753          	fsub.d	fa4,fa4,fa5
    1bdc:	1afd                	addi	s5,s5,-1
    1bde:	00fae7b3          	or	a5,s5,a5
    1be2:	22c60453          	fmv.d	fs0,fa2
    1be6:	e789                	bnez	a5,1bf0 <__ieee754_pow+0x3f0>
    1be8:	00000797          	auipc	a5,0x0
    1bec:	7f87b407          	fld	fs0,2040(a5) # 23e0 <_data+0xcc>
    1bf0:	47f2                	lw	a5,28(sp)
    1bf2:	c402                	sw	zero,8(sp)
    1bf4:	27e2                	fld	fa5,24(sp)
    1bf6:	c63e                	sw	a5,12(sp)
    1bf8:	26a2                	fld	fa3,8(sp)
    1bfa:	409006b7          	lui	a3,0x40900
    1bfe:	0ad7f7d3          	fsub.d	fa5,fa5,fa3
    1c02:	26e2                	fld	fa3,24(sp)
    1c04:	12d77753          	fmul.d	fa4,fa4,fa3
    1c08:	26a2                	fld	fa3,8(sp)
    1c0a:	12d5f6d3          	fmul.d	fa3,fa1,fa3
    1c0e:	72b7f7c3          	fmadd.d	fa5,fa5,fa1,fa4
    1c12:	02d7f753          	fadd.d	fa4,fa5,fa3
    1c16:	a43a                	fsd	fa4,8(sp)
    1c18:	47b2                	lw	a5,12(sp)
    1c1a:	4722                	lw	a4,8(sp)
    1c1c:	883e                	mv	a6,a5
    1c1e:	14d7c363          	blt	a5,a3,1d64 <__ieee754_pow+0x564>
    1c22:	40d786b3          	sub	a3,a5,a3
    1c26:	8ed9                	or	a3,a3,a4
    1c28:	26069263          	bnez	a3,1e8c <__ieee754_pow+0x68c>
    1c2c:	c63e                	sw	a5,12(sp)
    1c2e:	c43a                	sw	a4,8(sp)
    1c30:	25a2                	fld	fa1,8(sp)
    1c32:	00001697          	auipc	a3,0x1
    1c36:	8466b707          	fld	fa4,-1978(a3) # 2478 <_data+0x164>
    1c3a:	02e7f753          	fadd.d	fa4,fa5,fa4
    1c3e:	0ad5f5d3          	fsub.d	fa1,fa1,fa3
    1c42:	a2e597d3          	flt.d	a5,fa1,fa4
    1c46:	24079363          	bnez	a5,1e8c <__ieee754_pow+0x68c>
    1c4a:	41485793          	srai	a5,a6,0x14
    1c4e:	7ff7f793          	andi	a5,a5,2047
    1c52:	00100637          	lui	a2,0x100
    1c56:	c0278793          	addi	a5,a5,-1022
    1c5a:	40f657b3          	sra	a5,a2,a5
    1c5e:	97c2                	add	a5,a5,a6
    1c60:	4147d713          	srai	a4,a5,0x14
    1c64:	7ff77713          	andi	a4,a4,2047
    1c68:	c0170713          	addi	a4,a4,-1023
    1c6c:	fff60513          	addi	a0,a2,-1 # fffff <__freertos_irq_stack_top+0xfc6af>
    1c70:	40e556b3          	sra	a3,a0,a4
    1c74:	fff6c693          	not	a3,a3
    1c78:	8efd                	and	a3,a3,a5
    1c7a:	8d7d                	and	a0,a0,a5
    1c7c:	47d1                	li	a5,20
    1c7e:	c402                	sw	zero,8(sp)
    1c80:	c636                	sw	a3,12(sp)
    1c82:	8d51                	or	a0,a0,a2
    1c84:	40e78733          	sub	a4,a5,a4
    1c88:	2722                	fld	fa4,8(sp)
    1c8a:	40e55533          	sra	a0,a0,a4
    1c8e:	00085463          	bgez	a6,1c96 <__ieee754_pow+0x496>
    1c92:	40a00533          	neg	a0,a0
    1c96:	0ae6f6d3          	fsub.d	fa3,fa3,fa4
    1c9a:	01451693          	slli	a3,a0,0x14
    1c9e:	02d7f753          	fadd.d	fa4,fa5,fa3
    1ca2:	a43a                	fsd	fa4,8(sp)
    1ca4:	47b2                	lw	a5,12(sp)
    1ca6:	c63e                	sw	a5,12(sp)
    1ca8:	c402                	sw	zero,8(sp)
    1caa:	2722                	fld	fa4,8(sp)
    1cac:	00000797          	auipc	a5,0x0
    1cb0:	7dc7b587          	fld	fa1,2012(a5) # 2488 <_data+0x174>
    1cb4:	00000797          	auipc	a5,0x0
    1cb8:	7dc7b507          	fld	fa0,2012(a5) # 2490 <_data+0x17c>
    1cbc:	0ad776d3          	fsub.d	fa3,fa4,fa3
    1cc0:	12e5f5d3          	fmul.d	fa1,fa1,fa4
    1cc4:	00000797          	auipc	a5,0x0
    1cc8:	7d47b007          	fld	ft0,2004(a5) # 2498 <_data+0x184>
    1ccc:	00000797          	auipc	a5,0x0
    1cd0:	7d47b707          	fld	fa4,2004(a5) # 24a0 <_data+0x18c>
    1cd4:	00000797          	auipc	a5,0x0
    1cd8:	7d47b287          	fld	ft5,2004(a5) # 24a8 <_data+0x194>
    1cdc:	00000797          	auipc	a5,0x0
    1ce0:	7d47b207          	fld	ft4,2004(a5) # 24b0 <_data+0x19c>
    1ce4:	00000797          	auipc	a5,0x0
    1ce8:	7d47b187          	fld	ft3,2004(a5) # 24b8 <_data+0x1a4>
    1cec:	0ad7f7d3          	fsub.d	fa5,fa5,fa3
    1cf0:	26a2                	fld	fa3,8(sp)
    1cf2:	00000797          	auipc	a5,0x0
    1cf6:	7ce7b107          	fld	ft2,1998(a5) # 24c0 <_data+0x1ac>
    1cfa:	00000797          	auipc	a5,0x0
    1cfe:	7ce7b087          	fld	ft1,1998(a5) # 24c8 <_data+0x1b4>
    1d02:	5aa7f7c3          	fmadd.d	fa5,fa5,fa0,fa1
    1d06:	7ad075c3          	fmadd.d	fa1,ft0,fa3,fa5
    1d0a:	12b5f553          	fmul.d	fa0,fa1,fa1
    1d0e:	5a06f6cb          	fnmsub.d	fa3,fa3,ft0,fa1
    1d12:	2ae57743          	fmadd.d	fa4,fa0,fa4,ft5
    1d16:	0ad7f7d3          	fsub.d	fa5,fa5,fa3
    1d1a:	22a77743          	fmadd.d	fa4,fa4,fa0,ft4
    1d1e:	7af5f7c3          	fmadd.d	fa5,fa1,fa5,fa5
    1d22:	1aa77743          	fmadd.d	fa4,fa4,fa0,ft3
    1d26:	12a77743          	fmadd.d	fa4,fa4,fa0,ft2
    1d2a:	5aa7774b          	fnmsub.d	fa4,fa4,fa0,fa1
    1d2e:	12e5f6d3          	fmul.d	fa3,fa1,fa4
    1d32:	0a177753          	fsub.d	fa4,fa4,ft1
    1d36:	1ae6f753          	fdiv.d	fa4,fa3,fa4
    1d3a:	0af777d3          	fsub.d	fa5,fa4,fa5
    1d3e:	0ab7f7d3          	fsub.d	fa5,fa5,fa1
    1d42:	0af677d3          	fsub.d	fa5,fa2,fa5
    1d46:	a43e                	fsd	fa5,8(sp)
    1d48:	47b2                	lw	a5,12(sp)
    1d4a:	4722                	lw	a4,8(sp)
    1d4c:	96be                	add	a3,a3,a5
    1d4e:	4146d613          	srai	a2,a3,0x14
    1d52:	18c05263          	blez	a2,1ed6 <__ieee754_pow+0x6d6>
    1d56:	c43a                	sw	a4,8(sp)
    1d58:	c636                	sw	a3,12(sp)
    1d5a:	2522                	fld	fa0,8(sp)
    1d5c:	128577d3          	fmul.d	fa5,fa0,fs0
    1d60:	a43e                	fsd	fa5,8(sp)
    1d62:	be99                	j	18b8 <__ieee754_pow+0xb8>
    1d64:	00179593          	slli	a1,a5,0x1
    1d68:	4090d6b7          	lui	a3,0x4090d
    1d6c:	8185                	srli	a1,a1,0x1
    1d6e:	bff68693          	addi	a3,a3,-1025 # 4090cbff <__freertos_irq_stack_top+0x409092af>
    1d72:	10b6d463          	bge	a3,a1,1e7a <__ieee754_pow+0x67a>
    1d76:	3f6f36b7          	lui	a3,0x3f6f3
    1d7a:	40068693          	addi	a3,a3,1024 # 3f6f3400 <__freertos_irq_stack_top+0x3f6efab0>
    1d7e:	96be                	add	a3,a3,a5
    1d80:	8ed9                	or	a3,a3,a4
    1d82:	ea91                	bnez	a3,1d96 <__ieee754_pow+0x596>
    1d84:	c63e                	sw	a5,12(sp)
    1d86:	c43a                	sw	a4,8(sp)
    1d88:	2722                	fld	fa4,8(sp)
    1d8a:	0ad77753          	fsub.d	fa4,fa4,fa3
    1d8e:	a2e787d3          	fle.d	a5,fa5,fa4
    1d92:	ea078ce3          	beqz	a5,1c4a <__ieee754_pow+0x44a>
    1d96:	00000797          	auipc	a5,0x0
    1d9a:	6ea7b787          	fld	fa5,1770(a5) # 2480 <_data+0x16c>
    1d9e:	12f47453          	fmul.d	fs0,fs0,fa5
    1da2:	12f477d3          	fmul.d	fa5,fs0,fa5
    1da6:	a43e                	fsd	fa5,8(sp)
    1da8:	be01                	j	18b8 <__ieee754_pow+0xb8>
    1daa:	c20952e3          	bgez	s2,19ce <__ieee754_pow+0x1ce>
    1dae:	27e2                	fld	fa5,24(sp)
    1db0:	22f797d3          	fneg.d	fa5,fa5
    1db4:	a43e                	fsd	fa5,8(sp)
    1db6:	b609                	j	18b8 <__ieee754_pow+0xb8>
    1db8:	d20001d3          	fcvt.d.w	ft3,zero
    1dbc:	00000697          	auipc	a3,0x0
    1dc0:	5f46b607          	fld	fa2,1524(a3) # 23b0 <_data+0x9c>
    1dc4:	4501                	li	a0,0
    1dc6:	223182d3          	fmv.d	ft5,ft3
    1dca:	22c607d3          	fmv.d	fa5,fa2
    1dce:	b96d                	j	1a88 <__ieee754_pow+0x288>
    1dd0:	3ff00737          	lui	a4,0x3ff00
    1dd4:	ffe70693          	addi	a3,a4,-2 # 3feffffe <__freertos_irq_stack_top+0x3fefc6ae>
    1dd8:	b886d3e3          	bge	a3,s0,195e <__ieee754_pow+0x15e>
    1ddc:	c08749e3          	blt	a4,s0,19ee <__ieee754_pow+0x1ee>
    1de0:	27a2                	fld	fa5,8(sp)
    1de2:	00000717          	auipc	a4,0x0
    1de6:	5ce73607          	fld	fa2,1486(a4) # 23b0 <_data+0x9c>
    1dea:	00000717          	auipc	a4,0x0
    1dee:	60e73007          	fld	ft0,1550(a4) # 23f8 <_data+0xe4>
    1df2:	0ac7f7d3          	fsub.d	fa5,fa5,fa2
    1df6:	00000717          	auipc	a4,0x0
    1dfa:	5fa73687          	fld	fa3,1530(a4) # 23f0 <_data+0xdc>
    1dfe:	00000717          	auipc	a4,0x0
    1e02:	60273087          	fld	ft1,1538(a4) # 2400 <_data+0xec>
    1e06:	00000717          	auipc	a4,0x0
    1e0a:	60273507          	fld	fa0,1538(a4) # 2408 <_data+0xf4>
    1e0e:	00000717          	auipc	a4,0x0
    1e12:	60273707          	fld	fa4,1538(a4) # 2410 <_data+0xfc>
    1e16:	00000717          	auipc	a4,0x0
    1e1a:	60273587          	fld	fa1,1538(a4) # 2418 <_data+0x104>
    1e1e:	c402                	sw	zero,8(sp)
    1e20:	02d7f6cb          	fnmsub.d	fa3,fa5,fa3,ft0
    1e24:	12f7f053          	fmul.d	ft0,fa5,fa5
    1e28:	0af6f6cb          	fnmsub.d	fa3,fa3,fa5,ft1
    1e2c:	1206f6d3          	fmul.d	fa3,fa3,ft0
    1e30:	12a6f6d3          	fmul.d	fa3,fa3,fa0
    1e34:	6ae7f747          	fmsub.d	fa4,fa5,fa4,fa3
    1e38:	72b7f6c3          	fmadd.d	fa3,fa5,fa1,fa4
    1e3c:	a836                	fsd	fa3,16(sp)
    1e3e:	4752                	lw	a4,20(sp)
    1e40:	c63a                	sw	a4,12(sp)
    1e42:	26a2                	fld	fa3,8(sp)
    1e44:	6ab7f7cb          	fnmsub.d	fa5,fa5,fa1,fa3
    1e48:	22d685d3          	fmv.d	fa1,fa3
    1e4c:	0af77753          	fsub.d	fa4,fa4,fa5
    1e50:	b371                	j	1bdc <__ieee754_pow+0x3dc>
    1e52:	27c2                	fld	fa5,16(sp)
    1e54:	12f7f7d3          	fmul.d	fa5,fa5,fa5
    1e58:	a43e                	fsd	fa5,8(sp)
    1e5a:	bcb9                	j	18b8 <__ieee754_pow+0xb8>
    1e5c:	b0081be3          	bnez	a6,1972 <__ieee754_pow+0x172>
    1e60:	40f707b3          	sub	a5,a4,a5
    1e64:	40f4d733          	sra	a4,s1,a5
    1e68:	00f717b3          	sll	a5,a4,a5
    1e6c:	a09791e3          	bne	a5,s1,186e <__ieee754_pow+0x6e>
    1e70:	8b05                	andi	a4,a4,1
    1e72:	4a89                	li	s5,2
    1e74:	40ea8ab3          	sub	s5,s5,a4
    1e78:	badd                	j	186e <__ieee754_pow+0x6e>
    1e7a:	3fe00637          	lui	a2,0x3fe00
    1e7e:	4681                	li	a3,0
    1e80:	4501                	li	a0,0
    1e82:	e2b652e3          	bge	a2,a1,1ca6 <__ieee754_pow+0x4a6>
    1e86:	4145d793          	srai	a5,a1,0x14
    1e8a:	b3e1                	j	1c52 <__ieee754_pow+0x452>
    1e8c:	00000797          	auipc	a5,0x0
    1e90:	55c7b787          	fld	fa5,1372(a5) # 23e8 <_data+0xd4>
    1e94:	12f47453          	fmul.d	fs0,fs0,fa5
    1e98:	12f477d3          	fmul.d	fa5,fs0,fa5
    1e9c:	a43e                	fsd	fa5,8(sp)
    1e9e:	bc29                	j	18b8 <__ieee754_pow+0xb8>
    1ea0:	4785                	li	a5,1
    1ea2:	a0fa9be3          	bne	s5,a5,18b8 <__ieee754_pow+0xb8>
    1ea6:	27a2                	fld	fa5,8(sp)
    1ea8:	22f797d3          	fneg.d	fa5,fa5
    1eac:	a43e                	fsd	fa5,8(sp)
    1eae:	b429                	j	18b8 <__ieee754_pow+0xb8>
    1eb0:	00000697          	auipc	a3,0x0
    1eb4:	5186b187          	fld	ft3,1304(a3) # 23c8 <_data+0xb4>
    1eb8:	00000697          	auipc	a3,0x0
    1ebc:	5186b287          	fld	ft5,1304(a3) # 23d0 <_data+0xbc>
    1ec0:	00040537          	lui	a0,0x40
    1ec4:	00000697          	auipc	a3,0x0
    1ec8:	5146b787          	fld	fa5,1300(a3) # 23d8 <_data+0xc4>
    1ecc:	00000697          	auipc	a3,0x0
    1ed0:	4e46b607          	fld	fa2,1252(a3) # 23b0 <_data+0x9c>
    1ed4:	be55                	j	1a88 <__ieee754_pow+0x288>
    1ed6:	22f78553          	fmv.d	fa0,fa5
    1eda:	2e35                	jal	2216 <scalbn>
    1edc:	b541                	j	1d5c <__ieee754_pow+0x55c>

00001ede <__ieee754_sqrt>:
    1ede:	1141                	addi	sp,sp,-16
    1ee0:	a42a                	fsd	fa0,8(sp)
    1ee2:	46b2                	lw	a3,12(sp)
    1ee4:	7ff00737          	lui	a4,0x7ff00
    1ee8:	4622                	lw	a2,8(sp)
    1eea:	00d77833          	and	a6,a4,a3
    1eee:	16e80d63          	beq	a6,a4,2068 <__ieee754_sqrt+0x18a>
    1ef2:	87b6                	mv	a5,a3
    1ef4:	8532                	mv	a0,a2
    1ef6:	0ed05763          	blez	a3,1fe4 <__ieee754_sqrt+0x106>
    1efa:	4146d593          	srai	a1,a3,0x14
    1efe:	16058e63          	beqz	a1,207a <__ieee754_sqrt+0x19c>
    1f02:	00100737          	lui	a4,0x100
    1f06:	fff70693          	addi	a3,a4,-1 # fffff <__freertos_irq_stack_top+0xfc6af>
    1f0a:	8ff5                	and	a5,a5,a3
    1f0c:	8fd9                	or	a5,a5,a4
    1f0e:	c0158693          	addi	a3,a1,-1023
    1f12:	00179713          	slli	a4,a5,0x1
    1f16:	0016f613          	andi	a2,a3,1
    1f1a:	01f55793          	srli	a5,a0,0x1f
    1f1e:	97ba                	add	a5,a5,a4
    1f20:	00151713          	slli	a4,a0,0x1
    1f24:	c611                	beqz	a2,1f30 <__ieee754_sqrt+0x52>
    1f26:	837d                	srli	a4,a4,0x1f
    1f28:	0786                	slli	a5,a5,0x1
    1f2a:	97ba                	add	a5,a5,a4
    1f2c:	00251713          	slli	a4,a0,0x2
    1f30:	4016de93          	srai	t4,a3,0x1
    1f34:	45d9                	li	a1,22
    1f36:	4e01                	li	t3,0
    1f38:	4681                	li	a3,0
    1f3a:	00200637          	lui	a2,0x200
    1f3e:	00c68533          	add	a0,a3,a2
    1f42:	01f75813          	srli	a6,a4,0x1f
    1f46:	15fd                	addi	a1,a1,-1
    1f48:	00a7c663          	blt	a5,a0,1f54 <__ieee754_sqrt+0x76>
    1f4c:	8f89                	sub	a5,a5,a0
    1f4e:	00c506b3          	add	a3,a0,a2
    1f52:	9e32                	add	t3,t3,a2
    1f54:	0786                	slli	a5,a5,0x1
    1f56:	97c2                	add	a5,a5,a6
    1f58:	0706                	slli	a4,a4,0x1
    1f5a:	8205                	srli	a2,a2,0x1
    1f5c:	f1ed                	bnez	a1,1f3e <__ieee754_sqrt+0x60>
    1f5e:	4301                	li	t1,0
    1f60:	02000813          	li	a6,32
    1f64:	80000637          	lui	a2,0x80000
    1f68:	a821                	j	1f80 <__ieee754_sqrt+0xa2>
    1f6a:	0cd78e63          	beq	a5,a3,2046 <__ieee754_sqrt+0x168>
    1f6e:	01f75513          	srli	a0,a4,0x1f
    1f72:	0786                	slli	a5,a5,0x1
    1f74:	187d                	addi	a6,a6,-1
    1f76:	97aa                	add	a5,a5,a0
    1f78:	0706                	slli	a4,a4,0x1
    1f7a:	8205                	srli	a2,a2,0x1
    1f7c:	02080b63          	beqz	a6,1fb2 <__ieee754_sqrt+0xd4>
    1f80:	00b60533          	add	a0,a2,a1
    1f84:	fef6d3e3          	bge	a3,a5,1f6a <__ieee754_sqrt+0x8c>
    1f88:	00c505b3          	add	a1,a0,a2
    1f8c:	88b6                	mv	a7,a3
    1f8e:	0a054663          	bltz	a0,203a <__ieee754_sqrt+0x15c>
    1f92:	8f95                	sub	a5,a5,a3
    1f94:	00a736b3          	sltu	a3,a4,a0
    1f98:	8f95                	sub	a5,a5,a3
    1f9a:	8f09                	sub	a4,a4,a0
    1f9c:	01f75513          	srli	a0,a4,0x1f
    1fa0:	0786                	slli	a5,a5,0x1
    1fa2:	187d                	addi	a6,a6,-1
    1fa4:	9332                	add	t1,t1,a2
    1fa6:	86c6                	mv	a3,a7
    1fa8:	97aa                	add	a5,a5,a0
    1faa:	0706                	slli	a4,a4,0x1
    1fac:	8205                	srli	a2,a2,0x1
    1fae:	fc0819e3          	bnez	a6,1f80 <__ieee754_sqrt+0xa2>
    1fb2:	8fd9                	or	a5,a5,a4
    1fb4:	e3d5                	bnez	a5,2058 <__ieee754_sqrt+0x17a>
    1fb6:	00135813          	srli	a6,t1,0x1
    1fba:	401e5793          	srai	a5,t3,0x1
    1fbe:	3fe00737          	lui	a4,0x3fe00
    1fc2:	001e7e13          	andi	t3,t3,1
    1fc6:	973e                	add	a4,a4,a5
    1fc8:	000e0663          	beqz	t3,1fd4 <__ieee754_sqrt+0xf6>
    1fcc:	800007b7          	lui	a5,0x80000
    1fd0:	00f86833          	or	a6,a6,a5
    1fd4:	014e9793          	slli	a5,t4,0x14
    1fd8:	97ba                	add	a5,a5,a4
    1fda:	c442                	sw	a6,8(sp)
    1fdc:	c63e                	sw	a5,12(sp)
    1fde:	2522                	fld	fa0,8(sp)
    1fe0:	0141                	addi	sp,sp,16
    1fe2:	8082                	ret
    1fe4:	00169713          	slli	a4,a3,0x1
    1fe8:	8305                	srli	a4,a4,0x1
    1fea:	c432                	sw	a2,8(sp)
    1fec:	c636                	sw	a3,12(sp)
    1fee:	8f51                	or	a4,a4,a2
    1ff0:	2522                	fld	fa0,8(sp)
    1ff2:	d77d                	beqz	a4,1fe0 <__ieee754_sqrt+0x102>
    1ff4:	eeb5                	bnez	a3,2070 <__ieee754_sqrt+0x192>
    1ff6:	00b55613          	srli	a2,a0,0xb
    1ffa:	17ad                	addi	a5,a5,-21
    1ffc:	8732                	mv	a4,a2
    1ffe:	0556                	slli	a0,a0,0x15
    2000:	da7d                	beqz	a2,1ff6 <__ieee754_sqrt+0x118>
    2002:	01465693          	srli	a3,a2,0x14
    2006:	eebd                	bnez	a3,2084 <__ieee754_sqrt+0x1a6>
    2008:	4681                	li	a3,0
    200a:	a011                	j	200e <__ieee754_sqrt+0x130>
    200c:	86ae                	mv	a3,a1
    200e:	0706                	slli	a4,a4,0x1
    2010:	00b71613          	slli	a2,a4,0xb
    2014:	00168593          	addi	a1,a3,1
    2018:	fe065ae3          	bgez	a2,200c <__ieee754_sqrt+0x12e>
    201c:	02000893          	li	a7,32
    2020:	882a                	mv	a6,a0
    2022:	40b888b3          	sub	a7,a7,a1
    2026:	863a                	mv	a2,a4
    2028:	00b51533          	sll	a0,a0,a1
    202c:	01185733          	srl	a4,a6,a7
    2030:	40d785b3          	sub	a1,a5,a3
    2034:	00c767b3          	or	a5,a4,a2
    2038:	b5e9                	j	1f02 <__ieee754_sqrt+0x24>
    203a:	fff5c893          	not	a7,a1
    203e:	01f8d893          	srli	a7,a7,0x1f
    2042:	98b6                	add	a7,a7,a3
    2044:	b7b9                	j	1f92 <__ieee754_sqrt+0xb4>
    2046:	f2a764e3          	bltu	a4,a0,1f6e <__ieee754_sqrt+0x90>
    204a:	00c505b3          	add	a1,a0,a2
    204e:	fe0546e3          	bltz	a0,203a <__ieee754_sqrt+0x15c>
    2052:	88be                	mv	a7,a5
    2054:	4781                	li	a5,0
    2056:	b791                	j	1f9a <__ieee754_sqrt+0xbc>
    2058:	57fd                	li	a5,-1
    205a:	02f30363          	beq	t1,a5,2080 <__ieee754_sqrt+0x1a2>
    205e:	00130813          	addi	a6,t1,1
    2062:	00185813          	srli	a6,a6,0x1
    2066:	bf91                	j	1fba <__ieee754_sqrt+0xdc>
    2068:	52a57543          	fmadd.d	fa0,fa0,fa0,fa0
    206c:	0141                	addi	sp,sp,16
    206e:	8082                	ret
    2070:	0aa57553          	fsub.d	fa0,fa0,fa0
    2074:	1aa57553          	fdiv.d	fa0,fa0,fa0
    2078:	b7a5                	j	1fe0 <__ieee754_sqrt+0x102>
    207a:	8736                	mv	a4,a3
    207c:	4781                	li	a5,0
    207e:	b769                	j	2008 <__ieee754_sqrt+0x12a>
    2080:	0e05                	addi	t3,t3,1
    2082:	bf25                	j	1fba <__ieee754_sqrt+0xdc>
    2084:	882a                	mv	a6,a0
    2086:	02000893          	li	a7,32
    208a:	56fd                	li	a3,-1
    208c:	b745                	j	202c <__ieee754_sqrt+0x14e>

0000208e <fabs>:
    208e:	1141                	addi	sp,sp,-16
    2090:	a42a                	fsd	fa0,8(sp)
    2092:	4732                	lw	a4,12(sp)
    2094:	0706                	slli	a4,a4,0x1
    2096:	8305                	srli	a4,a4,0x1
    2098:	c63a                	sw	a4,12(sp)
    209a:	2522                	fld	fa0,8(sp)
    209c:	0141                	addi	sp,sp,16
    209e:	8082                	ret

000020a0 <finite>:
    20a0:	1141                	addi	sp,sp,-16
    20a2:	a42a                	fsd	fa0,8(sp)
    20a4:	4532                	lw	a0,12(sp)
    20a6:	801007b7          	lui	a5,0x80100
    20aa:	0506                	slli	a0,a0,0x1
    20ac:	8105                	srli	a0,a0,0x1
    20ae:	953e                	add	a0,a0,a5
    20b0:	817d                	srli	a0,a0,0x1f
    20b2:	0141                	addi	sp,sp,16
    20b4:	8082                	ret

000020b6 <nan>:
    20b6:	00000797          	auipc	a5,0x0
    20ba:	41a7b507          	fld	fa0,1050(a5) # 24d0 <_data+0x1bc>
    20be:	8082                	ret

000020c0 <rint>:
    20c0:	1101                	addi	sp,sp,-32
    20c2:	a42a                	fsd	fa0,8(sp)
    20c4:	4732                	lw	a4,12(sp)
    20c6:	47a2                	lw	a5,8(sp)
    20c8:	464d                	li	a2,19
    20ca:	41475693          	srai	a3,a4,0x14
    20ce:	7ff6f693          	andi	a3,a3,2047
    20d2:	c0168593          	addi	a1,a3,-1023
    20d6:	833a                	mv	t1,a4
    20d8:	883e                	mv	a6,a5
    20da:	01f75893          	srli	a7,a4,0x1f
    20de:	0eb64563          	blt	a2,a1,21c8 <rint+0x108>
    20e2:	0605cd63          	bltz	a1,215c <rint+0x9c>
    20e6:	00100637          	lui	a2,0x100
    20ea:	167d                	addi	a2,a2,-1
    20ec:	40b65633          	sra	a2,a2,a1
    20f0:	00e67533          	and	a0,a2,a4
    20f4:	c43e                	sw	a5,8(sp)
    20f6:	c63a                	sw	a4,12(sp)
    20f8:	8d5d                	or	a0,a0,a5
    20fa:	cd31                	beqz	a0,2156 <rint+0x96>
    20fc:	00165513          	srli	a0,a2,0x1
    2100:	00e57833          	and	a6,a0,a4
    2104:	00f86833          	or	a6,a6,a5
    2108:	02080563          	beqz	a6,2132 <rint+0x72>
    210c:	bee68613          	addi	a2,a3,-1042
    2110:	00040337          	lui	t1,0x40
    2114:	00163613          	seqz	a2,a2
    2118:	fff54513          	not	a0,a0
    211c:	80000837          	lui	a6,0x80000
    2120:	40c00633          	neg	a2,a2
    2124:	8f69                	and	a4,a4,a0
    2126:	40b355b3          	sra	a1,t1,a1
    212a:	00c87833          	and	a6,a6,a2
    212e:	00b76333          	or	t1,a4,a1
    2132:	088e                	slli	a7,a7,0x3
    2134:	00000797          	auipc	a5,0x0
    2138:	3a478793          	addi	a5,a5,932 # 24d8 <TWO52>
    213c:	c442                	sw	a6,8(sp)
    213e:	c61a                	sw	t1,12(sp)
    2140:	98be                	add	a7,a7,a5
    2142:	0008b707          	fld	fa4,0(a7)
    2146:	27a2                	fld	fa5,8(sp)
    2148:	02f777d3          	fadd.d	fa5,fa4,fa5
    214c:	ac3e                	fsd	fa5,24(sp)
    214e:	27e2                	fld	fa5,24(sp)
    2150:	0ae7f7d3          	fsub.d	fa5,fa5,fa4
    2154:	a43e                	fsd	fa5,8(sp)
    2156:	2522                	fld	fa0,8(sp)
    2158:	6105                	addi	sp,sp,32
    215a:	8082                	ret
    215c:	800006b7          	lui	a3,0x80000
    2160:	fff6c693          	not	a3,a3
    2164:	00e6f633          	and	a2,a3,a4
    2168:	8fd1                	or	a5,a5,a2
    216a:	d7f5                	beqz	a5,2156 <rint+0x96>
    216c:	00c71793          	slli	a5,a4,0xc
    2170:	83b1                	srli	a5,a5,0xc
    2172:	0107e733          	or	a4,a5,a6
    2176:	40e007b3          	neg	a5,a4
    217a:	00389613          	slli	a2,a7,0x3
    217e:	8fd9                	or	a5,a5,a4
    2180:	00000717          	auipc	a4,0x0
    2184:	35870713          	addi	a4,a4,856 # 24d8 <TWO52>
    2188:	9732                	add	a4,a4,a2
    218a:	2318                	fld	fa4,0(a4)
    218c:	83b1                	srli	a5,a5,0xc
    218e:	7701                	lui	a4,0xfffe0
    2190:	00080637          	lui	a2,0x80
    2194:	00677733          	and	a4,a4,t1
    2198:	8ff1                	and	a5,a5,a2
    219a:	00e7e5b3          	or	a1,a5,a4
    219e:	c442                	sw	a6,8(sp)
    21a0:	c62e                	sw	a1,12(sp)
    21a2:	27a2                	fld	fa5,8(sp)
    21a4:	08fe                	slli	a7,a7,0x1f
    21a6:	02f777d3          	fadd.d	fa5,fa4,fa5
    21aa:	ac3e                	fsd	fa5,24(sp)
    21ac:	27e2                	fld	fa5,24(sp)
    21ae:	0ae7f7d3          	fsub.d	fa5,fa5,fa4
    21b2:	a43e                	fsd	fa5,8(sp)
    21b4:	47b2                	lw	a5,12(sp)
    21b6:	4722                	lw	a4,8(sp)
    21b8:	8efd                	and	a3,a3,a5
    21ba:	0116e6b3          	or	a3,a3,a7
    21be:	c43a                	sw	a4,8(sp)
    21c0:	c636                	sw	a3,12(sp)
    21c2:	2522                	fld	fa0,8(sp)
    21c4:	6105                	addi	sp,sp,32
    21c6:	8082                	ret
    21c8:	03300613          	li	a2,51
    21cc:	00b65d63          	bge	a2,a1,21e6 <rint+0x126>
    21d0:	c43e                	sw	a5,8(sp)
    21d2:	c63a                	sw	a4,12(sp)
    21d4:	40000793          	li	a5,1024
    21d8:	27a2                	fld	fa5,8(sp)
    21da:	f6f59ee3          	bne	a1,a5,2156 <rint+0x96>
    21de:	02f7f7d3          	fadd.d	fa5,fa5,fa5
    21e2:	a43e                	fsd	fa5,8(sp)
    21e4:	bf8d                	j	2156 <rint+0x96>
    21e6:	bed68693          	addi	a3,a3,-1043 # 7ffffbed <__freertos_irq_stack_top+0x7fffc29d>
    21ea:	567d                	li	a2,-1
    21ec:	00d65633          	srl	a2,a2,a3
    21f0:	c63a                	sw	a4,12(sp)
    21f2:	c43e                	sw	a5,8(sp)
    21f4:	00f67733          	and	a4,a2,a5
    21f8:	df39                	beqz	a4,2156 <rint+0x96>
    21fa:	8205                	srli	a2,a2,0x1
    21fc:	00f67733          	and	a4,a2,a5
    2200:	db0d                	beqz	a4,2132 <rint+0x72>
    2202:	40000837          	lui	a6,0x40000
    2206:	fff64613          	not	a2,a2
    220a:	8ff1                	and	a5,a5,a2
    220c:	40d856b3          	sra	a3,a6,a3
    2210:	00d7e833          	or	a6,a5,a3
    2214:	bf39                	j	2132 <rint+0x72>

00002216 <scalbn>:
    2216:	1141                	addi	sp,sp,-16
    2218:	a42a                	fsd	fa0,8(sp)
    221a:	48b2                	lw	a7,12(sp)
    221c:	4822                	lw	a6,8(sp)
    221e:	4148d693          	srai	a3,a7,0x14
    2222:	7ff6f693          	andi	a3,a3,2047
    2226:	eeb5                	bnez	a3,22a2 <scalbn+0x8c>
    2228:	00189693          	slli	a3,a7,0x1
    222c:	8285                	srli	a3,a3,0x1
    222e:	0106e6b3          	or	a3,a3,a6
    2232:	c6b5                	beqz	a3,229e <scalbn+0x88>
    2234:	00000797          	auipc	a5,0x0
    2238:	2b47b787          	fld	fa5,692(a5) # 24e8 <TWO52+0x10>
    223c:	12f577d3          	fmul.d	fa5,fa0,fa5
    2240:	76d1                	lui	a3,0xffff4
    2242:	cb068693          	addi	a3,a3,-848 # ffff3cb0 <__freertos_irq_stack_top+0xffff0360>
    2246:	a43e                	fsd	fa5,8(sp)
    2248:	4822                	lw	a6,8(sp)
    224a:	48b2                	lw	a7,12(sp)
    224c:	0ad54663          	blt	a0,a3,22f8 <scalbn+0xe2>
    2250:	4148d693          	srai	a3,a7,0x14
    2254:	7ff6f693          	andi	a3,a3,2047
    2258:	8646                	mv	a2,a7
    225a:	fca68693          	addi	a3,a3,-54
    225e:	96aa                	add	a3,a3,a0
    2260:	7fe00593          	li	a1,2046
    2264:	02d5c263          	blt	a1,a3,2288 <scalbn+0x72>
    2268:	06d04d63          	bgtz	a3,22e2 <scalbn+0xcc>
    226c:	fcb00593          	li	a1,-53
    2270:	04b6d563          	bge	a3,a1,22ba <scalbn+0xa4>
    2274:	66b1                	lui	a3,0xc
    2276:	35068693          	addi	a3,a3,848 # c350 <__freertos_irq_stack_top+0x8a00>
    227a:	00a6c763          	blt	a3,a0,2288 <scalbn+0x72>
    227e:	00000797          	auipc	a5,0x0
    2282:	2027b787          	fld	fa5,514(a5) # 2480 <_data+0x16c>
    2286:	a029                	j	2290 <scalbn+0x7a>
    2288:	00000797          	auipc	a5,0x0
    228c:	1607b787          	fld	fa5,352(a5) # 23e8 <_data+0xd4>
    2290:	c442                	sw	a6,8(sp)
    2292:	c646                	sw	a7,12(sp)
    2294:	2722                	fld	fa4,8(sp)
    2296:	22e78553          	fsgnj.d	fa0,fa5,fa4
    229a:	12f57553          	fmul.d	fa0,fa0,fa5
    229e:	0141                	addi	sp,sp,16
    22a0:	8082                	ret
    22a2:	7ff00593          	li	a1,2047
    22a6:	8646                	mv	a2,a7
    22a8:	fab69be3          	bne	a3,a1,225e <scalbn+0x48>
    22ac:	c442                	sw	a6,8(sp)
    22ae:	c646                	sw	a7,12(sp)
    22b0:	27a2                	fld	fa5,8(sp)
    22b2:	0141                	addi	sp,sp,16
    22b4:	02f7f553          	fadd.d	fa0,fa5,fa5
    22b8:	8082                	ret
    22ba:	801007b7          	lui	a5,0x80100
    22be:	17fd                	addi	a5,a5,-1
    22c0:	03668693          	addi	a3,a3,54
    22c4:	8e7d                	and	a2,a2,a5
    22c6:	06d2                	slli	a3,a3,0x14
    22c8:	00c6e5b3          	or	a1,a3,a2
    22cc:	c442                	sw	a6,8(sp)
    22ce:	c62e                	sw	a1,12(sp)
    22d0:	27a2                	fld	fa5,8(sp)
    22d2:	00000797          	auipc	a5,0x0
    22d6:	21e7b507          	fld	fa0,542(a5) # 24f0 <TWO52+0x18>
    22da:	12f57553          	fmul.d	fa0,fa0,fa5
    22de:	0141                	addi	sp,sp,16
    22e0:	8082                	ret
    22e2:	801007b7          	lui	a5,0x80100
    22e6:	17fd                	addi	a5,a5,-1
    22e8:	8e7d                	and	a2,a2,a5
    22ea:	06d2                	slli	a3,a3,0x14
    22ec:	8ed1                	or	a3,a3,a2
    22ee:	c442                	sw	a6,8(sp)
    22f0:	c636                	sw	a3,12(sp)
    22f2:	2522                	fld	fa0,8(sp)
    22f4:	0141                	addi	sp,sp,16
    22f6:	8082                	ret
    22f8:	00000797          	auipc	a5,0x0
    22fc:	1887b507          	fld	fa0,392(a5) # 2480 <_data+0x16c>
    2300:	12a7f553          	fmul.d	fa0,fa5,fa0
    2304:	0141                	addi	sp,sp,16
    2306:	8082                	ret

00002308 <__errno>:
    2308:	81418793          	addi	a5,gp,-2028 # 2924 <_impure_ptr>
    230c:	4388                	lw	a0,0(a5)
    230e:	8082                	ret
