program automatic test(fifo_if intf);
    import fifo_pkg::*;
    environment env;
    initial begin
        env=new(intf);
        env.main();
    end
endprogram