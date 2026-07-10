`timescale 1ns/1ps

module bounding_box(
    input clk,
    input rst,
    input frame_start,
    input pixel_valid,
    input object_pixel,
    input [9:0] x_cnt,
    input [9:0] y_cnt,

    output reg [9:0] xmin,
    output reg [9:0] xmax,
    output reg [9:0] ymin,
    output reg [9:0] ymax
);

    always @(posedge clk) begin
        if (rst || frame_start) begin
            xmin <= 10'd639;
            xmax <= 10'd0;
            ymin <= 10'd479;
            ymax <= 10'd0;
        end else if (pixel_valid && object_pixel) begin
            if (x_cnt < xmin) xmin <= x_cnt;
            if (x_cnt > xmax) xmax <= x_cnt;
            if (y_cnt < ymin) ymin <= y_cnt;
            if (y_cnt > ymax) ymax <= y_cnt;
        end
    end

endmodule