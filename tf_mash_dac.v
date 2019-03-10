//(C) 2019 Ryan Lee Bunch
//Simple Test Harness for MASH 1-1-1 DAC

module tf_mash_dac;


reg clk;
reg rst_n;
reg [15:0] in;
wire  out;


mash_dac mash_dac_i0
(
.clk(clk),
.rst_n(rst_n),
.in(in),
.out(out)
);

always
begin
  clk = 0;
  #1;
  clk = 1;
  #1;
end

real sum;
integer numclocks=100000;

initial
begin
  $dumpvars;
//  in = 65536*0.95;
  in = 32767;
  rst_n = 0;
  #10;
  rst_n = 1;
  #1000;
  sum = 0.0;
  repeat(numclocks)
  begin
    sum = sum + (1.0)*(out);
    @(posedge clk);
  end
  
  $display("Average was %0f",sum/numclocks);
  
  $finish;
end


endmodule
