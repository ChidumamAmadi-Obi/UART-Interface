# makefile to do stuff with verilator easier

# warning diable
RTL_DISABLE_WARNING ?= -Wno-WIDTHEXPAND
TB_DISABLE_WARNING ?=  $(RTL_DISABLE_WARNING) -Wno-WIDTHTRUNC

# source files ***********************
# rtl
TOP_RTL_SRC = top
TOP_SPI_SRC = spi_slave_top
SNR_CTRL_SRC = sonar_control
TX_RTL_SRC = tx_uart
RX_RTL_SRC = rx_uart

# tbs
TOP_TB_SRC = top_tb
SPI_TB_SRC = spi_slave_tb
SNR_CTRL_TB_SRC = sonar_control_tb
TX_TB_SRC = tx_tb
RX_TB_SRC = rx_tb

# directories
RTL_DIR = rtl
TB_DIR = tb
OBJ_DIR = obj_dir

# executables ************************
# rtl executables
TOP_RTL_EXEC = ./$(OBJ_DIR)/V$(TOP_RTL_SRC)
TOP_SPI_EXEC = ./$(OBJ_DIR)/V$(TOP_SPI_SRC)
SNR_CTRL_EXEC = ./$(OBJ_DIR)/V$(TOP_SPI_SRC)
TX_RTL_EXEC = ./$(OBJ_DIR)/V$(TX_RTL_SRC)
RX_RTL_EXEC = ./$(OBJ_DIR)/V$(RX_RTL_SRC)

# tb executalbes
TOP_TB_EXEC = ./$(OBJ_DIR)/V$(TOP_TB_SRC)
TB_SPI_EXEC = ./$(OBJ_DIR)/V$(SPI_TB_SRC)
SNR_CTRL_TB_EXEC = ./$(OBJ_DIR)/V$(SNR_CTRL_TB_SRC)
TX_TB_EXEC = ./$(OBJ_DIR)/V$(TX_TB_SRC)
RX_TB_EXEC = ./$(OBJ_DIR)/V$(RX_TB_SRC)

# ***************************************************************************************************
help: # shows message
	@echo  MAKEFILE TARGETS:
	@echo  - lint-rtl
	@echo  - lint-spi-top
	@echo  - lint-snr-ctrl
	@echo  - lint-rtl-tx
	@echo  - lint-rtl-rx
	@echo  - run-tb-top
	@echo  - run-tb-snr-ctrl
	@echo  - run-tb-spi
	@echo  - run-tb-tx
	@echo  - run-tb-rx
	@echo  - clean
	@echo  - help

# lint only rtl modules
lint-rtl:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(TOP_RTL_SRC).v --top top
lint-spi-top:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(TOP_SPI_SRC).v --top spi_slave_top
lint-snr-ctrl:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(SNR_CTRL_SRC).v --top sonar_control
lint-rtl-rx:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(RX_RTL_SRC).v --top rx_uart
lint-rtl-tx:
	verilator --lint-only -I$(RTL_DIR) $(RTL_DISABLE_WARNING) $(RTL_DIR)/$(TX_RTL_SRC).v --top tx_uart

# run tbs
run-tb-top:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(TOP_RTL_SRC).v $(TB_DIR)/$(TOP_TB_SRC).sv --top top_tb
	$(TOP_TB_EXEC)
run-tb-spi:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(TOP_SPI_SRC).v $(TB_DIR)/$(SPI_TB_SRC).sv --top spi_slave_top_tb
	$(TOP_SPI_EXEC)
run-tb-snr-ctrl:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(SNR_CTRL_SRC).v $(TB_DIR)/$(SNR_CTRL_TB_SRC).sv --top sonar_control_tb
	$(SNR_CTRL_TB_EXEC)
run-tb-rx:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(RX_RTL_SRC).v $(TB_DIR)/$(RX_TB_SRC).sv --top rx_tb
	$(RX_TB_EXEC)
run-tb-tx:
	verilator --binary -I$(RTL_DIR) -I$(TB_DIR) $(TB_DISABLE_WARNING) $(RTL_DIR)/$(TX_RTL_SRC).v $(TB_DIR)/$(TX_TB_SRC).sv --top tx_tb
	$(TX_TB_EXEC)

clean: # remove generated stuff
	rm $(OBJ_DIR)/*

