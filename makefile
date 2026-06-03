# makefile to do stuff with verilator easier

# warning diable
RTL_DISABLE_WARNING ?= -Wno-WIDTHEXPAND
TB_DISABLE_WARNING ?=  $(RTL_DISABLE_WARNING) -Wno-WIDTHTRUNC

# source files ***********************
# rtl
TOP_RTL_SRC = top
TX_RTL_SRC = tx_uart
RX_RTL_SRC = rx_uart

# tbs
TOP_TB_SRC = top_tb
TX_TB_SRC = tx_tb
RX_TB_SRC = rx_tb

# directories
RTL_DIR = rtl
TB_DIR = tb
OBJ_DIR = obj_dir

# executables ************************
# rtl executables
TOP_RTL_EXEC = ./$(OBJ_DIR)/V$(TOP_RTL_SRC)
TX_RTL_EXEC = ./$(OBJ_DIR)/V$(TX_RTL_SRC)
RX_RTL_EXEC = ./$(OBJ_DIR)/V$(RX_RTL_SRC)

# tb executalbes
TOP_TB_EXEC = ./$(OBJ_DIR)/V$(TOP_TB_SRC)
TX_TB_EXEC = ./$(OBJ_DIR)/V$(TX_TB_SRC)
RX_TB_EXEC = ./$(OBJ_DIR)/V$(RX_TB_SRC)

# ***************************************************************************************************
help: # shows message
	@echo  MAKEFILE TARGETS:
	@echo  - lint-rtl
	@echo  - lint-rtl-tx
	@echo  - lint-rtl-rx
	@echo  - run-tb-top
	@echo  - run-tb-tx
	@echo  - run-tb-rx
	@echo  - clean
	@echo  - help

# lint only rtl modules
lint-rtl:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(TOP_RTL_SRC).v --top top
lint-rtl-rx:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(RX_RTL_SRC).v --top rx_uart
lint-rtl-tx:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(TX_RTL_SRC).v --top tx_uart

# run tbs
run-tb-top:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(TOP_RTL_SRC).v $(TB_DIR)/$(TOP_TB_SRC).sv --top top_tb
	$(TOP_TB_EXEC)
run-tb-rx:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(RX_RTL_SRC).v $(TB_DIR)/$(RX_TB_SRC).sv --top rx_tb
	$(RX_TB_EXEC)
run-tb-tx:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(TX_RTL_SRC).v $(TB_DIR)/$(TX_TB_SRC).sv --top tx_tb
	$(TX_TB_EXEC)

clean: # remove generated stuff
	rm $(OBJ_DIR)/*

