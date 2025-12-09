# -----------------------------------------------------------
# 1. 路径定义 (核心变化：用 ../ 返回上一级去找源码)
# -----------------------------------------------------------
RTL_DIR = ../rtl
TB_DIR  = ../tb

# 2. 文件列表 (全部加上 ../ 前缀)
RTL_FILES  = $(RTL_DIR)/sync_fifo.v
PKG_FILES  = $(TB_DIR)/fifo_pkg.sv
INTF_FILES = $(TB_DIR)/fifo_if.sv
TOP_FILES  = $(TB_DIR)/tb_top.sv $(TB_DIR)/test.sv

# 3. 输出定义 (因为就在 sim 目录下，直接写文件名即可)
OUTPUT     = simv

# -----------------------------------------------------------
# 4. 编译规则
# -----------------------------------------------------------
all: $(OUTPUT)

$(OUTPUT): $(RTL_FILES) $(PKG_FILES) $(INTF_FILES) $(TOP_FILES)
	# 关键参数解释：
	# -o $(OUTPUT): 生成的可执行文件叫 simv
	# +incdir+$(TB_DIR): 告诉 VCS 去 ../tb 目录找 `include 的 class 文件
	vcs -full64 -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS "-Wl,--no-as-needed" \
	-sverilog -debug_access+all -kdb \
	-l compile.log \
	+incdir+$(TB_DIR) \
	-o $(OUTPUT) \
	$(INTF_FILES) $(PKG_FILES) $(RTL_FILES) $(TOP_FILES)

# -----------------------------------------------------------
# 5. 运行规则
# -----------------------------------------------------------
run: $(OUTPUT)
	./$(OUTPUT) -l sim.log

# -----------------------------------------------------------
# 6. 清理规则 (只清理当前目录下的垃圾，安全！)
# -----------------------------------------------------------
clean:
	rm -rf csrc simv simv.daidir *.log *.fsdb *.key vc_hdrs.h