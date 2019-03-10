//(C) 2019 Ryan Lee Bunch
//A pipelined 1-1-1 MASH SDM
module mash_sdm
#(
parameter ACCUM_SIZE=16
)
(
input clk,
input rst_n,
input [ACCUM_SIZE-1:0] in,
output reg [3:0] out
);


reg [ACCUM_SIZE-1:0] accum1_reg;
reg [ACCUM_SIZE-1:0] accum2_reg;
reg [ACCUM_SIZE-1:0] accum3_reg;

wire [ACCUM_SIZE-1:0] accum1_sum;  
wire [ACCUM_SIZE-1:0] accum2_sum;
wire [ACCUM_SIZE-1:0] accum3_sum;

wire c1;
wire c2;
wire c3;

reg c1_z1;
reg c1_z2;
reg c2_z1;
reg c2_z2;
reg c3_z1;
reg c3_z2;

wire [3:0] seq_sum;

assign {c1,accum1_sum} = in+accum1_reg;
assign {c2,accum2_sum} = accum1_reg+accum2_reg;
assign {c3,accum3_sum} = accum2_reg+accum3_reg;

assign seq_sum = c1_z2+c2_z1-c2_z2+c3-2*c3_z1+c3_z2;


always @(posedge clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    accum1_reg <= 0;  
    accum2_reg <= 0; 
    accum3_reg <= 0; 
    c1_z1      <= 0;
    c1_z2      <= 0;
    c2_z1      <= 0;
    c2_z2      <= 0;
    c3_z1      <= 0;
    c3_z2      <= 0;   
    out        <= 0; 
  end
  else
  begin
    accum1_reg <= accum1_sum;  
    accum2_reg <= accum2_sum; 
    accum3_reg <= accum3_sum; 
    c1_z1      <= c1;
    c1_z2      <= c1_z1;
    c2_z1      <= c2;
    c2_z2      <= c2_z1;
    c3_z1      <= c3;
    c3_z2      <= c3_z1;   
    out        <= seq_sum; 
  end
end



endmodule
