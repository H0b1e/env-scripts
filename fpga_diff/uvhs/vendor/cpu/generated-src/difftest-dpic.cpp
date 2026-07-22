#ifndef CONFIG_NO_DIFFTEST

#include "difftest.h"
#include "difftest-dpic.h"
#include "difftest-query.h"
#ifdef CONFIG_DIFFTEST_PERFCNT
#include "perf.h"
#endif // CONFIG_DIFFTEST_PERFCNT


enum DifftestBundleType {
  ArchEvent,
  TrapEvent,
  InstrCommit,
  PhyIntRegStateElem,
  CSRStateElem,
  DeltaInfo,
  BatchHead,
  BatchStep
};

#define DIFFTEST_BATCH_CHUNK_BYTES 32
#define DIFFTEST_BATCH_BEAT_CHUNKS 2
#define DIFFTEST_BATCH_INFO_BYTES 32
#define DIFFTEST_BATCH_MAX_DATA_BYTES 96

#ifdef CONFIG_DIFFTEST_QUERY
static int batch_query_nums[8] = {0};
#endif // CONFIG_DIFFTEST_QUERY


#include "difftest-delta.h"
DeltaStats* dStats = nullptr;
#define DELTA_BUF(core_id) (dStats->get(core_id))


DiffStateBuffer** diffstate_buffer = nullptr;
#define DUT_BUF(core_id, zone, index) (diffstate_buffer[core_id]->get(zone, index))

void diffstate_buffer_init() {
  diffstate_buffer = new DiffStateBuffer*[NUM_CORES];
  for (int i = 0; i < NUM_CORES; i++) {
    diffstate_buffer[i] = new DPICBuffer(i);
  }
  dStats = new DeltaStats;
}

void diffstate_buffer_free() {
  for (int i = 0; i < NUM_CORES; i++) {
    delete diffstate_buffer[i];
  }
  delete[] diffstate_buffer;
  diffstate_buffer = nullptr;
  delete dStats;
}
      

typedef struct __attribute__((packed)) {
  uint8_t num;
  uint8_t id;
} DifftestBatchInfo;

class DifftestBatchParser {
private:
  uint32_t info_num = 0;
  uint32_t parsed_infos = 0;
  uint32_t info_idx = 0;
  uint32_t data_len = 0;
  uint32_t info_len = 0;
  uint32_t info_bytes = 0;
  uint32_t parsed_chunks = 0;
  uint32_t cluster_bytes = 0;
  uint8_t info_buf[DIFFTEST_BATCH_INFO_BYTES] = {0};
  uint8_t data_buf[DIFFTEST_BATCH_MAX_DATA_BYTES] = {0};

  inline uint32_t align_chunk(uint32_t bytes) const { return (bytes + DIFFTEST_BATCH_CHUNK_BYTES - 1) / DIFFTEST_BATCH_CHUNK_BYTES * DIFFTEST_BATCH_CHUNK_BYTES; }

  inline DifftestBatchInfo* info_entries() { return reinterpret_cast<DifftestBatchInfo*>(info_buf); }

public:
  bool reading_info() const { return info_idx == 0; }
  uint32_t info_count() const { return info_num; }
  uint32_t parsed_info_count() const { return parsed_infos; }
  uint32_t parsed_chunk_count() const { return parsed_chunks; }
  DifftestBatchInfo current_info() { return info_entries()[info_idx]; }
  uint8_t* cluster_buf() { return data_buf; }

  bool recv_info(const uint8_t* chunk_payload) {
    if (info_len + DIFFTEST_BATCH_CHUNK_BYTES > sizeof(info_buf)) {
      printf("Batch info buffer overflow: offset %u, chunk %u, buffer %zu\n",
        info_len, (uint32_t)DIFFTEST_BATCH_CHUNK_BYTES, sizeof(info_buf));
      assert(0);
    }
    memcpy(info_buf + info_len, chunk_payload, DIFFTEST_BATCH_CHUNK_BYTES);
    info_len += DIFFTEST_BATCH_CHUNK_BYTES;
    DifftestBatchInfo* entries = info_entries();

    if (info_bytes == 0) {
      uint8_t id = entries[0].id;
      uint8_t num = entries[0].num;
      if (id != BatchHead) {
        printf("Batch head marker mismatch: id %u, expected %u\n", id, BatchHead);
        assert(0);
      }
      info_num = num;
      info_bytes = align_chunk((info_num + 2) * sizeof(DifftestBatchInfo));
      if (info_bytes > sizeof(info_buf)) {
        printf("Batch info buffer overflow: expected %u, buffer %zu\n", info_bytes, sizeof(info_buf));
        assert(0);
      }
    }

    if (info_len < info_bytes) return true;
    if (info_len != info_bytes) {
      printf("Batch info size mismatch: received %u, expected %u\n", info_len, info_bytes);
      assert(0);
    }
    for (uint32_t i = 0; i < info_num + 2; i++) {
      if (!diffstate_buffer) return false;
      uint8_t id = entries[i].id;
      uint8_t num = entries[i].num;
      if (i == info_num + 1) {
        if (id != BatchStep) {
          printf("Batch step marker mismatch: id %u, expected %u\n", id, BatchStep);
          assert(0);
        }
      } else if (i > 0 && id == BatchStep) {
        printf("Batch info size mismatch: BatchStep at %u, expected %u\n", i, info_num + 1);
        assert(0);
      }
#ifdef CONFIG_DIFFTEST_QUERY
      if (qStats) {
        qStats->BatchInfo_write(id, num);
        batch_query_nums[id] = num;
      }
#endif // CONFIG_DIFFTEST_QUERY
    }
    info_len = 0;
    parsed_infos = 0;
    info_idx = 1;
    parsed_chunks = info_bytes / DIFFTEST_BATCH_CHUNK_BYTES;
    return true;
  }

  bool recv_cluster(const uint8_t* chunk_payload, uint8_t num, uint32_t elem_bytes) {
    uint32_t data_size = (uint32_t)num * elem_bytes;
    cluster_bytes = align_chunk(data_size);
    if (data_len + DIFFTEST_BATCH_CHUNK_BYTES > sizeof(data_buf)) {
      printf("Batch data buffer overflow: offset %u, chunk %u, buffer %zu\n",
        data_len, (uint32_t)DIFFTEST_BATCH_CHUNK_BYTES, sizeof(data_buf));
      assert(0);
    }
    memcpy(data_buf + data_len, chunk_payload, DIFFTEST_BATCH_CHUNK_BYTES);
    data_len += DIFFTEST_BATCH_CHUNK_BYTES;
    if (data_len < cluster_bytes) return false;
    if (data_len != cluster_bytes) {
      printf("Batch cluster size mismatch: received %u, expected %u\n", data_len, cluster_bytes);
      assert(0);
    }
    return true;
  }

  void finish_cluster() {
    data_len = 0;
    parsed_chunks += cluster_bytes / DIFFTEST_BATCH_CHUNK_BYTES;
    parsed_infos++;
    info_idx++;
  }

  void reset_step() {
    info_idx = 0;
    data_len = 0;
    info_len = 0;
    info_bytes = 0;
    info_num = 0;
    parsed_infos = 0;
    parsed_chunks = 0;
  }
};


#ifdef CONFIG_DIFFTEST_PERFCNT
enum DIFFSTATE_PERF {
  perf_v_difftest_Batch,
  perf_Batch_ArchEvent,
  perf_Batch_TrapEvent,
  perf_Batch_InstrCommit,
  perf_Batch_PhyIntRegStateElem,
  perf_Batch_CSRStateElem,
  perf_Batch_DeltaInfo,
  DIFFSTATE_PERF_NUM
};
long long dpic_calls[DIFFSTATE_PERF_NUM] = {0}, dpic_bytes[DIFFSTATE_PERF_NUM] = {0};
void diffstate_perfcnt_init() {
  for (int i = 0; i < DIFFSTATE_PERF_NUM; i++) {
    dpic_calls[i] = 0;
    dpic_bytes[i] = 0;
  }
}
void diffstate_perfcnt_finish(long long msec) {
  long long calls_sum = 0, bytes_sum = 0;
  const char *dpic_name[DIFFSTATE_PERF_NUM] = {
    "v_difftest_Batch",
    "Batch_ArchEvent",
    "Batch_TrapEvent",
    "Batch_InstrCommit",
    "Batch_PhyIntRegStateElem",
    "Batch_CSRStateElem",
    "Batch_DeltaInfo"
  };
  for (int i = 0; i < DIFFSTATE_PERF_NUM; i++) {
    difftest_perfcnt_print(dpic_name[i], dpic_calls[i], dpic_bytes[i], msec);
  }
  for (int i = 1; i < DIFFSTATE_PERF_NUM; i++) {
    calls_sum += dpic_calls[i];
    bytes_sum += dpic_bytes[i];
  }
  difftest_perfcnt_print("DIFFSTATE_SUM", calls_sum, bytes_sum, msec);
}
#endif // CONFIG_DIFFTEST_PERFCNT



extern "C" void v_difftest_Batch (
  uint8_t  io[64]
) {
  if (!diffstate_buffer) return;

#ifdef CONFIG_DIFFTEST_PERFCNT
  dpic_calls[perf_v_difftest_Batch] ++;
  dpic_bytes[perf_v_difftest_Batch] += 64;
#endif // CONFIG_DIFFTEST_PERFCNT

  
  uint8_t* payload = (uint8_t*)io;
  static DifftestBatchParser parser;
  static int dut_index = 0;

  for (uint32_t chunk = 0; chunk <= DIFFTEST_BATCH_BEAT_CHUNKS; chunk++) {
    bool has_chunk = chunk < DIFFTEST_BATCH_BEAT_CHUNKS;
    const uint8_t* chunk_payload = payload + chunk * DIFFTEST_BATCH_CHUNK_BYTES;
    if (has_chunk && parser.reading_info()) {
      if (!parser.recv_info(chunk_payload)) return;
      if (parser.reading_info() || parser.current_info().id != BatchStep) continue;
    }
    if (parser.reading_info()) continue;
    if (!has_chunk && parser.current_info().id != BatchStep) continue;

    uint8_t id = parser.current_info().id;
    uint8_t num = parser.current_info().num;
    uint32_t coreid, index, address;
    if (id == BatchStep) {
      if (parser.info_count() != parser.parsed_info_count()) {
        printf("Batch info size mismatch: expected %u, parsed %u\n",
          parser.info_count(), parser.parsed_info_count());
        assert(0);
      }
      if (num != parser.parsed_chunk_count()) {
        printf("Batch chunk size mismatch: expected %u, parsed %u\n",
          num, parser.parsed_chunk_count());
        assert(0);
      }
#ifdef CONFIG_DIFFTEST_QUERY
      if (qStats) qStats->BatchStep_write(batch_query_nums);
      memset(batch_query_nums, 0, sizeof(batch_query_nums));
#endif // CONFIG_DIFFTEST_QUERY
      parser.reset_step();

      if (dStats->need_pending()) {
        return; // Not changing dut_index
      }
      dStats->sync(0, dut_index);

      dut_index = (dut_index + 1) % CONFIG_DIFFTEST_BATCH_SIZE;
#ifdef CONFIG_DIFFTEST_INTERNAL_STEP
#ifdef FPGA_HOST
      extern void fpga_nstep(uint8_t step);
      fpga_nstep(1);
#else
      extern void simv_nstep(uint8_t step);
      simv_nstep(1);
#endif // FPGA_HOST
#endif // CONFIG_DIFFTEST_INTERNAL_STEP
      return;
    }

    else if (id == ArchEvent) {
      if (!parser.recv_cluster(chunk_payload, num, (sizeof(DifftestArchEvent) + 1))) continue;
#ifdef CONFIG_DIFFTEST_PERFCNT
      dpic_calls[perf_Batch_ArchEvent] += num;
      dpic_bytes[perf_Batch_ArchEvent] += num * (sizeof(DifftestArchEvent) + 1);
#endif // CONFIG_DIFFTEST_PERFCNT
      uint8_t* data = parser.cluster_buf();
      for (int j = 0; j < num; j++) {
        coreid = *((uint8_t*)(data + 25));
        auto packet = &(DUT_BUF(coreid, 0, dut_index)->event);
        memcpy(packet, data, sizeof(DifftestArchEvent));
#ifdef CONFIG_DIFFTEST_QUERY
        qStats->ArchEvent_write(0, coreid, packet);
#endif // CONFIG_DIFFTEST_QUERY
        data += (sizeof(DifftestArchEvent) + 1);
      }
      parser.finish_cluster();
    }
        
    else if (id == TrapEvent) {
      if (!parser.recv_cluster(chunk_payload, num, (sizeof(DifftestTrapEvent) + 1))) continue;
#ifdef CONFIG_DIFFTEST_PERFCNT
      dpic_calls[perf_Batch_TrapEvent] += num;
      dpic_bytes[perf_Batch_TrapEvent] += num * (sizeof(DifftestTrapEvent) + 1);
#endif // CONFIG_DIFFTEST_PERFCNT
      uint8_t* data = parser.cluster_buf();
      for (int j = 0; j < num; j++) {
        coreid = *((uint8_t*)(data + 34));
        auto packet = &(DUT_BUF(coreid, 0, dut_index)->trap);
        memcpy(packet, data, sizeof(DifftestTrapEvent));
#ifdef CONFIG_DIFFTEST_QUERY
        qStats->TrapEvent_write(0, coreid, packet);
#endif // CONFIG_DIFFTEST_QUERY
        data += (sizeof(DifftestTrapEvent) + 1);
      }
      parser.finish_cluster();
    }
        
    else if (id == InstrCommit) {
      if (!parser.recv_cluster(chunk_payload, num, (sizeof(DifftestInstrCommit) + 2))) continue;
#ifdef CONFIG_DIFFTEST_PERFCNT
      dpic_calls[perf_Batch_InstrCommit] += num;
      dpic_bytes[perf_Batch_InstrCommit] += num * (sizeof(DifftestInstrCommit) + 2);
#endif // CONFIG_DIFFTEST_PERFCNT
      uint8_t* data = parser.cluster_buf();
      for (int j = 0; j < num; j++) {
        coreid = *((uint8_t*)(data + 45));
        index = *((uint8_t*)(data + 46));
        auto packet = &(DUT_BUF(coreid, 0, dut_index)->commit[index]);
        memcpy(packet, data, sizeof(DifftestInstrCommit));
#ifdef CONFIG_DIFFTEST_QUERY
        qStats->InstrCommit_write(0, coreid, index, packet);
#endif // CONFIG_DIFFTEST_QUERY
        data += (sizeof(DifftestInstrCommit) + 2);
      }
      parser.finish_cluster();
    }
        
    else if (id == PhyIntRegStateElem) {
      if (!parser.recv_cluster(chunk_payload, num, (sizeof(uint64_t) + 2))) continue;
#ifdef CONFIG_DIFFTEST_PERFCNT
      dpic_calls[perf_Batch_PhyIntRegStateElem] += num;
      dpic_bytes[perf_Batch_PhyIntRegStateElem] += num * (sizeof(uint64_t) + 2);
#endif // CONFIG_DIFFTEST_PERFCNT
      uint8_t* data = parser.cluster_buf();
      for (int j = 0; j < num; j++) {
        coreid = *((uint8_t*)(data + 8));
        index = *((uint8_t*)(data + 9));
        auto packet = &(DELTA_BUF(coreid)->pregs_xrf_elem[index]);
        memcpy(packet, data, sizeof(uint64_t));
        dStats->hasProgress = true;
#ifdef CONFIG_DIFFTEST_QUERY
        qStats->PhyIntRegStateElem_write(0, coreid, index, packet);
#endif // CONFIG_DIFFTEST_QUERY
        data += (sizeof(uint64_t) + 2);
      }
      parser.finish_cluster();
    }
        
    else if (id == CSRStateElem) {
      if (!parser.recv_cluster(chunk_payload, num, (sizeof(uint64_t) + 2))) continue;
#ifdef CONFIG_DIFFTEST_PERFCNT
      dpic_calls[perf_Batch_CSRStateElem] += num;
      dpic_bytes[perf_Batch_CSRStateElem] += num * (sizeof(uint64_t) + 2);
#endif // CONFIG_DIFFTEST_PERFCNT
      uint8_t* data = parser.cluster_buf();
      for (int j = 0; j < num; j++) {
        coreid = *((uint8_t*)(data + 8));
        index = *((uint8_t*)(data + 9));
        auto packet = &(DELTA_BUF(coreid)->csr_elem[index]);
        memcpy(packet, data, sizeof(uint64_t));
        dStats->hasProgress = true;
#ifdef CONFIG_DIFFTEST_QUERY
        qStats->CSRStateElem_write(0, coreid, index, packet);
#endif // CONFIG_DIFFTEST_QUERY
        data += (sizeof(uint64_t) + 2);
      }
      parser.finish_cluster();
    }
        
    else if (id == DeltaInfo) {
      if (!parser.recv_cluster(chunk_payload, num, (sizeof(DifftestDeltaInfo) + 1))) continue;
#ifdef CONFIG_DIFFTEST_PERFCNT
      dpic_calls[perf_Batch_DeltaInfo] += num;
      dpic_bytes[perf_Batch_DeltaInfo] += num * (sizeof(DifftestDeltaInfo) + 1);
#endif // CONFIG_DIFFTEST_PERFCNT
      uint8_t* data = parser.cluster_buf();
      for (int j = 0; j < num; j++) {
        coreid = *((uint8_t*)(data + 1));
        auto packet = &(DELTA_BUF(coreid)->delta_info);
        memcpy(packet, data, sizeof(DifftestDeltaInfo));
#ifdef CONFIG_DIFFTEST_QUERY
        qStats->DeltaInfo_write(0, coreid, packet);
#endif // CONFIG_DIFFTEST_QUERY
        data += (sizeof(DifftestDeltaInfo) + 1);
      }
      parser.finish_cluster();
    }
        
    else {
      printf("Batch bundle id mismatch: id %u\n", id);
      assert(0);
    }
  }

}


#endif // CONFIG_NO_DIFFTEST

