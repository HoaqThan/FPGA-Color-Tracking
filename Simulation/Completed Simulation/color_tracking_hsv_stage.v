`timescale 1ns/1ps

// Small integration stage: CDC pixel stream -> HSV threshold mask.
// Connect sys_pixel/sys_pixel_valid from ov2640_rgb565_cdc to this module.
module color_tracking_hsv_stage #(
    parameter [7:0] H_MIN = 8'd0,
    parameter [7:0] H_MAX = 8'd10,
    parameter [7:0] S_MIN = 8'd80,
    parameter [7:0] S_MAX = 8'd255,
    parameter [7:0] V_MIN = 8'd50,
    parameter [7:0] V_MAX = 8'd255
) (
    input  wire        sys_clk,
    input  wire        sys_rst,
    input  wire [15:0] sys_pixel,
    input  wire        sys_pixel_valid,
    input  wire        sys_frame_start,
    input  wire        sys_line_start,

    output wire [7:0]  hsv_h,
    output wire [7:0]  hsv_s,
    output wire [7:0]  hsv_v,
    output wire        color_mask,
    output wire        color_mask_valid,
    output reg         frame_start_d,
    output reg         line_start_d
);

    rgb565_to_hsv_threshold #(
        .H_MIN(H_MIN),
        .H_MAX(H_MAX),
        .S_MIN(S_MIN),
        .S_MAX(S_MAX),
        .V_MIN(V_MIN),
        .V_MAX(V_MAX)
    ) hsv_filter (
        .clk        (sys_clk),
        .rst        (sys_rst),
        .rgb565     (sys_pixel),
        .pixel_valid(sys_pixel_valid),
        .hue        (hsv_h),
        .sat        (hsv_s),
        .val        (hsv_v),
        .mask       (color_mask),
        .mask_valid (color_mask_valid)
    );

    always @(posedge sys_clk or posedge sys_rst) begin
        if (sys_rst) begin
            frame_start_d <= 1'b0;
            line_start_d  <= 1'b0;
        end else begin
            frame_start_d <= sys_pixel_valid && sys_frame_start;
            line_start_d  <= sys_pixel_valid && sys_line_start;
        end
    end

endmodule
