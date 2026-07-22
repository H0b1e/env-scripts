/*
 * cfgpeek - read/write the XDMA config BAR (/dev/xdma0_user).
 *
 * The config BAR is the AXI-Lite window into the SimTop XDMAConfigBar
 * register file (the difftest control/status registers). Use this to inspect
 * the H2C drain state without touching fpga-host.
 *
 * Usage:
 *   sudo ./cfgpeek                 dump all registers 0x00..0x28
 *   sudo ./cfgpeek 24              read one register (hex offset)
 *   sudo ./cfgpeek 24 1            write one register (hex off, hex value)
 *
 * MEM_H2C (0x24) status, low 2 bits:
 *   0 = idle (not armed)
 *   1 = armed / draining in progress
 *   2 = done
 *   3 = address out of range error
 *
 * Build (build host, static, portable to 19p-host):
 *   gcc-15 -static -O2 cfgpeek.c -o cfgpeek
 * Build native on 19p-host (if gcc present):
 *   cc -O2 cfgpeek.c -o cfgpeek
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

#define USER_DEV  "/dev/xdma0_user"
#define MAP_SIZE  0x1000   /* one page; all config regs live in the low 0x100 */

/* Register offset -> human name, indexed by word (offset >> 2). */
static const char *names[] = {
    [0x00 / 4] = "CFG_RESET",
    [0x04 / 4] = "RESET(cpu)",
    [0x08 / 4] = "DIFFTEST_ENABLE",
    [0x0c / 4] = "ILA_TRIGGER",
    [0x10 / 4] = "SQUASH_ENABLE",
    [0x14 / 4] = "SEED",
    [0x18 / 4] = "RAM_SIZE_MB",
    [0x1c / 4] = "MEM_INIT",
    [0x20 / 4] = "MEM_CPU",
    [0x24 / 4] = "MEM_H2C(status)",
    [0x28 / 4] = "H2C_SIZE_MB",
};

static const char *h2c_decode(uint32_t v) {
    switch (v & 0x3) {
        case 0: return "IDLE (not armed)";
        case 1: return "ARMED/draining (stuck here => DDR write path blocked)";
        case 2: return "DONE";
        case 3: return "ADDR-OUT-OF-RANGE error";
        default: return "?";
    }
}

int main(int argc, char **argv) {
    int fd = open(USER_DEV, O_RDWR | O_SYNC);
    if (fd < 0) { perror(USER_DEV); return 1; }

    volatile uint32_t *m = (volatile uint32_t *)mmap(NULL, MAP_SIZE,
            PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (m == MAP_FAILED) { perror("mmap"); close(fd); return 1; }

    if (argc >= 3) {                       /* write */
        uint32_t off = (uint32_t)(strtoul(argv[1], NULL, 16) & 0xfff);
        uint32_t val = (uint32_t)strtoul(argv[2], NULL, 16);
        m[off >> 2] = val;
        printf("W 0x%02x <- 0x%08x\n", off, val);
    } else if (argc == 2) {                /* read one */
        uint32_t off = (uint32_t)(strtoul(argv[1], NULL, 16) & 0xfff);
        uint32_t v = m[off >> 2];
        printf("R 0x%02x = 0x%08x\n", off, v);
        if (off == 0x24) printf("    MEM_H2C: %s\n", h2c_decode(v));
    } else {                               /* dump all */
        int max = (int)(sizeof(names) / sizeof(names[0]));
        for (int i = 0; i < max; i++) {
            uint32_t v = m[i];
            printf("0x%02x  %-20s = 0x%08x", i * 4,
                   names[i] ? names[i] : "(reserved)", v);
            if (i * 4 == 0x24) printf("   <- %s", h2c_decode(v));
            printf("\n");
        }
    }

    munmap((void *)m, MAP_SIZE);
    close(fd);
    return 0;
}
