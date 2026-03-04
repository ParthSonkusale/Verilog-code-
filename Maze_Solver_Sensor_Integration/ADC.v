module adc_controller(
    input dout, adc_sck,
    output adc_cs_n, din, 
    output reg [11:0] d_out_ch0,
    output reg [7:0] mois
);
    parameter MIN = 12'd730;
    parameter MAX = 12'd1370;
    parameter STEP = (MAX - MIN) / 8;

    reg [3:0] din_counter = 0;
    reg [3:0] sp_counter  = 0;
    reg adc_cs = 1;
    reg din_temp = 0;       // channel 0
    reg [11:0] dout_chx = 0;

    // Write on falling edge
    always @(negedge adc_sck) begin
        if (din_counter == 4'd15)
            din_counter <= 0;
        else
            din_counter <= din_counter + 1'b1;

        if(din_counter == 0)
            adc_cs <= ~adc_cs;
    end

    // Read on rising edge
    always @(posedge adc_sck) begin
        if((sp_counter >= 4) && (sp_counter <= 15))
            dout_chx[15 - sp_counter] <= dout;

        if (sp_counter == 4'd15)
            sp_counter <= 0;
        else
            sp_counter <= sp_counter + 1'b1;
    end

    // Latch final ADC data
    always @(posedge adc_sck) begin
        if ((sp_counter == 4'd15) && (!adc_cs))
            d_out_ch0 <= dout_chx;
    end

    // Moisture level logic
    always @(posedge adc_sck) begin
        if(d_out_ch0 >= 12'd1300 )
            mois <= 8'h44; //D
        else 
            mois <= 8'h4D; //M
    end

    assign adc_cs_n = adc_cs;
    assign din = din_temp;

endmodule