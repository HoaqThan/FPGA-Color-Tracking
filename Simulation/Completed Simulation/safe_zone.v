module safe_zone(
    input [9:0] x_center,
    input [9:0] y_center,
    output reg error_flag
);

always @(*) begin
    // ?ã n?i r?ng vùng Safe Zone ra kích th??c 200x200 pixel
    if( x_center >= 10'd220 &&
        x_center <= 10'd420 &&
        y_center >= 10'd140 &&
        y_center <= 10'd340)
        error_flag = 1'b0;
    else
        error_flag = 1'b1;
end

endmodule