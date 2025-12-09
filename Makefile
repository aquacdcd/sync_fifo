
RTL_FILES =sync_fifo.v
PKG_FILES =fifo_pkg.sv
INTF_FILES=fifo_if.sv
TOP_FILES =tb_top.sv test.sv
CLASS_FILES =fifo_transaction.sv generator.sv driver.sv monitor.sv scoreboard.sv environment.sv
ALL_FILES =$(RTL_FILES) $(PKG_FILES) $(INTF_FILES) $(TOP_FILES) $(CLASS_FILES)

simv: $(ALL_FILES)
	vcs -full64 -cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed -sverilog  -debug_access+all -kdb -l com.log $(INTF_FILES) $(PKG_FILES) $(RTL_FILES) $(TOP_FILES)

clean:
	rm -rf csrc simv simv.daidir *.log *.fsdb ucli.key vc_hdrs.h