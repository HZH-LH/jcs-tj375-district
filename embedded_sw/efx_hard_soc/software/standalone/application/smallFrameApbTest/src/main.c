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
#define DEBUG_UART           SYSTEM_UART_0_IO_CTRL
#define ROBOT_UART           SYSTEM_UART_1_IO_CTRL
#define UART_BAUDRATE        500000u
#define UART_SAMPLE_PER_BIT  8u
#define UART_DATA_OFFSET     0x00u
#define UART_STATUS_OFFSET   0x04u
#define UART_TX_AVAIL_SHIFT  16u
#define UART_TX_AVAIL_MASK   0xffu
#define FRAME_WIDTH          160u
#define FRAME_HEIGHT         90u
#define FRAME_FORMAT_RGB565  1u
#define FRAME_GAP_US         50000u

#define STREAM_STOP          0u
#define STREAM_RISCV         1u
#define STREAM_FPGA          2u

static uint32_t reg_read(uint32_t offset)
{
    return *((volatile uint32_t *)(FRAME_APB_BASE + offset));
}

static void reg_write(uint32_t offset, uint32_t value)
{
    *((volatile uint32_t *)(FRAME_APB_BASE + offset)) = value;
}

static void uart_config_debug_baud(uint32_t uart)
{
    Uart_Config config;

    config.dataLength = BITS_8;
    config.parity = NONE;
    config.stop = ONE;
    config.clockDivider = BSP_CLINT_HZ /
                          (UART_BAUDRATE * UART_SAMPLE_PER_BIT) - 1u;
    uart_applyConfig(uart, &config);
}

static void uart0_write_byte_blocking(uint8_t value)
{
    volatile uint32_t *status = (volatile uint32_t *)(DEBUG_UART + UART_STATUS_OFFSET);
    volatile uint32_t *data = (volatile uint32_t *)(DEBUG_UART + UART_DATA_OFFSET);

    while (((*status >> UART_TX_AVAIL_SHIFT) & UART_TX_AVAIL_MASK) == 0u) {
    }
    *data = value;
}

static void uart0_write_u16(uint16_t value)
{
    uart0_write_byte_blocking((uint8_t)(value & 0xffu));
    uart0_write_byte_blocking((uint8_t)(value >> 8));
}

static void uart0_write_u32(uint32_t value)
{
    uart0_write_byte_blocking((uint8_t)(value & 0xffu));
    uart0_write_byte_blocking((uint8_t)((value >> 8) & 0xffu));
    uart0_write_byte_blocking((uint8_t)((value >> 16) & 0xffu));
    uart0_write_byte_blocking((uint8_t)(value >> 24));
}

static void uart0_write_frame_word_rgb565_be(uint32_t value)
{
    uint16_t pixel0 = (uint16_t)(value & 0xffffu);
    uint16_t pixel1 = (uint16_t)(value >> 16);

    uart0_write_byte_blocking((uint8_t)(pixel0 >> 8));
    uart0_write_byte_blocking((uint8_t)(pixel0 & 0xffu));
    uart0_write_byte_blocking((uint8_t)(pixel1 >> 8));
    uart0_write_byte_blocking((uint8_t)(pixel1 & 0xffu));
}

static uint32_t checksum_update(uint32_t checksum, uint32_t word)
{
    return ((checksum << 5) | (checksum >> 27)) ^ word;
}

static void uart0_write_frame_header(uint32_t seq, uint32_t payload_bytes,
                                     uint32_t bank)
{
    uart0_write_byte_blocking('V');
    uart0_write_byte_blocking('F');
    uart0_write_byte_blocking('R');
    uart0_write_byte_blocking('M');
    uart0_write_byte_blocking(1);                /* protocol version */
    uart0_write_byte_blocking(FRAME_FORMAT_RGB565);
    uart0_write_u16(FRAME_WIDTH);
    uart0_write_u16(FRAME_HEIGHT);
    uart0_write_u32(seq);
    uart0_write_u32(payload_bytes);
    uart0_write_u32(0);                         /* checksum follows payload */
    uart0_write_byte_blocking((uint8_t)bank);
    uart0_write_byte_blocking(1);                /* flags: footer checksum */
}

static uint32_t uart0_poll_command(uint32_t current_mode)
{
    while (uart_readOccupancy(DEBUG_UART) != 0u) {
        char cmd = uart_read(DEBUG_UART);
        if ((cmd == 'R') || (cmd == 'r')) {
            current_mode = STREAM_RISCV;
        } else if ((cmd == 'F') || (cmd == 'f')) {
            current_mode = STREAM_FPGA;
        } else if ((cmd == 'S') || (cmd == 's')) {
            current_mode = STREAM_STOP;
        }
    }
    return current_mode;
}

void main(void)
{
    uint32_t last_seq = 0;
    uint32_t stream_mode = STREAM_RISCV;

    if ((uint32_t)csr_read(mhartid) != 0u) {
        while (1) {
            asm volatile ("wfi");
        }
    }

    uart_config_debug_baud(DEBUG_UART);
    uart_config_debug_baud(ROBOT_UART);

    if (reg_read(REG_MAGIC) != EXPECTED_MAGIC) {
        uart_writeStr(DEBUG_UART, "VISION APB ERROR\r\n");
        while (1) {
            asm volatile ("wfi");
        }
    }

    while (1) {
        uint32_t status = reg_read(REG_STATUS);
        uint32_t seq = reg_read(REG_FRAME_SEQ);

        stream_mode = uart0_poll_command(stream_mode);

        if ((stream_mode == STREAM_RISCV) &&
            (status & STATUS_FRAME_VALID) && (seq != last_seq)) {
            uint32_t bank;
            uint32_t buffer_offset;
            uint32_t buffer_bytes;
            uint32_t word_count;
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

            uart0_write_frame_header(seq, buffer_bytes, bank);
            for (i = 0; i < word_count; ++i) {
                uint32_t word = pixels[i];
                checksum = checksum_update(checksum, word);
                uart0_write_frame_word_rgb565_be(word);
            }
            uart0_write_u32(checksum);

            reg_write(REG_CONTROL, CONTROL_RELEASE);
            last_seq = seq;
            bsp_uDelay(FRAME_GAP_US);
        } else {
            bsp_uDelay(1000u);
        }
    }
}
