module MULTI_PLEXER(a,b,c,d,s1,s2,F);
  input a,b,c,d,s1,s2;
  output reg F;
 
  always@(a or b or c or d or s1 or s2)
    begin
      case({s1,s2})
        2'b00: F=a;
        2'b01: F=b;
        2'b10: F=c;
        2'b11: F=d;
        default: F=1'b0;
      endcase
      end
      endmodule