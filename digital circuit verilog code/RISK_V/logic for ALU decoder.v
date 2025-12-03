

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 4'b0000;             // addition
        2'b01: ALUControl = 4'b0001;             // subtraction
        default:
            case (funct3) // R-type or I-type ALU
                3'b000: begin
                    // True for R-type subtract
                    if   (funct7b5 & opb5) ALUControl = 4'b0001; //sub
                    else ALUControl = 4'b0000; // add, addi
                end
					 
					 3'b001: begin
					         // for the I-type slli
									if (!funct7b5 & !opb5) ALUControl = 4'b0100; //slli
							      else                   ALUControl = 4'b1001; //sll 
								end
					 3'b101:  begin
			                  if (!funct7b5 & !opb5) ALUControl = 4'b1111; //srli
								   else ALUControl = 4'b1101; //srai
						       end 			
					 3'b100:  ALUControl = 4'b0111; //xori & xor
					 3'b011:  ALUControl = 4'b0110; //sltiu
                3'b010:  ALUControl = 4'b0101; // slt, slti
                3'b110:  ALUControl = 4'b0011; // or, ori
                3'b111:  ALUControl = 4'b0010; // and, andi
                default: ALUControl = 4'bxxxx; // ???
            endcase
    endcase
end

endmodule

