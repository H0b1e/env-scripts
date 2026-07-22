#ifndef __DIFFTEST_DPIC_H__
#define __DIFFTEST_DPIC_H__

#include <cstdint>
#include "difftest-state.h"
#ifdef CONFIG_DIFFTEST_QUERY
#include "difftest-query.h"
#endif // CONFIG_DIFFTEST_QUERY
#if defined(CONFIG_DIFFTEST_BATCH) && !defined(CONFIG_DIFFTEST_FPGA)
#include "svdpi.h"
#endif // CONFIG_DIFFTEST_BATCH && !CONFIG_DIFFTEST_FPGA
#include "difftest-delta.h"
static inline void diffstate_update_archreg(uint8_t coreid, DiffTestState* dut) {
  for (int i = 0; i < 32; i++) { dut->regs.xrf.value[i] = dut->pregs_xrf.value[i]; }
#ifdef CONFIG_DIFFTEST_QUERY
  if (qStats) qStats->ArchIntRegState_write(coreid, dut);
#endif // CONFIG_DIFFTEST_QUERY
}


class DPICBuffer : public DiffStateBuffer {
private:
  DiffTestState buffer[CONFIG_DIFFTEST_ZONESIZE][CONFIG_DIFFTEST_BUFLEN];
  int read_ptr = 0;
  int zone_ptr = 0;
  bool init = true;
  uint8_t coreid;
public:
  DPICBuffer(uint8_t coreid): coreid(coreid) {
    memset(buffer, 0, sizeof(buffer));
  }
  inline DiffTestState* get(int zone, int index) {
    return buffer[zone] + index;
  }
  inline DiffTestState* next() {
    DiffTestState* ret = buffer[zone_ptr] + read_ptr;
    diffstate_update_archreg(coreid, ret);
    read_ptr = (read_ptr + 1) % CONFIG_DIFFTEST_BUFLEN;
    return ret;
  }
  inline void switch_zone() {
    if (init) {
      init = false;
      return;
    }
    zone_ptr = (zone_ptr + 1) % CONFIG_DIFFTEST_ZONESIZE;
    read_ptr = 0;
  }
};


extern "C" void v_difftest_Batch (
  uint8_t  io[64]
);

#endif // __DIFFTEST_DPIC_H__

