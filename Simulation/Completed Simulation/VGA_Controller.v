`timescale 1ns/1ps

module vga_controller (
    input  wire        vga_clk,   // Th??ng là 25.175 MHz cho ?? phân gi?i 640x480
    input  wire        rst,
    output reg         vga_hsync,
    output reg         vga_vsync,
    output wire        vga_blank, // Báo vùng t?t (b?ng 1 khi n?m trong vùng tr?ng Horizontal/Vertical Blank)
    output wire [10:0] pixel_x,   // T?a ?? X hi?n t?i quét trên màn hình
    output wire [10:0] pixel_y    // T?a ?? Y hi?n t?i quét trên màn hình
);

    // Thông s? VGA chu?n 640x480 @ 60Hz
    localparam H_ACTIVE = 640;
    localparam H_FRONT  = 16;
    localparam H_SYNC   = 96;
    localparam H_BACK   = 48;
    localparam H_TOTAL  = 800;

    localparam V_ACTIVE = 480;
    localparam V_FRONT  = 10;
    localparam V_SYNC   = 2;
    localparam V_BACK   = 33;
    localparam V_TOTAL  = 525;

    reg [10:0] h_cnt;
    reg [10:0] v_cnt;

    // B? ??m ngang (Horizontal Counter)
    always @(posedge vga_clk or posedge rst) begin
        if (rst)
            h_cnt <= 11'd0;
        else if (h_cnt == H_TOTAL - 1)
            h_cnt <= 11'd0;
        else
            h_cnt <= h_cnt + 11'd1;
    end

    // B? ??m d?c (Vertical Counter)
    always @(posedge vga_clk or posedge rst) begin
        if (rst)
            v_cnt <= 11'd0;
        else if (h_cnt == H_TOTAL - 1) begin
            if (v_cnt == V_TOTAL - 1)
                v_cnt <= 11'd0;
            else
                v_cnt <= v_cnt + 11'd1;
        end
    end

    // Phát xung ??ng b? HSYNC và VSYNC (Tích c?c m?c th?p)
    always @(posedge vga_clk or posedge rst) begin
        if (rst) begin
            vga_hsync <= 1'b1;
            vga_vsync <= 1'b1;
        end else begin
            vga_hsync <= ~((h_cnt >= (H_ACTIVE + H_FRONT)) && (h_cnt < (H_ACTIVE + H_FRONT + H_SYNC)));
            vga_vsync <= ~((v_cnt >= (V_ACTIVE + V_FRONT)) && (v_cnt < (V_ACTIVE + V_FRONT + V_SYNC)));
        end
    end

    // T?o tín hi?u vùng xóa (Blanking signal)
    assign vga_blank = (h_cnt >= H_ACTIVE) || (v_cnt >= V_ACTIVE);

    // Xu?t t?a ?? pixel hi?n th?i ph?c v? vi?c l?y ?nh t? b? ??m RAM xu?t ra màn hình
    assign pixel_x = (h_cnt < H_ACTIVE) ? h_cnt : 11'd0;
    assign pixel_y = (v_cnt < V_ACTIVE) ? v_cnt : 11'd0;

endmodule
