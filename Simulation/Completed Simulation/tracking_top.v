`timescale 1ns/1ps

module tracking_top(
    input clk,
    input rst,
    input pixel_valid,
    input frame_start,
    input object_pixel,

    output [9:0] x_center,
    output [9:0] y_center,
    output error_flag
);

    wire [9:0] x_cnt;
    wire [9:0] y_cnt;
    wire [9:0] xmin, xmax, ymin, ymax;

    // U1: B? ??m t?a ?? quét ?nh
    xy_counter U1 (
        .clk(clk),
        .rst(rst),
        .pixel_valid(pixel_valid),
        .frame_start(frame_start),
        .x_cnt(x_cnt),
        .y_cnt(y_cnt)
    );

    // U2: C?p nh?t h?p bao xung quanh v?t th? m?c tiêu
    bounding_box U2 (
        .clk(clk),
        .rst(rst),
        .frame_start(frame_start),
        .pixel_valid(pixel_valid),
        .object_pixel(object_pixel),
        .x_cnt(x_cnt),
        .y_cnt(y_cnt),
        .xmin(xmin),
        .xmax(xmax),
        .ymin(ymin),
        .ymax(ymax)
    );

    // U3: Tính toán t?a ?? tr?ng tâm
    center_calc U3 (
        .xmin(xmin), .xmax(xmax),
        .ymin(ymin), .ymax(ymax),
        .x_center(x_center),
        .y_center(y_center)
    );

    // U4: Ki?m tra v? trí tâm so v?i vùng Safe Zone
    safe_zone U4 (
        .x_center(x_center),
        .y_center(y_center),
        .error_flag(error_flag)
    );

endmodule