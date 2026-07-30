config_hw -create_board_instance 1

# The layout of U2 is:
#     A   A   A   A   A   A   A   A   A   A   A   A       A   A   A   A   A   A   A   A   A   A   A   A   
#     P   P   P   P   P   P   P   P   P   P   P   P       P   P   P   P   P   P   P   P   P   P   P   P   
#     C   C   C   C   C   C   C   C   C   C   C   C       C   C   C   C   C   C   C   C   C   C   C   C   
#     0   1   2   3   4   5   6   7   8   9   10  11      0   1   2   3   4   5   6   7   8   9   10  11  
#     
#         FMC1                                FMC2            FMC1                                FMC2    
#                                                                                                         
#                         F2                                                      F3                      
#                                                                                                         
#         FMC0                                FMC3            FMC0                                FMC3    
#                                                                                                         
#     A   A   A   A   A   A   A   A   A   A   A   A       A   A   A   A   A   A   A   A   A   A   A   A   
#     P   P   P   P   P   P   P   P   P   P   P   P       P   P   P   P   P   P   P   P   P   P   P   P   
#     C   C   C   C   C   C   C   C   C   C   C   C       C   C   C   C   C   C   C   C   C   C   C   C   
#     23  22  21  20  19  18  17  16  15  14  13  12      23  22  21  20  19  18  17  16  15  14  13  12  
#     
#     A   A   A   A   A   A   A   A   A   A   A   A       A   A   A   A   A   A   A   A   A   A   A   A   
#     P   P   P   P   P   P   P   P   P   P   P   P       P   P   P   P   P   P   P   P   P   P   P   P  
#     C   C   C   C   C   C   C   C   C   C   C   C       C   C   C   C   C   C   C   C   C   C   C   C
#     12  13  14  15  16  17  18  19  20  21  22  23      12  13  14  15  16  17  18  19  20  21  22  23
#     
#         FMC3                                FMC0            FMC3                                FMC0
#     
#                         F1                                                      F0
#     
#         FMC2                                FMC1            FMC2                                FMC1
#     
#     A   A   A   A   A   A   A   A   A   A   A   A       A   A   A   A   A   A   A   A   A   A   A   A
#     P   P   P   P   P   P   P   P   P   P   P   P       P   P   P   P   P   P   P   P   P   P   P   P  
#     C   C   C   C   C   C   C   C   C   C   C   C       C   C   C   C   C   C   C   C   C   C   C   C
#     11  10  9   8   7   6   5   4   3   2   1   0       11  10  9   8   7   6   5   4   3   2   1   0

#config_hw -allocate_board {b0}

#config_hw -unplug_fpga b0.f0
#config_hw -unplug_fpga b0.f1
#config_hw -unplug_fpga b0.f2
config_hw -unplug_fpga b0.f3
    
# ddr4 for UHD in U2
config_hw -create_daughter_card UV_FMCH_PDDR4DME -instance pddr4dme_inst0
config_hw -connect_daughter_card {b0.F0_FMC3 pddr4dme_inst0.FMC}
config_hw -create_daughter_card UV_FMCH_PDDR4DME -instance pddr4dme_inst1
config_hw -connect_daughter_card {b0.F1_FMC3 pddr4dme_inst1.FMC}
config_hw -create_daughter_card UV_FMCH_PDDR4DME -instance pddr4dme_inst2
config_hw -connect_daughter_card {b0.F2_FMC3 pddr4dme_inst2.FMC}
config_hw -create_daughter_card UV_FMCH_PDDR4DME -instance pddr4dme_inst3
config_hw -connect_daughter_card {b0.F3_FMC3 pddr4dme_inst3.FMC}

config_hw -create_daughter_card UV_FMCH_PDDR4DME -instance pddr4dme_user_inst
config_hw -connect_daughter_card {b0.F0_FMC0 pddr4dme_user_inst.FMC}
config_hw -create_daughter_card UV_FMCH_FLASH -instance flash_inst
config_hw -connect_daughter_card {b0.F1_FMC0 flash_inst.FMC}
#config_hw -create_daughter_card UV_MEM_ARRAY_F -instance mem_adpt_inst0
#config_hw -connect_daughter_card {b0.F0_FMC1 mem_adpt_inst0.FMC}
#config_hw -create_daughter_card UV_MEM_ARRAY_F -instance mem_adpt_inst1
#config_hw -connect_daughter_card {b0.F1_FMC1 mem_adpt_inst1.FMC}
#config_hw -create_daughter_card UV_MEM_ADPT -instance mem_adpt_inst2
#config_hw -connect_daughter_card {b0.F2_FMC1 mem_adpt_inst2.FMC}
#config_hw -create_daughter_card UV_MEM_ADPT -instance mem_adpt_inst3
#config_hw -connect_daughter_card {b0.F3_FMC1 mem_adpt_inst3.FMC}

# connection FMC between the same FPGA
#config_hw -connect_fpga {b0.F0_FMC1 b0.F1_FMC2} -obu_mode normal -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_FMC2 b0.F2_FMC0} -obu_mode normal -cable UV_IOC_500
#config_hw -connect_fpga {b0.F0_FMC0 b0.F3_FMC2} -obu_mode normal -cable UV_IOC_500
#config_hw -connect_fpga {b0.F1_FMC0 b0.F2_FMC2} -obu_mode normal -cable UV_IOC_500
#config_hw -connect_fpga {b0.F1_FMC1 b0.F3_FMC0} -obu_mode normal -cable UV_IOC_500
config_hw -connect_fpga {b0.F2_FMC1 b0.F3_FMC1} -obu_mode normal -cable UV_IOC_500

# connection APC between the same board
config_hw -connect_fpga {b0.F0_APC0 b0.F1_APC4} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC1 b0.F1_APC5} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC2 b0.F1_APC6} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC3 b0.F1_APC7} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC4 b0.F1_APC8} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC5 b0.F1_APC9} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC6 b0.F1_APC10} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC7 b0.F1_APC11} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC8 b0.F2_APC12} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC9 b0.F2_APC13} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC10 b0.F2_APC14} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC11 b0.F2_APC15} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC12 b0.F2_APC8} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC13 b0.F2_APC9} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC14 b0.F2_APC10} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC15 b0.F2_APC11} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC16 b0.F3_APC4} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC17 b0.F3_APC5} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC18 b0.F3_APC6} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC19 b0.F3_APC7} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC20 b0.F3_APC8} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC21 b0.F3_APC9} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC22 b0.F3_APC10} -cable UV_IOC_500
config_hw -connect_fpga {b0.F0_APC23 b0.F3_APC11} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC12 b0.F2_APC0} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC13 b0.F2_APC1} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC14 b0.F2_APC2} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC15 b0.F2_APC3} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC16 b0.F2_APC4} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC17 b0.F2_APC5} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC18 b0.F2_APC6} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC19 b0.F2_APC7} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC0 b0.F3_APC20} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC1 b0.F3_APC21} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC2 b0.F3_APC22} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC3 b0.F3_APC23} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC20 b0.F3_APC0} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC21 b0.F3_APC1} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC22 b0.F3_APC2} -cable UV_IOC_500
config_hw -connect_fpga {b0.F1_APC23 b0.F3_APC3} -cable UV_IOC_500
#config_hw -connect_fpga {b0.F2_APC16 b0.F3_APC12} -cable UV_IOC_500
config_hw -connect_fpga {b0.F2_APC17 b0.F3_APC13} -cable UV_IOC_500
config_hw -connect_fpga {b0.F2_APC18 b0.F3_APC14} -cable UV_IOC_500
config_hw -connect_fpga {b0.F2_APC19 b0.F3_APC15} -cable UV_IOC_500
config_hw -connect_fpga {b0.F2_APC20 b0.F3_APC16} -cable UV_IOC_500
config_hw -connect_fpga {b0.F2_APC21 b0.F3_APC17} -cable UV_IOC_500
config_hw -connect_fpga {b0.F2_APC22 b0.F3_APC18} -cable UV_IOC_500
config_hw -connect_fpga {b0.F2_APC23 b0.F3_APC19} -cable UV_IOC_500

# connection HGC between the same board
config_hw -connect_fpga {b0.F0_HGC0 b0.F1_HGC0} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F0_HGC1 b0.F1_HGC1} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F0_HGC2 b0.F1_HGC2} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F0_HGC3 b0.F2_HGC0} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F0_HGC4 b0.F2_HGC1} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F0_HGC5 b0.F3_HGC0} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F0_HGC6 b0.F3_HGC1} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F0_HGC7 b0.F3_HGC2} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F1_HGC3 b0.F2_HGC2} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F1_HGC4 b0.F2_HGC3} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F1_HGC5 b0.F2_HGC4} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F1_HGC6 b0.F3_HGC3} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F1_HGC7 b0.F3_HGC4} -cable UV_HGC_1000
config_hw -connect_fpga {b0.F2_HGC5 b0.F3_HGC5} -cable UV_HGC_1000
#config_hw -connect_fpga {b0.F2_HGC6 b0.F3_HGC6} -cable UV_HGC_1000
#config_hw -connect_fpga {b0.F2_HGC7 b0.F3_HGC7} -cable UV_HGC_1000

# connection HGC between the diff board

# Here is the statistics of DC used.
# DCs used:
## Number of UV_FMCH_PDDR4DME is 4

# Here is the statistics of cable used.
# Cables used in FMC connection:
## Number of UV_IOC_500 is 6*3 = 18
# Cables used in APC connection:
## Number of UV_IOC_500 is 48
# Cables used in HGC connection:
## Number of UV_HGC_1000 is 16
# Cables used in CLKHUB connection:
## No ClockHub connection
# Total cable number is 82.

# assemble and report
config_hw -assemble
config_hw -report
