class driver;

    mailbox #(fifo_transaction) mbx;
    virtual fifo_if vif;

    function new(mailbox #(fifo_transaction) mbx,virtual fifo_if vif);
        this.mbx=mbx;
        this.vif=vif;
    endfunction

    task main();
        fifo_transaction tr;
        @(negedge vif.rst_n)
        vif.wr_en<=0;
        vif.rd_en<=0;
        vif.data_in<=0;
        @(posedge vif.rst_n);
        forever begin
            mbx.get(tr);
            tr.display("Driver");

            @(vif.drv_cb);
            if(~vif.drv_cb.full)begin
            vif.drv_cb.wr_en<=tr.wr_en;
            end 
            else begin
                vif.drv_cb.wr_en<=0;
            end
            if(~vif.drv_cb.empty)begin
            vif.drv_cb.rd_en<=tr.rd_en;
            end
            else begin
                vif.drv_cb.rd_en<=0;
            end
            vif.drv_cb.data_in<=tr.data;
            @(vif.drv_cb);
            vif.drv_cb.wr_en<=0;
            vif.drv_cb.rd_en<=0;
            
        end

    endtask
endclass