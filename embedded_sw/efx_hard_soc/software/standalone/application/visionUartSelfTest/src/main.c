////////////////////////////////////////////////////////////////////////////////
// Vision hard RISC-V UART self-test.
//
// This test intentionally uses only the SoC internal RAM and UART0. It does not
// touch the video DDR path, framebuffer, interrupts, or future image BRAM window.
////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "bsp.h"
#include "riscv.h"

static void delay_cycles(volatile uint32_t loops)
{
    while (loops--) {
        asm volatile ("nop");
    }
}

static void uart_puts_raw(const char *s)
{
    while (*s) {
        uart_write(BSP_UART_TERMINAL, *s++);
    }
}

static void uart_puthex32(uint32_t value)
{
    uart_writeHex(BSP_UART_TERMINAL, (int)value);
}

static void uart_putdec(uint32_t value)
{
    char buf[11];
    uint32_t i = 0;

    if (value == 0) {
        uart_write(BSP_UART_TERMINAL, '0');
        return;
    }

    while (value && i < sizeof(buf)) {
        buf[i++] = (char)('0' + (value % 10));
        value /= 10;
    }

    while (i) {
        uart_write(BSP_UART_TERMINAL, buf[--i]);
    }
}

void main(void)
{
    uint32_t hart_id = (uint32_t)csr_read(mhartid);
    uint32_t counter = 0;

    if (hart_id != 0) {
        while (1) {
            asm volatile ("wfi");
        }
    }

    bsp_init();

    uart_puts_raw("\r\n\r\n");
    uart_puts_raw("========================================\r\n");
    uart_puts_raw("Vision hard RISC-V UART self-test\r\n");
    uart_puts_raw("Build: internal RAM, UART0 only\r\n");
    uart_puts_raw("UART base: 0x");
    uart_puthex32((uint32_t)BSP_UART_TERMINAL);
    uart_puts_raw("\r\n");
    uart_puts_raw("Internal RAM base: 0x");
    uart_puthex32((uint32_t)SYSTEM_RAM_A_CTRL);
    uart_puts_raw(", size: 0x");
    uart_puthex32((uint32_t)SYSTEM_RAM_A_CTRL_SIZE);
    uart_puts_raw("\r\n");
    uart_puts_raw("mhartid: ");
    uart_putdec(hart_id);
    uart_puts_raw("\r\n");
    uart_puts_raw("Expected serial: 115200 8N1\r\n");
    uart_puts_raw("========================================\r\n");

    while (1) {
        uint32_t cycle_low = (uint32_t)csr_read(mcycle);

        uart_puts_raw("[alive] count=");
        uart_putdec(counter++);
        uart_puts_raw(" mcycle=0x");
        uart_puthex32(cycle_low);
        uart_puts_raw("\r\n");

        delay_cycles(20000000u);
    }
}
