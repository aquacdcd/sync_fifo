class fifo_transaction;
    rand bit[7:0]data;//命名成data会更好吗？
    rand bit wr_en;
    rand bit rd_en;

    constraint data_ratio {
        data dist{
            8'h00 := 15,
            8'hff := 15,
            8'haa := 15,
            8'h55 := 15,
            [1:254]:/40
        };
    }
    constraint c_fill {
        wr_en dist { 1 := 8, 0 := 2 };
        rd_en dist { 1 := 2, 0 := 8 };
    }

    constraint c_drain {
        wr_en dist { 1 := 1,0 := 9};
        rd_en dist { 1 := 9,0 := 1};
    }
    function void display(string name);
        $display("Time =%t [%s] wr=%b rd=%b data=%h",$time,name,wr_en,rd_en,data);
    endfunction

endclass
