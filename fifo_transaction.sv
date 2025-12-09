class fifo_transaction;
    rand bit[7:0]data;//命名成data会更好吗？
    rand bit wr_en;
    rand bit rd_en;

    constraint valid_ctrl {
        !(wr_en && rd_en);
        wr_en dist { 1 := 6, 0 := 4 };
        rd_en dist { 1 := 4, 0 := 6 };
    }

    function void display(string name);
        $display("Time =%t [%s] wr=%b rd=%b data=%h",$time,name,wr_en,rd_en,data);
    endfunction

endclass
