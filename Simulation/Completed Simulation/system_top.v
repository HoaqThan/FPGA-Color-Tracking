`timescale 1ns/1ps

module system_top #(
    parameter IMG_WIDTH  = 640, // Chu?n VGA
    parameter IMG_HEIGHT = 480
) (
    // --- System Clocks & Reset ---
    input  wire        sys_clk,     // Xung nh?p h? th?ng (VD: 25MHz ho?c 48MHz)
    input  wire        sys_rst,     // Reset h? th?ng (Tích c?c m?c cao)

    // --- Giao ti?p Camera OV7670 ---
    output wire        cam_xclk,    // Xung c?p cho Camera (24MHz)
    output wire        cam_sioc,    // Xung nh?p I2C/SCCB
    inout  wire        cam_siod,    // D? li?u I2C/SCCB
    input  wire        cam_pclk,    // Xung pixel t? Camera tr? v?
    input  wire        cam_rst,     // Chân reset Camera
    input  wire        cam_vsync,   // ??ng b? khung h́nh (Frame sync)
    input  wire        cam_href,    // ??ng b? hàng (Line sync)
    input  wire [7:0]  cam_data,    // D? li?u pixel (8-bit)

    // --- Inputs t? ng??i dùng ---
    input  wire [1:0]  color_sel,   // Dành cho vi?c ch?n màu sau này (00, 01, 10, 11)

    // --- K?t qu? x? lư (Tracking Outputs) ---
    output wire [9:0]  final_x_center,
    output wire [9:0]  final_y_center,
    output wire        final_object_valid,
    output wire        final_error_flag,

    // --- Giao ti?p VGA (Tùy ch?n hi?n th? sau này) ---
    output wire        vga_hsync,
    output wire        vga_vsync,
    output wire [15:0] vga_rgb
);

    // =========================================================================
    // 1. T?O XUNG VÀ C?U H̀NH CAMERA (SCCB)
    // =========================================================================
    camera_xclk_24m #(
        .CLK_IN_HZ(48000000) // Khai báo t?n s? sys_clk th?c t? trên board c?a b?n
    ) xclk_gen (
        .clk_in(sys_clk),
        .rst(sys_rst),
        .xclk(cam_xclk),
        .locked()
    );

    wire config_done, config_busy, ack_error_sticky;
    ov7670_configurator #(
        .CLK_HZ(48000000),
        .SCCB_HZ(100000)
    ) cam_config (
        .clk(sys_clk),
        .rst(sys_rst),
        .sioc(cam_sioc),
        .siod(cam_siod),
        .config_done(config_done),
        .config_busy(config_busy),
        .ack_error_sticky(ack_error_sticky),
        .rom_index_debug()
    );

    // =========================================================================
    // 2. KH?I ??NG B? MI?N XUNG NH?P (CDC)
    // =========================================================================
    wire [15:0] sys_pixel;
    wire        sys_pixel_valid;
    wire        sys_frame_start;
    wire        sys_line_start;

    ov7670_rgb565_cdc #(
        .FIFO_ADDR_WIDTH(10), // T?ng size FIFO ?? an toàn khi simulation
        .VSYNC_ACTIVE_HIGH(1'b1)
    ) camera_cdc (
        .cam_pclk(cam_pclk),
        .cam_rst(cam_rst),
        .cam_vsync(cam_vsync),
        .cam_href(cam_href),
        .cam_data(cam_data),
        .cam_fifo_full(),
        .cam_overflow_sticky(),
        
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .sys_rd_en(1'b1),     // Luôn ??c d? li?u t? FIFO khi có th?
        .sys_pixel(sys_pixel),
        .sys_pixel_valid(sys_pixel_valid),
        .sys_frame_start(sys_frame_start),
        .sys_line_start(sys_line_start),
        .sys_fifo_empty(),
        .sys_overflow_sticky()
    );

    // =========================================================================
    // 3. KH?I L?C MÀU HSV
    // =========================================================================
    wire [7:0] hsv_h, hsv_s, hsv_v;
    wire       color_mask, color_mask_valid;
    wire       frame_start_d, line_start_d;

    // Gi? nguyên các thông s? HSV m?c ??nh c?a b?n
    color_tracking_hsv_stage #(
        .H_MIN(8'd0),  .H_MAX(8'd10),
        .S_MIN(8'd80), .S_MAX(8'd255),
        .V_MIN(8'd50), .V_MAX(8'd255)
    ) hsv_stage (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .sys_pixel(sys_pixel),
        .sys_pixel_valid(sys_pixel_valid),
        .sys_frame_start(sys_frame_start),
        .sys_line_start(sys_line_start),
        
        .hsv_h(hsv_h),
        .hsv_s(hsv_s),
        .hsv_v(hsv_v),
        .color_mask(color_mask),
        .color_mask_valid(color_mask_valid),
        .frame_start_d(frame_start_d),
        .line_start_d(line_start_d)
    );

    // =========================================================================
    // 4. B? ??M T?A ?? & T̀M KHUNG BAO (BOUNDING BOX)
    // =========================================================================
    wire [9:0] x_cnt, y_cnt;
    xy_counter xy_cnt_inst (
        .clk(sys_clk),
        .rst(sys_rst),
        .pixel_valid(color_mask_valid),
        .frame_start(frame_start_d),
        .x_cnt(x_cnt),
        .y_cnt(y_cnt)
    );

    wire [9:0] xmin, xmax, ymin, ymax;
    bounding_box bbox_inst (
        .clk(sys_clk),
        .rst(sys_rst),
        .frame_start(frame_start_d),
        .pixel_valid(color_mask_valid),
        .object_pixel(color_mask),
        .x_cnt(x_cnt),
        .y_cnt(y_cnt),
        .xmin(xmin),
        .xmax(xmax),
        .ymin(ymin),
        .ymax(ymax)
    );

    // =========================================================================
    // 5. TÍNH TÂM & VÙNG AN TOÀN
    // =========================================================================
    wire [9:0] cur_x_center, cur_y_center;
    center_calc calc_inst (
        .xmin(xmin),
        .xmax(xmax),
        .ymin(ymin),
        .ymax(ymax),
        .x_center(cur_x_center),
        .y_center(cur_y_center)
    );

    // Ch?t (Latch) t?a ?? cu?i cùng khi k?t thúc 1 Frame h́nh
    reg [9:0] x_center_reg, y_center_reg;
    reg       obj_valid_reg;

    always @(posedge sys_clk or posedge sys_rst) begin
        if (sys_rst) begin
            x_center_reg  <= 10'd0;
            y_center_reg  <= 10'd0;
            obj_valid_reg <= 1'b0;
        end else if (frame_start_d) begin
            x_center_reg  <= cur_x_center;
            y_center_reg  <= cur_y_center;
            
            // N?u có v?t th? (h?p bao h?p l?), gán c? h?p l? (Valid)
            if (xmax >= xmin && ymax >= ymin)
                obj_valid_reg <= 1'b1;
            else
                obj_valid_reg <= 1'b0;
        end
    end

    assign final_x_center     = x_center_reg;
    assign final_y_center     = y_center_reg;
    assign final_object_valid = obj_valid_reg;

    safe_zone safe_zone_inst (
        .x_center(final_x_center),
        .y_center(final_y_center),
        .error_flag(final_error_flag)
    );

    // =========================================================================
    // 6. XU?T TÍN HI?U VGA (Tùy ch?n)
    // =========================================================================
    wire vga_blank;
    wire [10:0] pixel_x, pixel_y;
    
    vga_controller vga_inst (
        .vga_clk(sys_clk), // N?u dùng th?c t?, vga_clk ph?i là 25.175 MHz
        .rst(sys_rst),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .vga_blank(vga_blank),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );
    
    // T?m th?i gán màu ?en cho VGA (Do ch?a có b? nh? RAM l?u ?nh xu?t màn h́nh)
    assign vga_rgb = 16'h0000;

endmodule
