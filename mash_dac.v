//(C) 2019 Ryan Lee Bunch
//A pipelined 1-1-1 MASH DAC with PWM modulator output
module mash_dac
(
input clk,
input rst_n,
input [15:0] in,
output reg out
);

wire clk8;
reg [2:0] clkdiv;
wire clken;
reg clken_latched;
wire [3:0] sdm_out;
wire [3:0] sdm_comb;
reg [7:0] pwm_shift;
reg [7:0] pwmrom;

always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    clkdiv <= 0;
  end
  else
  begin
    clkdiv <= clkdiv+1; 
  end
end

assign clken = clkdiv==0;

always @(clk or clken)
begin
  if(!clk)
    clken_latched = clken;
end

assign clk8 = clken_latched & clk;


mash_sdm
#(
.ACCUM_SIZE(16)
)
mash_sdm_i0
(
.clk(clk8),
.rst_n(rst_n),
.in({in[14:0],1'b1}),
.out(sdm_out)
);

//we need to delay match the MSB with SDM

reg msb_z1;
reg msb_z2;
reg msb_z3;

always @(posedge clk8 or negedge rst_n)  //due the rom lookup on slowest clock
begin
  if(!rst_n)
  begin
    msb_z1 <= 0;
    msb_z2 <= 0;
    msb_z3 <= 0;
  end
  else
  begin   
    msb_z1 <= in[15];
    msb_z2 <= msb_z1;
    msb_z3 <= msb_z2;  
  end
end

assign sdm_comb = {4{msb_z3}}+sdm_out;

always @(posedge clk8 or negedge rst_n)  //due the rom lookup on slowest clock
begin
  if(!rst_n)
  begin
    pwmrom <= 0; 
  end
  else
  begin   
    case(sdm_comb) 
      4'b0100: pwmrom <= 8'b11111111; 
      4'b0011: pwmrom <= 8'b11111110; 
      4'b0010: pwmrom <= 8'b11111100; 
      4'b0001: pwmrom <= 8'b11111000; 
      4'b0000: pwmrom <= 8'b11110000; 
      4'b1111: pwmrom <= 8'b11100000; 
      4'b1110: pwmrom <= 8'b11000000; 
      4'b1101: pwmrom <= 8'b10000000;    
      4'b1100: pwmrom <= 8'b00000000;                
      default: pwmrom <= 8'b11110000;  
    endcase    
  end
end

always @(posedge clk or negedge rst_n)  //serializer
begin
  if(!rst_n)
  begin
    pwm_shift <= 0; 
    out <= 0;
  end
  else
  begin
    pwm_shift <= clken ? pwmrom : {pwm_shift[6:0],1'b0};   
    out <= pwm_shift[7];
  end
end



endmodule
