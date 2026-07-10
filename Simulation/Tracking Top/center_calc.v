module center_calc(

    input [9:0] xmin,
    input [9:0] xmax,
    input [9:0] ymin,
    input [9:0] ymax,

    output [9:0] x_center,
    output [9:0] y_center

);

assign x_center = (xmin + xmax) >> 1;
assign y_center = (ymin + ymax) >> 1;

endmodule