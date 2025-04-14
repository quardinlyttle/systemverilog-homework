//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------
module float_discriminant2(
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

 


    //Instantiation of Pipline modules. 
    f_mult multiplier(.clk(clk), .rst(rst), .a(stage1_b), .b(stage1_b), .up_valid(stage1_valid), .res(b_sq), .down_valid(bsq_valid), .busy(busy1), .error(error1));
    f_add adder(.clk(clk), .rst(rst), .a(stage3_aMulcsq), .b(stage3_aPlusbcsq), .up_valid(stage3_valid), .res(final_sum), .down_valid(final_valid), .busy(busy5), .error(error5));

/*
IDLE, Square, Middle, Result. 
Using only one multiplier and adder.
*/

endmodule
