module moisture_sensor(
    input dout, clk50,
    output adc_cs_n, din, adc_sck,
    output [11:0] d_out_ch0,
    output [7:0] mois
);


reg [3:0] counter;

always @(posedge clk50) begin
    counter <= counter + 1;
end

assign adc_sck = counter[3]; // dividing clk50 by 8 to get adc_sck

adc_controller adc_inst(
    .dout(dout),
    .adc_sck(adc_sck),
    .adc_cs_n(adc_cs_n),
    .din(din),
    .d_out_ch0(d_out_ch0),
    .mois(mois)
);


endmodule