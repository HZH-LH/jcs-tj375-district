#include "bsp.h"

static void uart_puts(const char *text)
{
    while (*text) {
        uart_write(BSP_UART_TERMINAL, *text++);
    }
}

void main(void)
{
    bsp_init();
    uart_puts("RISCV_OCR_BOOT\r\n");

    while (1) {
        uart_puts("RISCV_OCR_ALIVE\r\n");
        bsp_uDelay(1000000);
    }
}
