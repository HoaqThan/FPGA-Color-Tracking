`timescale 1ns/1ps

// RGB565 to HSV threshold for color tracking.
// Input should already be in sys_clk domain, for example from ov2640_rgb565_cdc.
// Hue is scaled to 0..179 like OpenCV, Saturation and Value are 0..255.
module rgb565_to_hsv_threshold #(
    parameter [7:0] H_MIN = 8'd0,
    parameter [7:0] H_MAX = 8'd10,
    parameter [7:0] S_MIN = 8'd80,
    parameter [7:0] S_MAX = 8'd255,
    parameter [7:0] V_MIN = 8'd50,
    parameter [7:0] V_MAX = 8'd255
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] rgb565,
    input  wire        pixel_valid,

    output reg  [7:0]  hue,
    output reg  [7:0]  sat,
    output reg  [7:0]  val,
    output reg         mask,
    output reg         mask_valid
);

    wire [7:0] r8;
    wire [7:0] g8;
    wire [7:0] b8;

    reg [7:0] max_rgb;
    reg [7:0] min_rgb;
    reg [7:0] delta;
    reg [7:0] h_calc;
    reg [7:0] s_calc;
    reg [7:0] v_calc;
    integer   h_tmp;
    reg       h_in_range;
    reg       s_in_range;
    reg       v_in_range;

    assign r8 = {rgb565[15:11], rgb565[15:13]};
    assign g8 = {rgb565[10:5],  rgb565[10:9]};
    assign b8 = {rgb565[4:0],   rgb565[4:2]};

    always @* begin
        if ((r8 >= g8) && (r8 >= b8)) begin
            max_rgb = r8;
        end else if (g8 >= b8) begin
            max_rgb = g8;
        end else begin
            max_rgb = b8;
        end

        if ((r8 <= g8) && (r8 <= b8)) begin
            min_rgb = r8;
        end else if (g8 <= b8) begin
            min_rgb = g8;
        end else begin
            min_rgb = b8;
        end

        delta  = max_rgb - min_rgb;
        v_calc = max_rgb;

        if (max_rgb == 0) begin
            s_calc = 0;
        end else begin
            s_calc = (delta * 255) / max_rgb;
        end

        h_tmp = 0;
        if (delta == 0) begin
            h_tmp = 0;
        end else if (max_rgb == r8) begin
            if (g8 >= b8) begin
                h_tmp = ((g8 - b8) * 30) / delta;
            end else begin
                h_tmp = 180 - (((b8 - g8) * 30) / delta);
            end
        end else if (max_rgb == g8) begin
            if (b8 >= r8) begin
                h_tmp = 60 + (((b8 - r8) * 30) / delta);
            end else begin
                h_tmp = 60 - (((r8 - b8) * 30) / delta);
            end
        end else begin
            if (r8 >= g8) begin
                h_tmp = 120 + (((r8 - g8) * 30) / delta);
            end else begin
                h_tmp = 120 - (((g8 - r8) * 30) / delta);
            end
        end

        if (h_tmp < 0) begin
            h_calc = h_tmp + 180;
        end else if (h_tmp >= 180) begin
            h_calc = h_tmp - 180;
        end else begin
            h_calc = h_tmp[7:0];
        end

        if (H_MIN <= H_MAX) begin
            h_in_range = (h_calc >= H_MIN) && (h_calc <= H_MAX);
        end else begin
            // Wrap-around range, useful for red: H_MIN=170, H_MAX=10.
            h_in_range = (h_calc >= H_MIN) || (h_calc <= H_MAX);
        end

        s_in_range = (s_calc >= S_MIN) && (s_calc <= S_MAX);
        v_in_range = (v_calc >= V_MIN) && (v_calc <= V_MAX);
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hue        <= 8'd0;
            sat        <= 8'd0;
            val        <= 8'd0;
            mask       <= 1'b0;
            mask_valid <= 1'b0;
        end else begin
            mask_valid <= pixel_valid;

            if (pixel_valid) begin
                hue  <= h_calc;
                sat  <= s_calc;
                val  <= v_calc;
                mask <= h_in_range && s_in_range && v_in_range;
            end else begin
                mask <= 1'b0;
            end
        end
    end

endmodule
