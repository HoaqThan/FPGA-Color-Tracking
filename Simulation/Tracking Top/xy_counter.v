`timescale 1ns/1ps

module xy_counter(
    input wire clk,
    input wire rst,
    input wire pixel_valid,
    input wire frame_start,

    output reg [9:0] x_cnt,
    output reg [9:0] y_cnt
);

    always @(posedge clk) begin
        if (rst || frame_start) begin
            x_cnt <= 10'd0;
            y_cnt <= 10'd0;
        end else if (pixel_valid) begin
            if (x_cnt == 10'd639) begin
                x_cnt <= 10'd0;
                if (y_cnt == 10'd479) begin
                    y_cnt <= 10'd0;
                end else begin
                    y_cnt <= y_cnt + 10'd1;
                end
            end else begin
                x_cnt <= x_cnt + 10'd1;
            end
        end
    end

endmodule