interface fifo_if(input logic clk, input logic rst_n);
    logic wr_en;
    logic rd_en;
    logic [7:0]data_in;
    logic [7:0]data_out;
    logic full;
    logic empty;
    
    property p_full_no_wp_change;
        @(posedge clk)disable iff(!rst_n)
        (full&&wr_en) |-> ##1 $stable(tb_top.dut.wp);
    endproperty
    assert property(p_full_no_wp_change)
        else $error("Full flag is set but write pointer changed!");
    property p_empty_no_rp_change;
        @(posedge clk)disable iff(!rst_n)
        (empty&&rd_en) |-> ##1 $stable(tb_top.dut.rp);
    endproperty
    assert property(p_empty_no_rp_change)
        else $error("Empty flag is set but read pointer changed!");
    modport TEST(
        output wr_en,rd_en,data_in,
        input full,empty,data_out,
        input clk,rst_n
    );

    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        input full,empty;
        output wr_en,rd_en,data_in;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step output #1;
        input wr_en,rd_en,data_in,data_out,full,empty;
    endclocking

endinterface//定义了一个接口，然后写了一个TEST的安全卫士