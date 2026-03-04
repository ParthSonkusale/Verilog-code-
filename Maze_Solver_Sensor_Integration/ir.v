module ir(
    input  wire clk,
    input  wire left,
    input  wire mid,
    input  wire right,
	 output reg  mid_op,
    output reg  left_op,
    output reg  right_op
);

always @(posedge clk) begin
    left_op  <= (!left);
    mid_op   <= (!mid);
    right_op <= (!right);
end 

endmodule
