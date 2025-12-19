class monitor;

    virtual fifo_if vif;

    mailbox #(fifo_transaction) mbx;

    int current_level=0;

    fifo_transaction tr;//和前面generator driver很像，都是为了这个操作这个包裹写这句话
    covergroup fifo_status_cg ;
        cp_full_trans:coverpoint vif.mon_cb.full{
            bins rose=(0=>1);
            bins fell=(1=>0);
            bins stable_high=(1=>1);
            bins stable_low=(0=>0);
        }
        cp_empty_trans:coverpoint vif.mon_cb.empty{
            bins rose=(0=>1);
            bins fell=(1=>0);
            bins stable_high=(1=>1);
            bins stable_low=(0=>0);
        }
        cp_level:coverpoint current_level{
            bins empty_lvl={0};
            bins almost_empty_lvl={1};
            bins mid_lvl={[2:14]};
            bins almost_full_lvl={15}; 
            bins full_lvl={16};
        }
        cross cp_level,vif.mon_cb.wr_en,vif.mon_cb.rd_en{
            ignore_bins impossible_full_wr=binsof(cp_level.full_lvl)&&binsof(vif.mon_cb.wr_en);
            ignore_bins impossible_empty_rd=binsof(cp_level.empty_lvl)&&binsof(vif.mon_cb.rd_en);
        }
        cross vif.mon_cb.wr_en,vif.mon_cb.rd_en;
    endgroup

    covergroup fifo_data_cg with function sample(fifo_transaction t);
        option.per_instance=1;
        cp_data:coverpoint t.data{
            bins max={8'hff};
            bins min={8'h00};
            bins pattern_55={8'h55};
            bins pattern_aa={8'haa};
            bins other=default;
        }
    endgroup
    function new(virtual fifo_if vif,mailbox #(fifo_transaction) mbx);//this跟着的是class定义的，右值是括号里面的，也就是从外面得到的接口
        this.vif=vif;//这个接口为了能测到上升沿且使能时的data_in或data_out
        this.mbx=mbx;//这个mailbox是为了把检测到的数据发给scoreboard，比如这次写入的数据，在fifo里就是当上升沿时rp=wp-1且rp=1的时候看有没有相同，具体逻辑还不知道
        fifo_status_cg=new();
        fifo_data_cg=new();
    endfunction

    task main();
        bit vaild_read=0;
        forever begin
            @(vif.mon_cb)
                if(!vif.rst_n)begin
                current_level=0;
            end else begin
                fifo_status_cg.sample();
                case({vif.mon_cb.wr_en&!vif.mon_cb.full,vif.mon_cb.rd_en&!vif.mon_cb.empty})
                    2'b10:current_level=current_level+1;
                    2'b01:current_level=current_level-1;
                    2'b11:current_level=current_level;
                    2'b00:current_level=current_level;
                endcase
            end
                if(vif.mon_cb.wr_en&~vif.mon_cb.full)begin
                    tr=new();
                    tr.data=vif.mon_cb.data_in;
                    tr.wr_en=vif.mon_cb.wr_en;
                    tr.display("Monitor-write");
                    mbx.put(tr);
                    fifo_data_cg.sample(tr);
                end
                if(vaild_read)begin
                    tr=new();
                    tr.data=vif.mon_cb.data_out;
                    tr.rd_en=1;
                    tr.display("Monitor-read");
                    mbx.put(tr);
                    fifo_data_cg.sample(tr);
                end
                if(vif.mon_cb.rd_en&&~vif.mon_cb.empty)begin
                    vaild_read=1;
                end
                else begin
                    vaild_read=0;
                end
                
            end

    endtask
    
endclass