PROJ_NAME=smallFrameApbTest

SHELL ?= D:/Efinity/efinity-riscv-ide-2025.2/build_tools/bin/sh.exe

STANDALONE=../..
BSP ?= efinix/EfxSapphireSoc

CFLAGS+=-DSMP

SRCS =  $(wildcard src/*.c) \
        ${STANDALONE}/common/start.S

include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk

LDSCRIPT = ${BSP_PATH}/linker/default_i.ld
