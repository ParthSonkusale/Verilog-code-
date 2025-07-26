module frequency_scaler (
    input clk_50MHz,
    output reg clk_1MHz
);

initial begin
    clk_1MHz = 1;
end

reg [5:0] count = 6'd0;
parameter HALF_CYCLE = 6'd24;
reg toggle_next = 1'b0;

always @(posedge clk_50MHz) begin
    if (count == HALF_CYCLE) begin
        toggle_next <= 1'b1;         
        count <= 6'd0;
    end else begin
        count <= count + 6'd1;
    end

    if (toggle_next) begin
        clk_1MHz <= ~clk_1MHz;   
        toggle_next <= 1'b0;        
    end
end
 

endmodule