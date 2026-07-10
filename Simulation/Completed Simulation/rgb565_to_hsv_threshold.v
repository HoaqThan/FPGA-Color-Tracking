`timescale 1ns/1ps

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

    // --- Tách kênh màu sang 8-bit chu?n ---
    wire [7:0] r8 = {rgb565[15:11], rgb565[15:13]};
    wire [7:0] g8 = {rgb565[10:5],  rgb565[10:9]};
    wire [7:0] b8 = {rgb565[4:0],   rgb565[4:2]};

    // --- T?NG VÀO 1: Tìm Max, Min và Delta ---
    reg [7:0] max_rgb;
    reg [7:0] min_rgb;
    reg [7:0] delta;
    reg [7:0] r8_d1, g8_d1, b8_d1;
    reg       vld_d1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            max_rgb <= 8'd0;
            min_rgb <= 8'd0;
            delta   <= 8'd0;
            r8_d1   <= 8'd0;
            g8_d1   <= 8'd0;
            b8_d1   <= 8'd0;
            vld_d1  <= 1'b0;
        end else begin
            vld_d1 <= pixel_valid;
            if (pixel_valid) begin
                r8_d1 <= r8;
                g8_d1 <= g8;
                b8_d1 <= b8;

                // Tìm Max
                if (r8 >= g8 && r8 >= b8)      max_rgb <= r8;
                else if (g8 >= r8 && g8 >= b8) max_rgb <= g8;
                else                           max_rgb <= b8;

                // Tìm Min
                if (r8 <= g8 && r8 <= b8)      min_rgb <= r8;
                else if (g8 <= r8 && g8 <= b8) min_rgb <= g8;
                else                           min_rgb <= b8;

                // Tính Delta
                delta <= (r8 >= g8 && r8 >= b8 ? r8 : (g8 >= r8 && g8 >= b8 ? g8 : b8)) - 
                         (r8 <= g8 && r8 <= b8 ? r8 : (g8 <= r8 && g8 <= b8 ? g8 : b8));
            end
        end
    end

    // --- B?NG TRA C?U NGH?CH ??O CHO DELTA (THAY PHÉP CHIA C?A HUE) ---
    // Công th?c tính tr??c: inv_div = (1 << 14) / delta = 16384 / delta
    reg [14:0] inv_div;
    always @* begin
        case (delta)
            8'd0:    inv_div = 15'd0;
            8'd1:    inv_div = 15'd16384; 8'd2:    inv_div = 15'd8192;  8'd3:    inv_div = 15'd5461;
            8'd4:    inv_div = 15'd4096;  8'd5:    inv_div = 15'd3276;  8'd6:    inv_div = 15'd2730;
            8'd7:    inv_div = 15'd2340;  8'd8:    inv_div = 15'd2048;  8'd9:    inv_div = 15'd1820;
            8'd10:   inv_div = 15'd1638;  8'd11:   inv_div = 15'd1489;  8'd12:   inv_div = 15'd1365;
            8'd13:   inv_div = 15'd1260;  8'd14:   inv_div = 15'd1170;  8'd15:   inv_div = 15'd1092;
            8'd16:   inv_div = 15'd1024;  8'd17:   inv_div = 15'd963;   8'd18:   inv_div = 15'd910;
            8'd19:   inv_div = 15'd862;   8'd20:   inv_div = 15'd819;   8'd21:   inv_div = 15'd780;
            8'd22:   inv_div = 15'd744;   8'd23:   inv_div = 15'd712;   8'd24:   inv_div = 15'd682;
            8'd25:   inv_div = 15'd655;   8'd26:   inv_div = 15'd630;   8'd27:   inv_div = 15'd606;
            8'd28:   inv_div = 15'd585;   8'd29:   inv_div = 15'd564;   8'd30:   inv_div = 15'd546;
            8'd31:   inv_div = 15'd528;   8'd32:   inv_div = 15'd512;   8'd33:   inv_div = 15'd496;
            8'd34:   inv_div = 15'd481;   8'd35:   inv_div = 15'd468;   8'd36:   inv_div = 15'd455;
            8'd37:   inv_div = 15'd442;   8'd38:   inv_div = 15'd431;   8'd39:   inv_div = 15'd420;
            8'd40:   inv_div = 15'd409;   default: inv_div = 15'd409; 
        endcase
    end

    // --- B?NG TRA C?U NGH?CH ??O CHO MAX_RGB (THAY PHÉP CHIA C?A SATURATION) ---
    // Công th?c tính tr??c: inv_max = 16384 / max_rgb
    reg [14:0] inv_max;
    always @* begin
        case (max_rgb)
            8'd0:    inv_max = 15'd0;
            8'd1:    inv_max = 15'd16384; 8'd2:    inv_max = 15'd8192;  8'd3:    inv_max = 15'd5461;
            8'd4:    inv_max = 15'd4096;  8'd5:    inv_max = 15'd3276;  8'd6:    inv_max = 15'd2730;
            8'd7:    inv_max = 15'd2340;  8'd8:    inv_max = 15'd2048;  8'd9:    inv_max = 15'd1820;
            8'd10:   inv_max = 15'd1638;  8'd11:   inv_max = 15'd1489;  8'd12:   inv_max = 15'd1365;
            8'd13:   inv_max = 15'd1260;  8'd14:   inv_max = 15'd1170;  8'd15:   inv_max = 15'd1092;
            8'd16:   inv_max = 15'd1024;  8'd17:   inv_max = 15'd963;   8'd18:   inv_max = 15'd910;
            8'd19:   inv_max = 15'd862;   8'd20:   inv_max = 15'd819;   8'd21:   inv_max = 15'd780;
            8'd22:   inv_max = 15'd744;   8'd23:   inv_max = 15'd712;   8'd24:   inv_max = 15'd682;
            8'd25:   inv_max = 15'd655;   8'd26:   inv_max = 15'd630;   8'd27:   inv_max = 15'd606;
            8'd28:   inv_max = 15'd585;   8'd29:   inv_max = 15'd564;   8'd30:   inv_max = 15'd546;
            8'd31:   inv_max = 15'd528;   8'd32:   inv_max = 15'd512;   8'd33:   inv_max = 15'd496;
            8'd34:   inv_max = 15'd481;   8'd35:   inv_max = 15'd468;   8'd36:   inv_max = 15'd455;
            8'd37:   inv_max = 15'd442;   8'd38:   inv_max = 15'd431;   8'd39:   inv_max = 15'd420;
            default: begin
                if (max_rgb >= 8'd40 && max_rgb < 8'd80)       inv_max = 15'd273;  // Ngh?ch ??o trung bình d?i
                else if (max_rgb >= 8'd80 && max_rgb < 8'd160)  inv_max = 15'd136;
                else                                            inv_max = 15'd70;
            end
        endcase
    end

    // Các bi?n ph? x? lý t? h?p hình h?c màu s?c
    reg signed [23:0] h_prod;
    reg signed [15:0] h_tmp;
    reg [7:0] h_nxt;
    reg [7:0] s_nxt;
    reg [7:0] v_nxt;
    reg       h_in_range;
    reg       s_in_range;
    reg       v_in_range;

    // --- T?NG X? LÝ 2: Tính toán HSV và Phân ng??ng (Dùng Nhân + D?ch bit ph?i 14) ---
    always @* begin
        h_tmp  = 16'sh0;
        h_nxt  = 8'd0;
        h_prod = 24'd0;
        v_nxt  = max_rgb;

        // Tính toán Saturation (S) - Không dùng phép chia
        if (max_rgb == 8'd0) begin
            s_nxt = 8'd0;
        end else begin
            s_nxt = ((delta * 255 * inv_max) >> 14);
            if (s_nxt > 8'd255) s_nxt = 8'd255;
        end

        // Tính toán Hue (H) - Không dùng phép chia
        if (delta == 8'd0) begin
            h_tmp = 0;
        end else if (max_rgb == r8_d1) begin
            if (g8_d1 >= b8_d1) begin
                h_prod = (g8_d1 - b8_d1) * 30 * inv_div;
                h_tmp  = h_prod >> 14;
            end else begin
                h_prod = (r8_d1 - b8_d1) * 30 * inv_div;
                h_tmp  = 60 - (h_prod >> 14);
            end
        end else if (max_rgb == g8_d1) begin
            if (r8_d1 >= b8_d1) begin
                h_prod = (r8_d1 - b8_d1) * 30 * inv_div;
                h_tmp  = 120 + (h_prod >> 14);
            end else begin
                h_prod = (b8_d1 - r8_d1) * 30 * inv_div;
                h_tmp  = 120 - (h_prod >> 14);
            end
        end else begin
            if (r8_d1 >= g8_d1) begin
                h_prod = (r8_d1 - g8_d1) * 30 * inv_div;
                h_tmp  = 120 + (h_prod >> 14);
            end else begin
                h_prod = (g8_d1 - r8_d1) * 30 * inv_div;
                h_tmp  = 120 - (h_prod >> 14);
            end
        end

        // Chu?n hóa góc Hue v? d?i [0, 179]
        if (h_tmp < 0)         h_nxt = h_tmp + 180;
        else if (h_tmp >= 180) h_nxt = h_tmp - 180;
        else                   h_nxt = h_tmp[7:0];

        // Ki?m tra ?i?u ki?n c?t ng??ng l?c d?i màu
        if (H_MIN <= H_MAX) h_in_range = (h_nxt >= H_MIN) && (h_nxt <= H_MAX);
        else                h_in_range = (h_nxt >= H_MIN) || (h_nxt <= H_MAX);

        s_in_range = (s_nxt >= S_MIN) && (s_nxt <= S_MAX);
        v_in_range = (v_nxt >= V_MIN) && (v_nxt <= V_MAX);
    end

    // --- T?NG RA 3: Gán ch?t d? li?u ??ng b? s??n lên clock ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hue        <= 8'd0;
            sat        <= 8'd0;
            val        <= 8'd0;
            mask       <= 1'b0;
            mask_valid <= 1'b0;
        end else begin
            mask_valid <= vld_d1;
            if (vld_d1) begin
                hue  <= h_nxt;
                sat  <= s_nxt;
                val  <= v_nxt;
                mask <= (h_in_range && s_in_range && v_in_range);
            end
        end
    end

endmodule
