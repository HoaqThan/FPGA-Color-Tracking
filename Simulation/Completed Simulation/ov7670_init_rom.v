`timescale 1ns/1ps

// OV7670 initialization ROM configured for VGA (640x480) RGB565 streaming.
// Tweaked from QVGA version to disable downsampling/scaling and fix window limits.
module ov7670_init_rom (
    input  wire [7:0] index,
    output reg  [7:0] reg_addr,
    output reg  [7:0] reg_data,
    output reg        valid,
    output reg        last
);

    // Giữ nguyên tổng số lượng câu lệnh nạp register là 133
    localparam [7:0] ROM_LAST = 8'd133;

    always @* begin
        reg_addr = 8'h00;
        reg_data = 8'h00;
        valid    = (index <= ROM_LAST);
        last     = (index == ROM_LAST);

        case (index)
            8'd0: begin reg_addr = 8'h12; reg_data = 8'h80; end // COM7 reset
            8'd1: begin reg_addr = 8'h11; reg_data = 8'h01; end // CLKRC: camera internal clock divider
            8'd2: begin reg_addr = 8'h3A; reg_data = 8'h04; end // TSLB
            
            // --- THAY ĐỔI CHÍNH ĐỂ CẤU HÌNH VGA ---
            8'd3: begin reg_addr = 8'h12; reg_data = 8'h04; end // COM7: CHUYỂN TỪ ĐỂ QVGA (8'h14) THÀNH VGA (8'h04) + RGB
            8'd4: begin reg_addr = 8'h17; reg_data = 8'h13; end // HSTART: Căn lề ngang bắt đầu cho VGA (Chuẩn cũ 8'h16)
            8'd5: begin reg_addr = 8'h18; reg_data = 8'h01; end // HSTOP: Căn lề ngang kết thúc cho VGA (Chuẩn cũ 8'h04)
            8'd6: begin reg_addr = 8'h32; reg_data = 8'hB6; end // HREF: Các bit thấp bổ trợ căn lề ngang (Chuẩn cũ 8'h24)
            8'd7: begin reg_addr = 8'h19; reg_data = 8'h02; end // VSTART: Căn lề dọc bắt đầu
            8'd8: begin reg_addr = 8'h1A; reg_data = 8'h7A; end // VSTOP: Căn lề dọc kết thúc
            8'd9: begin reg_addr = 8'h03; reg_data = 8'h0A; end // VREF low bits
            8'd10: begin reg_addr = 8'h0C; reg_data = 8'h00; end // COM3: Đảm bảo TẮT hoàn toàn scaling (Gộp pixel)
            8'd11: begin reg_addr = 8'h3E; reg_data = 8'h00; end // COM14: CHUYỂN TỪ ĐỂ CHIA CLK QUY ĐỔI (8'h19) THÀNH KHÔNG CHIA (8'h00) CHO VGA
            8'd12: begin reg_addr = 8'h70; reg_data = 8'h3A; end // SCALING_XSC
            8'd13: begin reg_addr = 8'h71; reg_data = 8'h35; end // SCALING_YSC
            8'd14: begin reg_addr = 8'h72; reg_data = 8'h11; end // SCALING_DCWCTR
            8'd15: begin reg_addr = 8'h73; reg_data = 8'hF0; end // SCALING_PCLK_DIV: Tắt bộ chia PCLK (Chuẩn cũ 8'hF1)
            // -------------------------------------

            8'd16: begin reg_addr = 8'hA2; reg_data = 8'h02; end // SCALING_PCLK_DELAY
            8'd17: begin reg_addr = 8'h15; reg_data = 8'h00; end // COM10: HREF/VSYNC normal
            8'd18: begin reg_addr = 8'h8C; reg_data = 8'h00; end // RGB444 disabled
            8'd19: begin reg_addr = 8'h40; reg_data = 8'hD0; end // COM15: full range + RGB565
            8'd20: begin reg_addr = 8'h3D; reg_data = 8'hC0; end // COM13: gamma + UV saturation
            8'd21: begin reg_addr = 8'h7A; reg_data = 8'h20; end // gamma 0
            8'd22: begin reg_addr = 8'h7B; reg_data = 8'h10; end // gamma 1
            8'd23: begin reg_addr = 8'h7C; reg_data = 8'h1E; end // gamma 2
            8'd24: begin reg_addr = 8'h7D; reg_data = 8'h35; end // gamma 3
            8'd25: begin reg_addr = 8'h7E; reg_data = 8'h5A; end // gamma 4
            8'd26: begin reg_addr = 8'h7F; reg_data = 8'h69; end // gamma 5
            8'd27: begin reg_addr = 8'h80; reg_data = 8'h76; end // gamma 6
            8'd28: begin reg_addr = 8'h81; reg_data = 8'h80; end // gamma 7
            8'd29: begin reg_addr = 8'h82; reg_data = 8'h88; end // gamma 8
            8'd30: begin reg_addr = 8'h83; reg_data = 8'h8F; end // gamma 9
            8'd31: begin reg_addr = 8'h84; reg_data = 8'h96; end // gamma 10
            8'd32: begin reg_addr = 8'h85; reg_data = 8'hA3; end // gamma 11
            8'd33: begin reg_addr = 8'h86; reg_data = 8'hAF; end // gamma 12
            8'd34: begin reg_addr = 8'h87; reg_data = 8'hC4; end // gamma 13
            8'd35: begin reg_addr = 8'h88; reg_data = 8'hD7; end // gamma 14
            8'd36: begin reg_addr = 8'h89; reg_data = 8'hE8; end // gamma 15
            8'd37: begin reg_addr = 8'h13; reg_data = 8'hE0; end // COM8: fast AEC + band filter before tuning
            8'd38: begin reg_addr = 8'h00; reg_data = 8'h00; end // GAIN
            8'd39: begin reg_addr = 8'h10; reg_data = 8'h00; end // AECH
            8'd40: begin reg_addr = 8'h0D; reg_data = 8'h40; end // COM4 reserved bit
            8'd41: begin reg_addr = 8'h14; reg_data = 8'h38; end // COM9 gain ceiling
            8'd42: begin reg_addr = 8'hA5; reg_data = 8'h05; end // BD50MAX
            8'd43: begin reg_addr = 8'hAB; reg_data = 8'h07; end // BD60MAX
            8'd44: begin reg_addr = 8'h24; reg_data = 8'h95; end // AEW
            8'd45: begin reg_addr = 8'h25; reg_data = 8'h33; end // AEB
            8'd46: begin reg_addr = 8'h26; reg_data = 8'hE3; end // VPT
            8'd47: begin reg_addr = 8'h9F; reg_data = 8'h78; end // HAECC1
            8'd48: begin reg_addr = 8'hA0; reg_data = 8'h68; end // HAECC2
            8'd49: begin reg_addr = 8'hA1; reg_data = 8'h03; end // magic
            8'd50: begin reg_addr = 8'hA6; reg_data = 8'hD8; end // HAECC3
            8'd51: begin reg_addr = 8'hA7; reg_data = 8'hD8; end // HAECC4
            8'd52: begin reg_addr = 8'hA8; reg_data = 8'hF0; end // HAECC5
            8'd53: begin reg_addr = 8'hA9; reg_data = 8'h90; end // HAECC6
            8'd54: begin reg_addr = 8'hAA; reg_data = 8'h94; end // HAECC7
            8'd55: begin reg_addr = 8'h13; reg_data = 8'hE7; end // COM8: enable AGC/AEC
            8'd56: begin reg_addr = 8'h0E; reg_data = 8'h61; end // COM5
            8'd57: begin reg_addr = 8'h0F; reg_data = 8'h4B; end // COM6
            8'd58: begin reg_addr = 8'h16; reg_data = 8'h02; end // reserved
            8'd59: begin reg_addr = 8'h1E; reg_data = 8'h07; end // MVFP
            8'd60: begin reg_addr = 8'h21; reg_data = 8'h02; end // reserved
            8'd61: begin reg_addr = 8'h22; reg_data = 8'h91; end // reserved
            8'd62: begin reg_addr = 8'h29; reg_data = 8'h07; end // reserved
            8'd63: begin reg_addr = 8'h33; reg_data = 8'h0B; end // reserved
            8'd64: begin reg_addr = 8'h35; reg_data = 8'h0B; end // reserved
            8'd65: begin reg_addr = 8'h37; reg_data = 8'h1D; end // reserved
            8'd66: begin reg_addr = 8'h38; reg_data = 8'h71; end // reserved
            8'd67: begin reg_addr = 8'h39; reg_data = 8'h2A; end // reserved
            8'd68: begin reg_addr = 8'h3C; reg_data = 8'h78; end // COM12
            8'd69: begin reg_addr = 8'h4D; reg_data = 8'h40; end // reserved
            8'd70: begin reg_addr = 8'h4E; reg_data = 8'h20; end // reserved
            8'd71: begin reg_addr = 8'h69; reg_data = 8'h00; end // GFIX
            8'd72: begin reg_addr = 8'h6B; reg_data = 8'h4A; end // DBLV
            8'd73: begin reg_addr = 8'h74; reg_data = 8'h10; end // reserved
            8'd74: begin reg_addr = 8'h8D; reg_data = 8'h4F; end // reserved
            8'd75: begin reg_addr = 8'h8E; reg_data = 8'h00; end // reserved
            8'd76: begin reg_addr = 8'h8F; reg_data = 8'h00; end // reserved
            8'd77: begin reg_addr = 8'h90; reg_data = 8'h00; end // reserved
            8'd78: begin reg_addr = 8'h91; reg_data = 8'h00; end // reserved
            8'd79: begin reg_addr = 8'h96; reg_data = 8'h00; end // reserved
            8'd80: begin reg_addr = 8'h9A; reg_data = 8'h00; end // reserved
            8'd81: begin reg_addr = 8'hB0; reg_data = 8'h84; end // reserved
            8'd82: begin reg_addr = 8'hB1; reg_data = 8'h0C; end // reserved
            8'd83: begin reg_addr = 8'hB2; reg_data = 8'h0E; end // reserved
            8'd84: begin reg_addr = 8'hB3; reg_data = 8'h82; end // reserved
            8'd85: begin reg_addr = 8'hB8; reg_data = 8'h0A; end // reserved
            8'd86: begin reg_addr = 8'h43; reg_data = 8'h0A; end // AWB
            8'd87: begin reg_addr = 8'h44; reg_data = 8'hF0; end // AWB
            8'd88: begin reg_addr = 8'h45; reg_data = 8'h34; end // AWB
            8'd89: begin reg_addr = 8'h46; reg_data = 8'h58; end // AWB
            8'd90: begin reg_addr = 8'h47; reg_data = 8'h28; end // AWB
            8'd91: begin reg_addr = 8'h48; reg_data = 8'h3A; end // AWB
            8'd92: begin reg_addr = 8'h59; reg_data = 8'h88; end // AWB
            8'd93: begin reg_addr = 8'h5A; reg_data = 8'h88; end // AWB
            8'd94: begin reg_addr = 8'h5B; reg_data = 8'h44; end // AWB
            8'd95: begin reg_addr = 8'h5C; reg_data = 8'h67; end // AWB
            8'd96: begin reg_addr = 8'h5D; reg_data = 8'h49; end // AWB
            8'd97: begin reg_addr = 8'h5E; reg_data = 8'h0E; end // AWB
            8'd98: begin reg_addr = 8'h6C; reg_data = 8'h0A; end // AWB
            8'd99: begin reg_addr = 8'h6D; reg_data = 8'h55; end // AWB
            8'd100: begin reg_addr = 8'h6E; reg_data = 8'h11; end // AWB
            8'd101: begin reg_addr = 8'h6F; reg_data = 8'h9F; end // AWB
            8'd102: begin reg_addr = 8'h6A; reg_data = 8'h40; end // AWB
            8'd103: begin reg_addr = 8'h01; reg_data = 8'h40; end // BLUE gain
            8'd104: begin reg_addr = 8'h02; reg_data = 8'h60; end // RED gain
            8'd105: begin reg_addr = 8'h13; reg_data = 8'hE7; end // COM8: AGC/AEC/AWB
            8'd106: begin reg_addr = 8'h4F; reg_data = 8'hB3; end // RGB matrix
            8'd107: begin reg_addr = 8'h50; reg_data = 8'hB3; end // RGB matrix
            8'd108: begin reg_addr = 8'h51; reg_data = 8'h00; end // RGB matrix
            8'd109: begin reg_addr = 8'h52; reg_data = 8'h3D; end // RGB matrix
            8'd110: begin reg_addr = 8'h53; reg_data = 8'hA7; end // RGB matrix
            8'd111: begin reg_addr = 8'h54; reg_data = 8'hE4; end // RGB matrix
            8'd112: begin reg_addr = 8'h58; reg_data = 8'h9E; end // matrix sign
            8'd113: begin reg_addr = 8'h41; reg_data = 8'h38; end // COM16
            8'd114: begin reg_addr = 8'h3F; reg_data = 8'h00; end // EDGE
            8'd115: begin reg_addr = 8'h75; reg_data = 8'h05; end // reserved
            8'd116: begin reg_addr = 8'h76; reg_data = 8'hE1; end // REG76
            8'd117: begin reg_addr = 8'h4C; reg_data = 8'h00; end // reserved
            8'd118: begin reg_addr = 8'h77; reg_data = 8'h01; end // reserved
            8'd119: begin reg_addr = 8'h4B; reg_data = 8'h09; end // reserved
            8'd120: begin reg_addr = 8'hC9; reg_data = 8'h60; end // reserved
            8'd121: begin reg_addr = 8'h56; reg_data = 8'h40; end // contrast
            8'd122: begin reg_addr = 8'h34; reg_data = 8'h11; end // reserved
            8'd123: begin reg_addr = 8'h3B; reg_data = 8'h12; end // COM11 auto 50/60 + exposure
            8'd124: begin reg_addr = 8'hA4; reg_data = 8'h88; end // reserved
            8'd125: begin reg_addr = 8'h96; reg_data = 8'h00; end // reserved
            8'd126: begin reg_addr = 8'h97; reg_data = 8'h30; end // reserved
            8'd127: begin reg_addr = 8'h98; reg_data = 8'h20; end // reserved
            8'd128: begin reg_addr = 8'h99; reg_data = 8'h30; end // reserved
            8'd129: begin reg_addr = 8'h9A; reg_data = 8'h84; end // reserved
            8'd130: begin reg_addr = 8'h9B; reg_data = 8'h29; end // reserved
            8'd131: begin reg_addr = 8'h9C; reg_data = 8'h03; end // reserved
            8'd132: begin reg_addr = 8'h9D; reg_data = 8'h4C; end // reserved
            8'd133: begin reg_addr = 8'h9E; reg_data = 8'h3F; end // reserved
            default: begin reg_addr = 8'h00; reg_data = 8'h00; end
        endcase
    end

endmodule