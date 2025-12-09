class driver;

    mailbox #(fifo_transaction) mbx;
    virtual fifo_if vif;

    function new(mailbox #(fifo_transaction) mbx,virtual fifo_if vif);
        this.mbx=mbx;
        this.vif=vif;
    endfunction

    task main();
        fifo_transaction tr;
        vif.wr_en=0;
        vif.rd_en=0;
        vif.data_in=0;
        @(posedge vif.rst_n);
        forever begin
            mbx.get(tr);
            tr.display("Driver");

            @(posedge vif.clk);
            vif.wr_en<=tr.wr_en;
            vif.rd_en<=tr.rd_en;
            vif.data_in<=tr.data;
            @(posedge vif.clk);
            vif.wr_en<=0;
            vif.rd_en<=0;
            
        end

    endtask
endclass