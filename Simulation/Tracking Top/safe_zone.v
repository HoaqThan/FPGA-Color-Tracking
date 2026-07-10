module safe_zone(

    input [9:0] x_center,
    input [9:0] y_center,

    output reg error_flag

);

always @(*)
begin

   if( x_center >= 270 &&
       x_center <= 370 &&
       y_center >= 190 &&
       y_center <= 290)
        error_flag = 1'b0;

    else

        error_flag = 1'b1;

end

endmodule