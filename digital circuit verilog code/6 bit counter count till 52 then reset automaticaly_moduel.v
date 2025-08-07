module counter_6bit(clk,count);
  input clk;
  output reg [5:0] count = 6'b000000;

always @(posedge clk) begin
  if (count == 6'b110100)
    count <= 6'b000000;
  else
    count <= count + 1;
end

endmodule