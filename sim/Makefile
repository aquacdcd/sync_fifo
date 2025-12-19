# -----------------------------------------------------------
# 1. 路径定义
# -----------------------------------------------------------
RTL_DIR    = ../rtl
TB_DIR     = ../tb

# -----------------------------------------------------------
# 2. 文件列表
# -----------------------------------------------------------
RTL_FILES  = $(RTL_DIR)/sync_fifo.v
PKG_FILES  = $(TB_DIR)/fifo_pkg.sv
INTF_FILES = $(TB_DIR)/fifo_if.sv
TOP_FILES  = $(TB_DIR)/tb_top.sv $(TB_DIR)/test.sv
TB_FILES   = $(wildcard $(TB_DIR)/*.sv)

# -----------------------------------------------------------
# 3. 输出定义 & 覆盖率配置
# -----------------------------------------------------------
OUTPUT      = simv

# 覆盖率类型配置
COV_OPTS    = -cm line+cond+fsm+tgl+branch+assert

# 覆盖率数据库名称 (统一变量，防止手误)
COV_DB_NAME = sync_fifo.vdb

# -----------------------------------------------------------
# 4. 编译规则 (VCS)
# -----------------------------------------------------------
all: $(OUTPUT)

$(OUTPUT): $(RTL_FILES) $(TB_FILES)
	# [修复点] 关键！编译时必须指定 -cm_dir，否则 VCS 会默认生成 simv.vdb，
	# 导致和后面运行时的数据库 sync_fifo.vdb 分离，造成报告里没有代码层级。
	vcs -full64 -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS "-Wl,--no-as-needed" \
	-sverilog -debug_access+all -kdb \
	-l compile.log \
	+incdir+$(TB_DIR) \
	$(COV_OPTS) \
	-cm_dir $(COV_DB_NAME) \
	-o $(OUTPUT) \
	$(INTF_FILES) $(PKG_FILES) $(RTL_FILES) $(TOP_FILES)

# -----------------------------------------------------------
# 5. 运行规则 (SIMV)
# -----------------------------------------------------------
run: $(OUTPUT)
	# 运行时继续指定同一个 -cm_dir，累加数据
	./$(OUTPUT) \
	$(COV_OPTS) \
	-cm_dir $(COV_DB_NAME) \
	-cm_name test_run_1 \
	-l sim.log \
	+fsdb+region

# -----------------------------------------------------------
# 6. 生成报告规则 (URG)
# -----------------------------------------------------------
report:
	# 指定同一个数据库生成报告
	urg -dir $(COV_DB_NAME) -format both -report urgReport
	@echo "-------------------------------------------------------"
	@echo "覆盖率报告已生成! 请打开 urgReport/dashboard.html 查看"
	@echo "-------------------------------------------------------"

# -----------------------------------------------------------
# 7. 清理规则
# -----------------------------------------------------------
clean:
	rm -rf csrc simv simv.daidir *.log *.fsdb *.vpd *.key vc_hdrs.h .vlogansetup.args
	# 清理掉所有的 vdb 文件夹 (包括可能残留的默认 simv.vdb)
	rm -rf $(COV_DB_NAME) simv.vdb urgReport