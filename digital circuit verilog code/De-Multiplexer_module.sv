module DE_MUX(a,b,c,d,s1,s2,F);
  input F,s1,s2;
  output reg a,b,c,d;
  always@(F or s1 or s2)
  begin
    if(s1==0 && s2==0) begin
      a=F; b=0; c=0; d=0;
    end
    else if(s1==0 && s2==1) begin
      a=0; b=F; c=0; d=0;
    end
    else if(s1==1 && s2==0) begin
      a=0; b=0; c=F; d=0;
    end
    else begin
      a=0; b=0; c=0; d=F;
    end
    
  end
endmodule
      