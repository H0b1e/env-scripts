#################################################################
#set pin assignment
#################################################################
# Uart
assign_pin  uart0_sout -connector b0.F1_FMC0 -index  311
assign_pin  uart0_sin -connector b0.F1_FMC0 -index  270


# F2 APC16 sideband I/O. rstn_sw* are UVHS global reset ports and do not
# require assign_pin constraints.
# Stage 01: LED status outputs are intentionally left unconnected at the
# staged top level, so their board pin assignments are removed.
# Stage 03: the inactive SD interface is removed from the staged top level.
assign_pin -port {pcie_ep_lnk_up} -connector b0.F2_APC16 -index 58

#pcie sys clk
#assign_pin -port {pcie_ep_gt_ref_clk_p} -connector b0.F0_GTYREFC_P -index 10
#assign_pin -port {pcie_ep_gt_ref_clk_n} -connector b0.F0_GTYREFC_N -index 11

###add by songbinghao pcie ep refclk###
assign_pin -port {pcie_ep_gt_ref_clk_p} -connector b0.F2_HGC7 -index 29
assign_pin -port {pcie_ep_gt_ref_clk_n} -connector b0.F2_HGC7 -index 30
#refclk1
###add by songbinghao pcie ep###
assign_pin -port {pci_ep_rxp[0]} -connector b0.F2_HGC7 -index 16
assign_pin -port {pci_ep_rxn[0]} -connector b0.F2_HGC7 -index 17
assign_pin -port {pci_ep_rxp[1]} -connector b0.F2_HGC7 -index 13
assign_pin -port {pci_ep_rxn[1]} -connector b0.F2_HGC7 -index 14
assign_pin -port {pci_ep_rxp[2]} -connector b0.F2_HGC7 -index 4
assign_pin -port {pci_ep_rxn[2]} -connector b0.F2_HGC7 -index 5
assign_pin -port {pci_ep_rxp[3]} -connector b0.F2_HGC7 -index 1
assign_pin -port {pci_ep_rxn[3]} -connector b0.F2_HGC7 -index 2
#assign_pin -port {pci_ep_rxp[4]} -connector b0.F2_HGC6 -index 16
#assign_pin -port {pci_ep_rxn[4]} -connector b0.F2_HGC6 -index 17
#assign_pin -port {pci_ep_rxp[5]} -connector b0.F2_HGC6 -index 13
#assign_pin -port {pci_ep_rxn[5]} -connector b0.F2_HGC6 -index 14
#assign_pin -port {pci_ep_rxp[6]} -connector b0.F2_HGC6 -index 4
#assign_pin -port {pci_ep_rxn[6]} -connector b0.F2_HGC6 -index 5
#assign_pin -port {pci_ep_rxp[7]} -connector b0.F2_HGC6 -index 1
#assign_pin -port {pci_ep_rxn[7]} -connector b0.F2_HGC6 -index 2

assign_pin -port {pci_ep_txp[0]} -connector b0.F2_HGC7 -index 35
assign_pin -port {pci_ep_txn[0]} -connector b0.F2_HGC7 -index 36
assign_pin -port {pci_ep_txp[1]} -connector b0.F2_HGC7 -index 32
assign_pin -port {pci_ep_txn[1]} -connector b0.F2_HGC7 -index 33
assign_pin -port {pci_ep_txp[2]} -connector b0.F2_HGC7 -index 23
assign_pin -port {pci_ep_txn[2]} -connector b0.F2_HGC7 -index 24
assign_pin -port {pci_ep_txp[3]} -connector b0.F2_HGC7 -index 20
assign_pin -port {pci_ep_txn[3]} -connector b0.F2_HGC7 -index 21
#assign_pin -port {pci_ep_txp[4]} -connector b0.F2_HGC6 -index 35
#assign_pin -port {pci_ep_txn[4]} -connector b0.F2_HGC6 -index 36
#assign_pin -port {pci_ep_txp[5]} -connector b0.F2_HGC6 -index 32
#assign_pin -port {pci_ep_txn[5]} -connector b0.F2_HGC6 -index 33
#assign_pin -port {pci_ep_txp[6]} -connector b0.F2_HGC6 -index 23
#assign_pin -port {pci_ep_txn[6]} -connector b0.F2_HGC6 -index 24
#assign_pin -port {pci_ep_txp[7]} -connector b0.F2_HGC6 -index 20
#assign_pin -port {pci_ep_txn[7]} -connector b0.F2_HGC6 -index 21
assign_pin -port {pcie_ep_perstn}      -connector b0.F2_APC16 -index 118
####
#assign_pin -port {DDR0_DQ[0]}   -connector b0.F0_FMC0	  -index 263		
#assign_pin -port {DDR0_DQ[1]}   -connector b0.F0_FMC0	  -index 101		
#assign_pin -port {DDR0_DQ[2]}   -connector b0.F0_FMC0	  -index 301		
#assign_pin -port {DDR0_DQ[3]}   -connector b0.F0_FMC0	  -index 305		
#assign_pin -port {DDR0_DQ[4]}   -connector b0.F0_FMC0	  -index 304		
#assign_pin -port {DDR0_DQ[5]}   -connector b0.F0_FMC0     -index 102		
#assign_pin -port {DDR0_DQ[6]}   -connector b0.F0_FMC0     -index 302		
#assign_pin -port {DDR0_DQ[7]}   -connector b0.F0_FMC0     -index 264		
#assign_pin -port {DDR0_DQ[8]}   -connector b0.F0_FMC0     -index 307		
#assign_pin -port {DDR0_DQ[9]}   -connector b0.F0_FMC0     -index 105		
#assign_pin -port {DDR0_DQ[10]}  -connector b0.F0_FMC0     -index 267		
#assign_pin -port {DDR0_DQ[11]}  -connector b0.F0_FMC0     -index 310		
#assign_pin -port {DDR0_DQ[12]}  -connector b0.F0_FMC0     -index 311		
#assign_pin -port {DDR0_DQ[13]}  -connector b0.F0_FMC0     -index 106		
#assign_pin -port {DDR0_DQ[14]}  -connector b0.F0_FMC0     -index 308		
#assign_pin -port {DDR0_DQ[15]}  -connector b0.F0_FMC0     -index 266		
#assign_pin -port {DDR0_DQ[16]}  -connector b0.F0_FMC0     -index 257		
#assign_pin -port {DDR0_DQ[17]}  -connector b0.F0_FMC0     -index 136		
#assign_pin -port {DDR0_DQ[18]}  -connector b0.F0_FMC0     -index 254		
#assign_pin -port {DDR0_DQ[19]}  -connector b0.F0_FMC0     -index 258		
#assign_pin -port {DDR0_DQ[20]}  -connector b0.F0_FMC0     -index 298		
#assign_pin -port {DDR0_DQ[21]}  -connector b0.F0_FMC0     -index 137		
#assign_pin -port {DDR0_DQ[22]}  -connector b0.F0_FMC0     -index 255		
#assign_pin -port {DDR0_DQ[23]}  -connector b0.F0_FMC0     -index 299		
#assign_pin -port {DDR0_DQ[24]}  -connector b0.F0_FMC0     -index 181		
#assign_pin -port {DDR0_DQ[25]}  -connector b0.F0_FMC0     -index 225		
#assign_pin -port {DDR0_DQ[26]}  -connector b0.F0_FMC0     -index 388		
#assign_pin -port {DDR0_DQ[27]}  -connector b0.F0_FMC0     -index 387		
#assign_pin -port {DDR0_DQ[28]}  -connector b0.F0_FMC0     -index 180		
#assign_pin -port {DDR0_DQ[29]}  -connector b0.F0_FMC0     -index 346		
#assign_pin -port {DDR0_DQ[30]}  -connector b0.F0_FMC0     -index 347		
#assign_pin -port {DDR0_DQ[31]}  -connector b0.F0_FMC0     -index 224		
#assign_pin -port {DDR0_DQ[32]}  -connector b0.F0_FMC0     -index 177		
#assign_pin -port {DDR0_DQ[33]}  -connector b0.F0_FMC0     -index 178		
#assign_pin -port {DDR0_DQ[34]}  -connector b0.F0_FMC0     -index 338		
#assign_pin -port {DDR0_DQ[35]}  -connector b0.F0_FMC0     -index 375		
#assign_pin -port {DDR0_DQ[36]}  -connector b0.F0_FMC0     -index 337		
#assign_pin -port {DDR0_DQ[37]}  -connector b0.F0_FMC0     -index 379		
#assign_pin -port {DDR0_DQ[38]}  -connector b0.F0_FMC0     -index 378		
#assign_pin -port {DDR0_DQ[39]}  -connector b0.F0_FMC0     -index 376		
#assign_pin -port {DDR0_DQ[40]}  -connector b0.F0_FMC0     -index 216		
#assign_pin -port {DDR0_DQ[41]}  -connector b0.F0_FMC0     -index 334		
#assign_pin -port {DDR0_DQ[42]}  -connector b0.F0_FMC0     -index 213		
#assign_pin -port {DDR0_DQ[43]}  -connector b0.F0_FMC0     -index 212		
#assign_pin -port {DDR0_DQ[44]}  -connector b0.F0_FMC0     -index 215		
#assign_pin -port {DDR0_DQ[45]}  -connector b0.F0_FMC0     -index 335		
#assign_pin -port {DDR0_DQ[46]}  -connector b0.F0_FMC0     -index 332		
#assign_pin -port {DDR0_DQ[47]}  -connector b0.F0_FMC0     -index 331		
#assign_pin -port {DDR0_DQ[48]}  -connector b0.F0_FMC0     -index 292		
#assign_pin -port {DDR0_DQ[49]}  -connector b0.F0_FMC0     -index 295		
#assign_pin -port {DDR0_DQ[50]}  -connector b0.F0_FMC0     -index 94		
#assign_pin -port {DDR0_DQ[51]}  -connector b0.F0_FMC0     -index 251		
#assign_pin -port {DDR0_DQ[52]}  -connector b0.F0_FMC0     -index 296		
#assign_pin -port {DDR0_DQ[53]}  -connector b0.F0_FMC0     -index 293		
#assign_pin -port {DDR0_DQ[54]}  -connector b0.F0_FMC0     -index 93		
#assign_pin -port {DDR0_DQ[55]}  -connector b0.F0_FMC0     -index 252		
#assign_pin -port {DDR0_DQ[56]}  -connector b0.F0_FMC0     -index 286		
#assign_pin -port {DDR0_DQ[57]}  -connector b0.F0_FMC0     -index 289		
#assign_pin -port {DDR0_DQ[58]}  -connector b0.F0_FMC0     -index 127		
#assign_pin -port {DDR0_DQ[59]}  -connector b0.F0_FMC0     -index 131		
#assign_pin -port {DDR0_DQ[60]}  -connector b0.F0_FMC0     -index 290		
#assign_pin -port {DDR0_DQ[61]}  -connector b0.F0_FMC0     -index 287		
#assign_pin -port {DDR0_DQ[62]}  -connector b0.F0_FMC0     -index 130		
#assign_pin -port {DDR0_DQ[63]}  -connector b0.F0_FMC0     -index 128		
#
#assign_pin -port {DDR0_DM[0]}	-connector b0.F0_FMC0	  -index 139		
#assign_pin -port {DDR0_DM[1]}	-connector b0.F0_FMC0 	  -index 142		
#assign_pin -port {DDR0_DM[2]}	-connector b0.F0_FMC0	  -index 283		
#assign_pin -port {DDR0_DM[3]}	-connector b0.F0_FMC0	  -index 221		
#assign_pin -port {DDR0_DM[4]}	-connector b0.F0_FMC0	  -index 174		
#assign_pin -port {DDR0_DM[5]}	-connector b0.F0_FMC0	  -index 372		
#assign_pin -port {DDR0_DM[6]}	-connector b0.F0_FMC0	  -index 89		
#assign_pin -port {DDR0_DM[7]}	-connector b0.F0_FMC0	  -index 245		
#
#assign_pin -port {DDR0_DQS_T[0]} -connector b0.F0_FMC0    -index 260		
#assign_pin -port {DDR0_DQS_T[1]} -connector b0.F0_FMC0	  -index 145		
#assign_pin -port {DDR0_DQS_T[2]} -connector b0.F0_FMC0	  -index 97		
#assign_pin -port {DDR0_DQS_T[3]} -connector b0.F0_FMC0	  -index 183		
#assign_pin -port {DDR0_DQS_T[4]} -connector b0.F0_FMC0	  -index 218		
#assign_pin -port {DDR0_DQS_T[5]} -connector b0.F0_FMC0	  -index 171		
#assign_pin -port {DDR0_DQS_T[6]} -connector b0.F0_FMC0	  -index 133		
#assign_pin -port {DDR0_DQS_T[7]} -connector b0.F0_FMC0	  -index 248		
#
#assign_pin -port {DDR0_DQS_C[0]} -connector b0.F0_FMC0	  -index 261	
#assign_pin -port {DDR0_DQS_C[1]} -connector b0.F0_FMC0    -index 146	
#assign_pin -port {DDR0_DQS_C[2]} -connector b0.F0_FMC0    -index 98	
#assign_pin -port {DDR0_DQS_C[3]} -connector b0.F0_FMC0    -index 184	
#assign_pin -port {DDR0_DQS_C[4]} -connector b0.F0_FMC0    -index 219	
#assign_pin -port {DDR0_DQS_C[5]} -connector b0.F0_FMC0    -index 172	
#assign_pin -port {DDR0_DQS_C[6]} -connector b0.F0_FMC0    -index 134	
#assign_pin -port {DDR0_DQS_C[7]} -connector b0.F0_FMC0    -index 249	
#assign_pin -port DDR0_CK_T 	-connector b0.F0_FMC0		-index 269	
#assign_pin -port DDR0_CK_C	-connector b0.F0_FMC0		-index 270		
#assign_pin -port {DDR0_A[0]}	-connector b0.F0_FMC0		-index 275		
#assign_pin -port {DDR0_A[1]}	-connector b0.F0_FMC0		-index 391		
#assign_pin -port {DDR0_A[2]}	-connector b0.F0_FMC0		-index 276		
#assign_pin -port {DDR0_A[3]}	-connector b0.F0_FMC0		-index 273		
#assign_pin -port {DDR0_A[4]}	-connector b0.F0_FMC0		-index 317		
#assign_pin -port {DDR0_A[5]}	-connector b0.F0_FMC0		-index 316		
#assign_pin -port {DDR0_A[6]}	-connector b0.F0_FMC0		-index 390		
#assign_pin -port {DDR0_A[7]}	-connector b0.F0_FMC0		-index 369		
#assign_pin -port {DDR0_A[8]}	-connector b0.F0_FMC0		-index 272		
#assign_pin -port {DDR0_A[9]}	-connector b0.F0_FMC0		-index 370		
#assign_pin -port {DDR0_A[10]}	-connector b0.F0_FMC0		-index 326		
#assign_pin -port {DDR0_A[11]}	-connector b0.F0_FMC0		-index 207		
#assign_pin -port {DDR0_A[12]}	-connector b0.F0_FMC0		-index 168		
#assign_pin -port {DDR0_A[13]}	-connector b0.F0_FMC0		-index 203		
#assign_pin -port {DDR0_A[14]}	-connector b0.F0_FMC0		-index 166		
#assign_pin -port {DDR0_A[15]}	-connector b0.F0_FMC0		-index 162		
#assign_pin -port {DDR0_A[16]}	-connector b0.F0_FMC0		-index 204		
#assign_pin -port {DDR0_BA[0]}	-connector b0.F0_FMC0		-index 161		
#assign_pin -port {DDR0_BA[1]}	-connector b0.F0_FMC0		-index 367		
#assign_pin -port {DDR0_BG[0]}	-connector b0.F0_FMC0	        -index 209		
#assign_pin -port {DDR0_BG[1]}	-connector b0.F0_FMC0		-index 210		
##assign_pin -port DDR0_RESET_N	-connector b0.F0_FMC0		-index 227		
#assign_pin -port DDR0_RESET_N	-connector b0.F0_FMC0		-index 227 -attribute {DRIVE:8}		
#assign_pin -port DDR0_CKE	-connector b0.F0_FMC0		-index 169		
#assign_pin -port DDR0_CS_N	-connector b0.F0_FMC0		-index 165		
#assign_pin -port DDR0_ODT	-connector b0.F0_FMC0		-index 325		
#assign_pin -port DDR0_ACT_N	-connector b0.F0_FMC0		-index 328		
#assign_pin -port clk7_p		-connector b0.F0_FMC0		-index 241		
#assign_pin -port clk7_n		-connector b0.F0_FMC0		-index 242		
#
##set_property DRIVE 8 [get_ports DDR0_RESET_N]
##set_property DRIVE 8 [get_ports xs_fpga_top_debug.DDR0_RESET_N]
#
