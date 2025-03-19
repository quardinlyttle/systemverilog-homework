//----------------------------------------------------------------------------
// Testbench
//----------------------------------------------------------------------------

`include "util.svh"
module new_testbench #(parameter FLEN = 8);

    //--------------------------------------------------------------------------
    // Signals to drive Device Under Test - DUT

    logic               clk;
    logic               rst;

    logic               arg_vld;
    logic  [FLEN - 1:0] a;
    logic  [FLEN - 1:0] b;
    logic  [FLEN - 1:0] c;

    wire                res_vld;
    wire   [FLEN - 1:0] res;
    wire                res_negative;
    wire                err;

    wire                busy;


    
    //--------------------------------------------------------------------------
    // Driving clk

    initial
    begin
        clk = '1;

        forever
        begin
            # 5 clk = ~ clk;
        end
    end

    //------------------------------------------------------------------------
    // Reset

    task reset ();

        rst <= 'x;
        repeat (3) @ (posedge clk);
        rst <= '1;
        repeat (3) @ (posedge clk);
        rst <= '0;

    endtask

    float_discriminant dut(.clk(clk),.rst(rst),.arg_vld(arg_vld),.a(a),.b(b),.c(c),.res_vld(res_vld),.res(res),
                        .res_negative(res_negative),.err(err),.busy(busy));

    //Some basic testing of stimuli
    //ignoring integer limits for now
    initial begin
        #5
        a= 2;
        b= 3;
        c= 4;
        #20
        a=1;
        b=2;
        c=3;
        #30
        reset;
    end


endmodule 