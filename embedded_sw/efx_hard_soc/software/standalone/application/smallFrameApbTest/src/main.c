#include <stdint.h>
#include "bsp.h"
#include "riscv.h"

#define FRAME_APB_BASE       IO_APB_SLAVE_0_INPUT
#define REG_MAGIC            0x0000u
#define REG_DIMENSIONS       0x0008u
#define REG_FRAME_SEQ        0x0010u
#define REG_STATUS           0x0018u
#define REG_BUFFER0          0x001cu
#define REG_BUFFER1          0x0020u
#define REG_BUFFER_BYTES     0x0024u
#define REG_DROP_COUNT       0x0028u
#define REG_CONTROL          0x0030u
#define REG_CLAIM_BANK       0x0034u
#define REG_CLAIM_SEQ        0x0038u

#define STATUS_FRAME_VALID   (1u << 1)
#define CONTROL_CLAIM        (1u << 0)
#define CONTROL_RELEASE      (1u << 1)
#define EXPECTED_MAGIC       0x5649534eu

static uint32_t reg_read(uint32_t offset)
{
    return *((volatile uint32_t *)(FRAME_APB_BASE + offset));
}

static void reg_write(uint32_t offset, uint32_t value)
{
    *((volatile uint32_t *)(FRAME_APB_BASE + offset)) = value;
}

static void uart_puts_raw(const char *text)
{
    while (*text) {
        uart_write(BSP_UART_TERMINAL, *text++);
    }
}

static void uart_hex(uint32_t value)
{
    uart_writeHex(BSP_UART_TERMINAL, (int)value);
}

void main(void)
{
    uint32_t last_seq = 0;

    if ((uint32_t)csr_read(mhartid) != 0u) {
        while (1) {
            asm volatile ("wfi");
        }
    }

    bsp_init();
    uart_puts_raw("\r\nVision 160x90 APB frame test\r\n");
    uart_puts_raw("base=0x");
    uart_hex(FRAME_APB_BASE);
    uart_puts_raw(" magic=0x");
    uart_hex(reg_read(REG_MAGIC));
    uart_puts_raw(" dimensions=0x");
    uart_hex(reg_read(REG_DIMENSIONS));
    uart_puts_raw("\r\n");

    if (reg_read(REG_MAGIC) != EXPECTED_MAGIC) {
        uart_puts_raw("ERROR: APB frame window not detected\r\n");
        while (1) {
            asm volatile ("wfi");
        }
    }

    while (1) {
        uint32_t status = reg_read(REG_STATUS);
        uint32_t seq = reg_read(REG_FRAME_SEQ);

        if ((status & STATUS_FRAME_VALID) && (seq != last_seq)) {
            uint32_t bank;
            uint32_t buffer_offset;
            uint32_t buffer_bytes;
            uint32_t word_count;
            uint32_t first_word;
            uint32_t last_word;
            uint32_t checksum = 0;
            uint32_t i;
            volatile uint32_t *pixels;

            reg_write(REG_CONTROL, CONTROL_CLAIM);
            bank = reg_read(REG_CLAIM_BANK);
            seq = reg_read(REG_CLAIM_SEQ);
            buffer_offset = reg_read(bank ? REG_BUFFER1 : REG_BUFFER0);
            buffer_bytes = reg_read(REG_BUFFER_BYTES);
            word_count = buffer_bytes >> 2;
            pixels = (volatile uint32_t *)(FRAME_APB_BASE + buffer_offset);

            first_word = pixels[0];
            for (i = 0; i < word_count; ++i) {
                checksum = (checksum << 5) | (checksum >> 27);
                checksum ^= pixels[i];
            }
            last_word = pixels[word_count - 1u];
            reg_write(REG_CONTROL, CONTROL_RELEASE);

            uart_puts_raw("frame seq=0x");
            uart_hex(seq);
            uart_puts_raw(" bank=0x");
            uart_hex(bank);
            uart_puts_raw(" first=0x");
            uart_hex(first_word);
            uart_puts_raw(" last=0x");
            uart_hex(last_word);
            uart_puts_raw(" checksum=0x");
            uart_hex(checksum);
            uart_puts_raw(" drops=0x");
            uart_hex(reg_read(REG_DROP_COUNT));
            uart_puts_raw("\r\n");

            last_seq = seq;
        }
    }
}
