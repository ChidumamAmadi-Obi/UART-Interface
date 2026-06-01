

# debug flags
RTL_DEBUG_FLAGS ?= -Wno-WIDTHEXPAND
TB_DEBUG_FLAGS ?=  $(RTL_DEBUG_FLAGS) -Wno-WIDTHTRUNC

#directories
RTL_DIR = rtl
TB_DIR = tb
OBJ_DIR = obj_dir

# executables ************************
# rtl executables
TOP_RTL_EXEC = ./$(OBJ_DIR)/Vtop
TX_RTL_EXEC = ./$(OBJ_DIR)/Vtx_uart
RX_RTL_EXEC = ./$(OBJ_DIR)/Vrx_uart

# tb executalbes
TOP_TB_EXEC = ./$(OBJ_DIR)/Vtop_tb
TX_TB_EXEC = ./$(OBJ_DIR)/Vtx_tb
RX_TB_EXEC = ./$(OBJ_DIR)/Vrx_tb

# ***************************************************************************************************

# lint only rtl modules
lint-rtl-top:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DEBUG_FLAGS) $(RTL_DIR)/top.v --top top
lint-rtl-rx:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DEBUG_FLAGS) $(RTL_DIR)/rx_uart.v --top rx_uart
lint-rtl-tx:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DEBUG_FLAGS) $(RTL_DIR)/tx_uart.v --top tx_uart

# run tbs
run-tb-top:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DEBUG_FLAGS) $(RTL_DIR)/top.v $(TB_DIR)/top_tb.sv --top top_tb
	$(TOP_TB_EXEC)
run-tb-rx:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DEBUG_FLAGS) $(RTL_DIR)/rx_uart.v $(TB_DIR)/rx_tb.sv --top rx_tb
	$(RX_TB_EXEC)
run-tb-tx:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DEBUG_FLAGS) $(RTL_DIR)/tx_uart.v $(TB_DIR)/tx_tb.sv --top tx_tb
	$(TX_TB_EXEC)

clean: # remove generated stuff
	rm $(OBJ_DIR)/*

