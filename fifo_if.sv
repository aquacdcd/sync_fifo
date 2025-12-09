interface fifo_if(input logic clk, input logic rst_n);
    logic wr_en;
    logic rd_en;
    logic [7:0]data_in;
    logic [7:0]data_out;
    logic full;
    logic empty;
    
    property p_no_write_on_full;
        @(posedge clk)disable iff(!rst_n)
        (full) |-> !wr_en;
    endproperty
    modport TEST(
        output wr_en,rd_en,data_in,
        input full,empty,data_out,
        input clk,rst_n
    );
endinterface//定义了一个接口，然后写了一个TEST的安全卫士