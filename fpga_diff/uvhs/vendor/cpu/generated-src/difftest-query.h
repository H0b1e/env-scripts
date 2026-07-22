
#ifndef __DIFFTEST_QUERY_H__
#define __DIFFTEST_QUERY_H__

#include <cstdint>
#include "difftest-state.h"
#include "query.h"
#ifdef CONFIG_DIFFTEST_DELTA
#include "difftest-delta.h"
#endif // CONFIG_DIFFTEST_DELTA

#ifdef CONFIG_DIFFTEST_QUERY

class QueryStats: public QueryStatsBase {
public:
  Query* query_ArchEvent;
  Query* query_TrapEvent;
  Query* query_InstrCommit;
  Query* query_PhyIntRegStateElem;
  Query* query_ArchIntRegState;
  Query* query_CSRStateElem;
  Query* query_DeltaInfo;
  Query* query_BatchInfo;
  Query* query_BatchStep;
  QueryStats(char *path): QueryStatsBase(path) {
    ArchEvent_init();
    TrapEvent_init();
    InstrCommit_init();
    PhyIntRegStateElem_init();
    ArchIntRegState_init();
    CSRStateElem_init();
    DeltaInfo_init();
    BatchTable_init();
  }
  
  void ArchEvent_init() {
    const char* createSql = " CREATE TABLE ArchEvent(" \
      "ID INTEGER PRIMARY KEY AUTOINCREMENT," \
      "STEP INTEGER NOT NULL," \
      "COREID INTEGER NOT NULL," \
      "VALID INTEGER NOT NULL," \
      "INTERRUPT INTEGER NOT NULL," \
      "EXCEPTION INTEGER NOT NULL," \
      "EXCEPTIONPC INTEGER NOT NULL," \
      "EXCEPTIONINST INTEGER NOT NULL," \
      "HASNMI INTEGER NOT NULL," \
      "VIRTUALINTERRUPTISHVICTLINJECT INTEGER NOT NULL," \
      "IRTOHS INTEGER NOT NULL," \
      "IRTOVS INTEGER NOT NULL);";
    const char* insertSql = "INSERT INTO ArchEvent (STEP,COREID,VALID,INTERRUPT,EXCEPTION,EXCEPTIONPC,EXCEPTIONINST,HASNMI,VIRTUALINTERRUPTISHVICTLINJECT,IRTOHS,IRTOVS) " \
      " VALUES (?,?,?,?,?,?,?,?,?,?,?);";
    query_ArchEvent = new Query(mem_db, createSql, insertSql);
  }

  void TrapEvent_init() {
    const char* createSql = " CREATE TABLE TrapEvent(" \
      "ID INTEGER PRIMARY KEY AUTOINCREMENT," \
      "STEP INTEGER NOT NULL," \
      "COREID INTEGER NOT NULL," \
      "HASTRAP INTEGER NOT NULL," \
      "CYCLECNT INTEGER NOT NULL," \
      "INSTRCNT INTEGER NOT NULL," \
      "HASWFI INTEGER NOT NULL," \
      "CODE INTEGER NOT NULL," \
      "PC INTEGER NOT NULL);";
    const char* insertSql = "INSERT INTO TrapEvent (STEP,COREID,HASTRAP,CYCLECNT,INSTRCNT,HASWFI,CODE,PC) " \
      " VALUES (?,?,?,?,?,?,?,?);";
    query_TrapEvent = new Query(mem_db, createSql, insertSql);
  }

  void InstrCommit_init() {
    const char* createSql = " CREATE TABLE InstrCommit(" \
      "ID INTEGER PRIMARY KEY AUTOINCREMENT," \
      "STEP INTEGER NOT NULL," \
      "COREID INTEGER NOT NULL," \
      "MY_INDEX INTEGER NOT NULL," \
      "VALID INTEGER NOT NULL," \
      "SKIP INTEGER NOT NULL," \
      "ISRVC INTEGER NOT NULL," \
      "RFWEN INTEGER NOT NULL," \
      "FPWEN INTEGER NOT NULL," \
      "VECWEN INTEGER NOT NULL," \
      "V0WEN INTEGER NOT NULL," \
      "WPDEST INTEGER NOT NULL," \
      "WDEST INTEGER NOT NULL," \
      "OTHERWPDEST_0 INTEGER NOT NULL," \
      "OTHERWPDEST_1 INTEGER NOT NULL," \
      "OTHERWPDEST_2 INTEGER NOT NULL," \
      "OTHERWPDEST_3 INTEGER NOT NULL," \
      "OTHERWPDEST_4 INTEGER NOT NULL," \
      "OTHERWPDEST_5 INTEGER NOT NULL," \
      "OTHERWPDEST_6 INTEGER NOT NULL," \
      "OTHERWPDEST_7 INTEGER NOT NULL," \
      "OTHERWPDEST_8 INTEGER NOT NULL," \
      "OTHERWPDEST_9 INTEGER NOT NULL," \
      "OTHERWPDEST_10 INTEGER NOT NULL," \
      "OTHERWPDEST_11 INTEGER NOT NULL," \
      "OTHERWPDEST_12 INTEGER NOT NULL," \
      "OTHERWPDEST_13 INTEGER NOT NULL," \
      "OTHERWPDEST_14 INTEGER NOT NULL," \
      "OTHERWPDEST_15 INTEGER NOT NULL," \
      "PC INTEGER NOT NULL," \
      "INSTR INTEGER NOT NULL," \
      "ROBIDX INTEGER NOT NULL," \
      "LQIDX INTEGER NOT NULL," \
      "SQIDX INTEGER NOT NULL," \
      "ISLOAD INTEGER NOT NULL," \
      "ISSTORE INTEGER NOT NULL," \
      "NFUSED INTEGER NOT NULL," \
      "SPECIAL INTEGER NOT NULL);";
    const char* insertSql = "INSERT INTO InstrCommit (STEP,COREID,MY_INDEX,VALID,SKIP,ISRVC,RFWEN,FPWEN,VECWEN,V0WEN,WPDEST,WDEST,OTHERWPDEST_0,OTHERWPDEST_1,OTHERWPDEST_2,OTHERWPDEST_3,OTHERWPDEST_4,OTHERWPDEST_5,OTHERWPDEST_6,OTHERWPDEST_7,OTHERWPDEST_8,OTHERWPDEST_9,OTHERWPDEST_10,OTHERWPDEST_11,OTHERWPDEST_12,OTHERWPDEST_13,OTHERWPDEST_14,OTHERWPDEST_15,PC,INSTR,ROBIDX,LQIDX,SQIDX,ISLOAD,ISSTORE,NFUSED,SPECIAL) " \
      " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
    query_InstrCommit = new Query(mem_db, createSql, insertSql);
  }

  void PhyIntRegStateElem_init() {
    const char* createSql = " CREATE TABLE PhyIntRegStateElem(" \
      "ID INTEGER PRIMARY KEY AUTOINCREMENT," \
      "STEP INTEGER NOT NULL," \
      "COREID INTEGER NOT NULL," \
      "MY_INDEX INTEGER NOT NULL," \
      "DATA INTEGER NOT NULL);";
    const char* insertSql = "INSERT INTO PhyIntRegStateElem (STEP,COREID,MY_INDEX,DATA) " \
      " VALUES (?,?,?,?);";
    query_PhyIntRegStateElem = new Query(mem_db, createSql, insertSql);
  }

  void ArchIntRegState_init() {
    const char* createSql = " CREATE TABLE ArchIntRegState(" \
      "ID INTEGER PRIMARY KEY AUTOINCREMENT," \
      "STEP INTEGER NOT NULL," \
      "COREID INTEGER NOT NULL," \
      "VALUE_0 INTEGER NOT NULL," \
      "VALUE_1 INTEGER NOT NULL," \
      "VALUE_2 INTEGER NOT NULL," \
      "VALUE_3 INTEGER NOT NULL," \
      "VALUE_4 INTEGER NOT NULL," \
      "VALUE_5 INTEGER NOT NULL," \
      "VALUE_6 INTEGER NOT NULL," \
      "VALUE_7 INTEGER NOT NULL," \
      "VALUE_8 INTEGER NOT NULL," \
      "VALUE_9 INTEGER NOT NULL," \
      "VALUE_10 INTEGER NOT NULL," \
      "VALUE_11 INTEGER NOT NULL," \
      "VALUE_12 INTEGER NOT NULL," \
      "VALUE_13 INTEGER NOT NULL," \
      "VALUE_14 INTEGER NOT NULL," \
      "VALUE_15 INTEGER NOT NULL," \
      "VALUE_16 INTEGER NOT NULL," \
      "VALUE_17 INTEGER NOT NULL," \
      "VALUE_18 INTEGER NOT NULL," \
      "VALUE_19 INTEGER NOT NULL," \
      "VALUE_20 INTEGER NOT NULL," \
      "VALUE_21 INTEGER NOT NULL," \
      "VALUE_22 INTEGER NOT NULL," \
      "VALUE_23 INTEGER NOT NULL," \
      "VALUE_24 INTEGER NOT NULL," \
      "VALUE_25 INTEGER NOT NULL," \
      "VALUE_26 INTEGER NOT NULL," \
      "VALUE_27 INTEGER NOT NULL," \
      "VALUE_28 INTEGER NOT NULL," \
      "VALUE_29 INTEGER NOT NULL," \
      "VALUE_30 INTEGER NOT NULL," \
      "VALUE_31 INTEGER NOT NULL);";
    const char* insertSql = "INSERT INTO ArchIntRegState (STEP,COREID,VALUE_0,VALUE_1,VALUE_2,VALUE_3,VALUE_4,VALUE_5,VALUE_6,VALUE_7,VALUE_8,VALUE_9,VALUE_10,VALUE_11,VALUE_12,VALUE_13,VALUE_14,VALUE_15,VALUE_16,VALUE_17,VALUE_18,VALUE_19,VALUE_20,VALUE_21,VALUE_22,VALUE_23,VALUE_24,VALUE_25,VALUE_26,VALUE_27,VALUE_28,VALUE_29,VALUE_30,VALUE_31) " \
      " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
    query_ArchIntRegState = new Query(mem_db, createSql, insertSql);
  }

  void CSRStateElem_init() {
    const char* createSql = " CREATE TABLE CSRStateElem(" \
      "ID INTEGER PRIMARY KEY AUTOINCREMENT," \
      "STEP INTEGER NOT NULL," \
      "COREID INTEGER NOT NULL," \
      "MY_INDEX INTEGER NOT NULL," \
      "DATA INTEGER NOT NULL);";
    const char* insertSql = "INSERT INTO CSRStateElem (STEP,COREID,MY_INDEX,DATA) " \
      " VALUES (?,?,?,?);";
    query_CSRStateElem = new Query(mem_db, createSql, insertSql);
  }

  void DeltaInfo_init() {
    const char* createSql = " CREATE TABLE DeltaInfo(" \
      "ID INTEGER PRIMARY KEY AUTOINCREMENT," \
      "STEP INTEGER NOT NULL," \
      "COREID INTEGER NOT NULL," \
      "VALID INTEGER NOT NULL);";
    const char* insertSql = "INSERT INTO DeltaInfo (STEP,COREID,VALID) " \
      " VALUES (?,?,?);";
    query_DeltaInfo = new Query(mem_db, createSql, insertSql);
  }

  
  void ArchEvent_write(int dut_zone, uint8_t coreid, DifftestArchEvent* packet) {
    query_ArchEvent->write(11, query_step + (query_zone != 0), coreid, packet->valid, packet->interrupt, packet->exception, packet->exceptionPC, packet->exceptionInst, packet->hasNMI, packet->virtualInterruptIsHvictlInject, packet->irToHS, packet->irToVS);
  }

  void TrapEvent_write(int dut_zone, uint8_t coreid, DifftestTrapEvent* packet) {
    query_TrapEvent->write(8, query_step + (query_zone != 0), coreid, packet->hasTrap, packet->cycleCnt, packet->instrCnt, packet->hasWFI, packet->code, packet->pc);
  }

  void InstrCommit_write(int dut_zone, uint8_t coreid, uint8_t index, DifftestInstrCommit* packet) {
    query_InstrCommit->write(37, query_step + (query_zone != 0), coreid, index, packet->valid, packet->skip, packet->isRVC, packet->rfwen, packet->fpwen, packet->vecwen, packet->v0wen, packet->wpdest, packet->wdest, packet->otherwpdest[0], packet->otherwpdest[1], packet->otherwpdest[2], packet->otherwpdest[3], packet->otherwpdest[4], packet->otherwpdest[5], packet->otherwpdest[6], packet->otherwpdest[7], packet->otherwpdest[8], packet->otherwpdest[9], packet->otherwpdest[10], packet->otherwpdest[11], packet->otherwpdest[12], packet->otherwpdest[13], packet->otherwpdest[14], packet->otherwpdest[15], packet->pc, packet->instr, packet->robIdx, packet->lqIdx, packet->sqIdx, packet->isLoad, packet->isStore, packet->nFused, packet->special);
  }

  void PhyIntRegStateElem_write(int dut_zone, uint8_t coreid, uint8_t index, uint64_t* packet) {
    query_PhyIntRegStateElem->write(4, query_step + (query_zone != 0), coreid, index, *packet);
  }

  void ArchIntRegState_write(uint8_t coreid, DiffTestState* dut) {
    query_ArchIntRegState->write(34, (int)query_step, coreid, dut->regs.xrf.value[0], dut->regs.xrf.value[1], dut->regs.xrf.value[2], dut->regs.xrf.value[3], dut->regs.xrf.value[4], dut->regs.xrf.value[5], dut->regs.xrf.value[6], dut->regs.xrf.value[7], dut->regs.xrf.value[8], dut->regs.xrf.value[9], dut->regs.xrf.value[10], dut->regs.xrf.value[11], dut->regs.xrf.value[12], dut->regs.xrf.value[13], dut->regs.xrf.value[14], dut->regs.xrf.value[15], dut->regs.xrf.value[16], dut->regs.xrf.value[17], dut->regs.xrf.value[18], dut->regs.xrf.value[19], dut->regs.xrf.value[20], dut->regs.xrf.value[21], dut->regs.xrf.value[22], dut->regs.xrf.value[23], dut->regs.xrf.value[24], dut->regs.xrf.value[25], dut->regs.xrf.value[26], dut->regs.xrf.value[27], dut->regs.xrf.value[28], dut->regs.xrf.value[29], dut->regs.xrf.value[30], dut->regs.xrf.value[31]);
  }

  void CSRStateElem_write(int dut_zone, uint8_t coreid, uint8_t index, uint64_t* packet) {
    query_CSRStateElem->write(4, query_step + (query_zone != 0), coreid, index, *packet);
  }

  void DeltaInfo_write(int dut_zone, uint8_t coreid, DifftestDeltaInfo* packet) {
    query_DeltaInfo->write(3, query_step + (query_zone != 0), coreid, packet->valid);
  }

  
  void BatchTable_init() {
    const char* createBatchInfoSql = "CREATE TABLE BatchInfo("
      "ID INTEGER PRIMARY KEY AUTOINCREMENT,"
      "STEP INTEGER NOT NULL,"
      "BUNDLE_ID INTEGER NOT NULL,"
      "NUM INTEGER NOT NULL);";
    const char* insertBatchInfoSql = "INSERT INTO BatchInfo (STEP,BUNDLE_ID,NUM)"
      " VALUES (?,?,?);";
    query_BatchInfo = new Query(mem_db, createBatchInfoSql, insertBatchInfoSql);

    const char* createBundleNamesSql = "CREATE TABLE BundleNames("
      "BUNDLE_ID INTEGER PRIMARY KEY,"
      "NAME TEXT NOT NULL);";
    char* errMsg;
    sqlite3_exec(mem_db, createBundleNamesSql, 0, 0, &errMsg);
    sqlite3_exec(mem_db, "INSERT INTO BundleNames VALUES(0, 'ArchEvent');INSERT INTO BundleNames VALUES(1, 'TrapEvent');INSERT INTO BundleNames VALUES(2, 'InstrCommit');INSERT INTO BundleNames VALUES(3, 'PhyIntRegStateElem');INSERT INTO BundleNames VALUES(4, 'CSRStateElem');INSERT INTO BundleNames VALUES(5, 'DeltaInfo');INSERT INTO BundleNames VALUES(6, 'BatchHead');INSERT INTO BundleNames VALUES(7, 'BatchStep');", 0, 0, &errMsg);

    const char* createBatchStepSql = "CREATE TABLE BatchStep("
      "ID INTEGER PRIMARY KEY AUTOINCREMENT,"
      "STEP INTEGER NOT NULL,"
      "ArchEvent INTEGER NOT NULL,TrapEvent INTEGER NOT NULL,InstrCommit INTEGER NOT NULL,PhyIntRegStateElem INTEGER NOT NULL,CSRStateElem INTEGER NOT NULL,DeltaInfo INTEGER NOT NULL,BatchHead INTEGER NOT NULL,BatchStep INTEGER NOT NULL);";
    const char* insertBatchStepSql = "INSERT INTO BatchStep (STEP,ArchEvent,TrapEvent,InstrCommit,PhyIntRegStateElem,CSRStateElem,DeltaInfo,BatchHead,BatchStep) "
      "VALUES (?,?,?,?,?,?,?,?,?);";
    query_BatchStep = new Query(mem_db, createBatchStepSql, insertBatchStepSql);
  }

  
  void BatchInfo_write(int bundle_id, int num) {
    query_BatchInfo->write(3, (int)query_step, bundle_id, num);
  }
  void BatchStep_write(int* nums) {
    query_BatchStep->write(9, (int)query_step, nums[0], nums[1], nums[2], nums[3], nums[4], nums[5], nums[6], nums[7]);
  }

};
#endif // CONFIG_DIFFTEST_QUERY
#endif // __DIFFTEST_QUERY_H__

