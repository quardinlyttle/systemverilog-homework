//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
//adding parameter for FLEN for Modelsim purposes rather than using header file
module float_discriminant #(parameter FLEN = 8) (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //

    //***********************************************
    //Note: Yuri has asked me to do a+b^2+a*c^2 instead for this instance.
    //Exercise 3. A pipelined implementation capable of accepting the formula arguments 
    //back-to-back, getting each clock cycle a new set of arguments.
    //***********************************************

    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

 

    //Pipeline stages
    logic [FLEN-1:0] stage1_a,stage1_b,stage1_c,b_sq, c_sq;
    logic stage1_valid, bsq_valid, csq_valid;

    logic [FLEN-1:0] stage2_a,stage2_bsq, stage2_csq, a_x_csq, a_p_bsq;
    logic stage2_valid, aMulCsq_valid, aPlusBsq_valid;

    logic [FLEN-1:0]  stage3_aMulcsq, stage3_aPlusbcsq, final_sum;
    logic stage3_valid, final_valid;

    //System Busy or Error state
    logic busy1,busy2,busy3,busy4,busy5, sys_Busy;
    assign sys_Busy = busy1||busy2 || busy3 || busy4 || busy5;
    //For busy, I am assuming each module will have its own busy logic which would be more useful for pipelining within itself, however for this assignment
    // I will not use it for simplicity and scope.

    logic error1,error2,error3,error4,error5, sys_error;
    assign sys_error = error1||error2 || error3 || error4 || error5;

    //Instantiation of Pipline modules. 
    f_mult bSquare(.clk(clk), .rst(rst), .a(stage1_b), .b(stage1_b), .up_valid(stage1_valid), .res(b_sq), .down_valid(bsq_valid), .busy(busy1), .error(error1));
    f_mult cSquare(.clk(clk), .rst(rst), .a(stage1_c), .b(stage1_c), .up_valid(stage1_valid), .res(c_sq), .down_valid(csq_valid), .busy(busy2), .error(error2));
    f_mult aMul_cSquare(.clk(clk), .rst(rst), .a(stage2_a), .b(stage2_csq), .up_valid(stage2_valid), .res(a_x_csq), .down_valid(aMulCsq_valid), .busy(busy3), .error(error3));
    f_add aPlus_bSquare(.clk(clk), .rst(rst), .a(stage2_a), .b(stage2_bsq), .up_valid(stage2_valid), .res(a_p_bsq), .down_valid(aPlusBsq_valid), .busy(busy4), .error(error4));
    f_add total_sum(.clk(clk), .rst(rst), .a(stage3_aMulcsq), .b(stage3_aPlusbcsq), .up_valid(stage3_valid), .res(final_sum), .down_valid(final_valid), .busy(busy5), .error(error5));

    
    always_ff @( posedge clk or posedge rst) begin : PIPELINE
        if(rst) begin

            //Reset stage 1
            stage1_valid <=1'b0;
            b_sq <= {FLEN{1'b0}};
            c_sq <= {FLEN{1'b0}};
            stage1_a <= {FLEN{1'b0}};
            stage1_b <= {FLEN{1'b0}};
            stage1_c <= {FLEN{1'b0}};
            bsq_valid <= 1'b0;
            csq_valid <= 1'b0;

            //Reset Stage 2
            a_x_csq <= {FLEN{1'b0}};
            a_p_bsq <= {FLEN{1'b0}};
            stage2_a <= {FLEN{1'b0}};
            stage2_bsq <= {FLEN{1'b0}};
            stage2_csq <= {FLEN{1'b0}};
            stage2_valid <= 1'b0;
            final_valid <= 1'b0;
            aMulCsq_valid <= 1'b0;
            aPlusBsq_valid <= 1'b0;

            //Reset Stage 3
            final_sum <= {FLEN{1'b0}};
            final_valid <= 1'b0;
            stage3_valid <= 1'b0;
            stage3_aMulcsq <= {FLEN{1'b0}};
            stage3_aPlusbcsq <= {FLEN{1'b0}};

            //Reset output
            res_vld <= 1'b0;
            res <= {FLEN{1'b0}};
            res_negative <= 1'b0;
            err <= 1'b0;
            busy <= 1'b0;
        end
        //Valid data at clk cycle.
        else if(arg_vld) begin
            stage1_a <= a;
            stage1_b <= b;
            stage1_c <= c;
            stage1_valid <=1'b1;
        end
        if(!arg_vld) begin
            stage1_valid <=1'b0;
        end
        //Stage2
        if(csq_valid && bsq_valid && (!(error1 || error2))) begin
            stage2_valid <=1'b1;
            stage2_a <= stage1_a;
            stage2_bsq <= b_sq;
            stage2_csq <= c_sq;
        end
        else begin
            stage2_valid <=1'b0;
        end
        //Stage3
        if(aMulCsq_valid && aPlusBsq_valid && (!(error3 || error4))) begin
            stage3_valid <= 1'b1;
            stage3_aMulcsq <= a_x_csq;
            stage3_aPlusbcsq <=a_p_bsq;
        end
        else begin 
            stage3_valid <=1'b0;
        end
        //output
        if (final_valid) begin
            if (!error5) begin
                res <= final_sum;
                res_vld <= 1'b1;
                res_negative <= final_sum[FLEN-1];
            end
            else begin
                res <= {FLEN{1'b0}};
                res_vld <= 1'b0;
                res_negative <= 1'b0;
            end
        end
        else begin
            res <= {FLEN{1'b0}};
            res_vld <= 1'b0;
            res_negative <= 1'b0;
        end

        
    end
endmodule
