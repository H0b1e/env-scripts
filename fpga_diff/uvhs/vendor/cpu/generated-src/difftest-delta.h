#ifndef __DIFFTEST_DELTA_H__
#define __DIFFTEST_DELTA_H__
#include "difftest-state.h"
typedef struct __attribute__((packed)) {
  uint8_t  valid;
} DifftestDeltaInfo;

typedef struct {
  DifftestDeltaInfo delta_info;
  uint64_t pregs_xrf_elem[32];
  uint64_t csr_elem[18];
} DeltaState;


class DeltaStats {
private:
  DeltaState buffer[NUM_CORES];
public:
  bool hasProgress = false;

  DeltaStats() {
    memset(buffer, 0, sizeof(buffer));
  }
  DeltaState* get(int coreid){
    return buffer + coreid;
  }
  bool need_pending() {
    return hasProgress && !get(0)->delta_info.valid;
  }
  void sync(int zone, int index) {
    for (int i = 0; i < NUM_CORES; i++) {
      DiffTestState* dut = diffstate_buffer[i]->get(zone, index);
      DeltaState* delta = get(i);
      memcpy(&(dut->pregs_xrf), delta->pregs_xrf_elem, sizeof(DifftestPhyIntRegState));
      memcpy(&(dut->regs.csr), delta->csr_elem, sizeof(DifftestCSRState));
    }
    hasProgress = false;
    get(0)->delta_info.valid = false;
  }
};

#endif // __DIFFTEST_DELTA_H__
