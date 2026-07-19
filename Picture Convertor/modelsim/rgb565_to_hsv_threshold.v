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

    // --- T?NG VÀO 1: T́m Max, Min và Delta ---
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

                // T́m Max
                if (r8 >= g8 && r8 >= b8)      max_rgb <= r8;
                else if (g8 >= r8 && g8 >= b8) max_rgb <= g8;
                else                           max_rgb <= b8;

                // T́m Min
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
            8'd1:    inv_div = 15'd16384;
            8'd2:    inv_div = 15'd8192;
            8'd3:    inv_div = 15'd5461;
            8'd4:    inv_div = 15'd4096;
            8'd5:    inv_div = 15'd3276;
            8'd6:    inv_div = 15'd2730;
            8'd7:    inv_div = 15'd2340;
            8'd8:    inv_div = 15'd2048;
            8'd9:    inv_div = 15'd1820;
            8'd10:    inv_div = 15'd1638;
            8'd11:    inv_div = 15'd1489;
            8'd12:    inv_div = 15'd1365;
            8'd13:    inv_div = 15'd1260;
            8'd14:    inv_div = 15'd1170;
            8'd15:    inv_div = 15'd1092;
            8'd16:    inv_div = 15'd1024;
            8'd17:    inv_div = 15'd963;
            8'd18:    inv_div = 15'd910;
            8'd19:    inv_div = 15'd862;
            8'd20:    inv_div = 15'd819;
            8'd21:    inv_div = 15'd780;
            8'd22:    inv_div = 15'd744;
            8'd23:    inv_div = 15'd712;
            8'd24:    inv_div = 15'd682;
            8'd25:    inv_div = 15'd655;
            8'd26:    inv_div = 15'd630;
            8'd27:    inv_div = 15'd606;
            8'd28:    inv_div = 15'd585;
            8'd29:    inv_div = 15'd564;
            8'd30:    inv_div = 15'd546;
            8'd31:    inv_div = 15'd528;
            8'd32:    inv_div = 15'd512;
            8'd33:    inv_div = 15'd496;
            8'd34:    inv_div = 15'd481;
            8'd35:    inv_div = 15'd468;
            8'd36:    inv_div = 15'd455;
            8'd37:    inv_div = 15'd442;
            8'd38:    inv_div = 15'd431;
            8'd39:    inv_div = 15'd420;
            8'd40:    inv_div = 15'd409;
            8'd41:    inv_div = 15'd399;
            8'd42:    inv_div = 15'd390;
            8'd43:    inv_div = 15'd381;
            8'd44:    inv_div = 15'd372;
            8'd45:    inv_div = 15'd364;
            8'd46:    inv_div = 15'd356;
            8'd47:    inv_div = 15'd348;
            8'd48:    inv_div = 15'd341;
            8'd49:    inv_div = 15'd334;
            8'd50:    inv_div = 15'd327;
            8'd51:    inv_div = 15'd321;
            8'd52:    inv_div = 15'd315;
            8'd53:    inv_div = 15'd309;
            8'd54:    inv_div = 15'd303;
            8'd55:    inv_div = 15'd297;
            8'd56:    inv_div = 15'd292;
            8'd57:    inv_div = 15'd287;
            8'd58:    inv_div = 15'd282;
            8'd59:    inv_div = 15'd277;
            8'd60:    inv_div = 15'd273;
            8'd61:    inv_div = 15'd268;
            8'd62:    inv_div = 15'd264;
            8'd63:    inv_div = 15'd260;
            8'd64:    inv_div = 15'd256;
            8'd65:    inv_div = 15'd252;
            8'd66:    inv_div = 15'd248;
            8'd67:    inv_div = 15'd244;
            8'd68:    inv_div = 15'd240;
            8'd69:    inv_div = 15'd237;
            8'd70:    inv_div = 15'd234;
            8'd71:    inv_div = 15'd230;
            8'd72:    inv_div = 15'd227;
            8'd73:    inv_div = 15'd224;
            8'd74:    inv_div = 15'd221;
            8'd75:    inv_div = 15'd218;
            8'd76:    inv_div = 15'd215;
            8'd77:    inv_div = 15'd212;
            8'd78:    inv_div = 15'd210;
            8'd79:    inv_div = 15'd207;
            8'd80:    inv_div = 15'd204;
            8'd81:    inv_div = 15'd202;
            8'd82:    inv_div = 15'd199;
            8'd83:    inv_div = 15'd197;
            8'd84:    inv_div = 15'd195;
            8'd85:    inv_div = 15'd192;
            8'd86:    inv_div = 15'd190;
            8'd87:    inv_div = 15'd188;
            8'd88:    inv_div = 15'd186;
            8'd89:    inv_div = 15'd184;
            8'd90:    inv_div = 15'd182;
            8'd91:    inv_div = 15'd180;
            8'd92:    inv_div = 15'd178;
            8'd93:    inv_div = 15'd176;
            8'd94:    inv_div = 15'd174;
            8'd95:    inv_div = 15'd172;
            8'd96:    inv_div = 15'd170;
            8'd97:    inv_div = 15'd168;
            8'd98:    inv_div = 15'd167;
            8'd99:    inv_div = 15'd165;
            8'd100:    inv_div = 15'd163;
            8'd101:    inv_div = 15'd162;
            8'd102:    inv_div = 15'd160;
            8'd103:    inv_div = 15'd159;
            8'd104:    inv_div = 15'd157;
            8'd105:    inv_div = 15'd156;
            8'd106:    inv_div = 15'd154;
            8'd107:    inv_div = 15'd153;
            8'd108:    inv_div = 15'd151;
            8'd109:    inv_div = 15'd150;
            8'd110:    inv_div = 15'd148;
            8'd111:    inv_div = 15'd147;
            8'd112:    inv_div = 15'd146;
            8'd113:    inv_div = 15'd144;
            8'd114:    inv_div = 15'd143;
            8'd115:    inv_div = 15'd142;
            8'd116:    inv_div = 15'd141;
            8'd117:    inv_div = 15'd140;
            8'd118:    inv_div = 15'd138;
            8'd119:    inv_div = 15'd137;
            8'd120:    inv_div = 15'd136;
            8'd121:    inv_div = 15'd135;
            8'd122:    inv_div = 15'd134;
            8'd123:    inv_div = 15'd133;
            8'd124:    inv_div = 15'd132;
            8'd125:    inv_div = 15'd131;
            8'd126:    inv_div = 15'd130;
            8'd127:    inv_div = 15'd129;
            8'd128:    inv_div = 15'd128;
            8'd129:    inv_div = 15'd127;
            8'd130:    inv_div = 15'd126;
            8'd131:    inv_div = 15'd125;
            8'd132:    inv_div = 15'd124;
            8'd133:    inv_div = 15'd123;
            8'd134:    inv_div = 15'd122;
            8'd135:    inv_div = 15'd121;
            8'd136:    inv_div = 15'd120;
            8'd137:    inv_div = 15'd119;
            8'd138:    inv_div = 15'd118;
            8'd139:    inv_div = 15'd117;
            8'd140:    inv_div = 15'd117;
            8'd141:    inv_div = 15'd116;
            8'd142:    inv_div = 15'd115;
            8'd143:    inv_div = 15'd114;
            8'd144:    inv_div = 15'd113;
            8'd145:    inv_div = 15'd112;
            8'd146:    inv_div = 15'd112;
            8'd147:    inv_div = 15'd111;
            8'd148:    inv_div = 15'd110;
            8'd149:    inv_div = 15'd109;
            8'd150:    inv_div = 15'd109;
            8'd151:    inv_div = 15'd108;
            8'd152:    inv_div = 15'd107;
            8'd153:    inv_div = 15'd107;
            8'd154:    inv_div = 15'd106;
            8'd155:    inv_div = 15'd105;
            8'd156:    inv_div = 15'd105;
            8'd157:    inv_div = 15'd104;
            8'd158:    inv_div = 15'd103;
            8'd159:    inv_div = 15'd103;
            8'd160:    inv_div = 15'd102;
            8'd161:    inv_div = 15'd101;
            8'd162:    inv_div = 15'd101;
            8'd163:    inv_div = 15'd100;
            8'd164:    inv_div = 15'd99;
            8'd165:    inv_div = 15'd99;
            8'd166:    inv_div = 15'd98;
            8'd167:    inv_div = 15'd98;
            8'd168:    inv_div = 15'd97;
            8'd169:    inv_div = 15'd96;
            8'd170:    inv_div = 15'd96;
            8'd171:    inv_div = 15'd95;
            8'd172:    inv_div = 15'd95;
            8'd173:    inv_div = 15'd94;
            8'd174:    inv_div = 15'd94;
            8'd175:    inv_div = 15'd93;
            8'd176:    inv_div = 15'd93;
            8'd177:    inv_div = 15'd92;
            8'd178:    inv_div = 15'd92;
            8'd179:    inv_div = 15'd91;
            8'd180:    inv_div = 15'd91;
            8'd181:    inv_div = 15'd90;
            8'd182:    inv_div = 15'd90;
            8'd183:    inv_div = 15'd89;
            8'd184:    inv_div = 15'd89;
            8'd185:    inv_div = 15'd88;
            8'd186:    inv_div = 15'd88;
            8'd187:    inv_div = 15'd87;
            8'd188:    inv_div = 15'd87;
            8'd189:    inv_div = 15'd86;
            8'd190:    inv_div = 15'd86;
            8'd191:    inv_div = 15'd85;
            8'd192:    inv_div = 15'd85;
            8'd193:    inv_div = 15'd84;
            8'd194:    inv_div = 15'd84;
            8'd195:    inv_div = 15'd84;
            8'd196:    inv_div = 15'd83;
            8'd197:    inv_div = 15'd83;
            8'd198:    inv_div = 15'd82;
            8'd199:    inv_div = 15'd82;
            8'd200:    inv_div = 15'd81;
            8'd201:    inv_div = 15'd81;
            8'd202:    inv_div = 15'd81;
            8'd203:    inv_div = 15'd80;
            8'd204:    inv_div = 15'd80;
            8'd205:    inv_div = 15'd79;
            8'd206:    inv_div = 15'd79;
            8'd207:    inv_div = 15'd79;
            8'd208:    inv_div = 15'd78;
            8'd209:    inv_div = 15'd78;
            8'd210:    inv_div = 15'd78;
            8'd211:    inv_div = 15'd77;
            8'd212:    inv_div = 15'd77;
            8'd213:    inv_div = 15'd76;
            8'd214:    inv_div = 15'd76;
            8'd215:    inv_div = 15'd76;
            8'd216:    inv_div = 15'd75;
            8'd217:    inv_div = 15'd75;
            8'd218:    inv_div = 15'd75;
            8'd219:    inv_div = 15'd74;
            8'd220:    inv_div = 15'd74;
            8'd221:    inv_div = 15'd74;
            8'd222:    inv_div = 15'd73;
            8'd223:    inv_div = 15'd73;
            8'd224:    inv_div = 15'd73;
            8'd225:    inv_div = 15'd72;
            8'd226:    inv_div = 15'd72;
            8'd227:    inv_div = 15'd72;
            8'd228:    inv_div = 15'd71;
            8'd229:    inv_div = 15'd71;
            8'd230:    inv_div = 15'd71;
            8'd231:    inv_div = 15'd70;
            8'd232:    inv_div = 15'd70;
            8'd233:    inv_div = 15'd70;
            8'd234:    inv_div = 15'd70;
            8'd235:    inv_div = 15'd69;
            8'd236:    inv_div = 15'd69;
            8'd237:    inv_div = 15'd69;
            8'd238:    inv_div = 15'd68;
            8'd239:    inv_div = 15'd68;
            8'd240:    inv_div = 15'd68;
            8'd241:    inv_div = 15'd67;
            8'd242:    inv_div = 15'd67;
            8'd243:    inv_div = 15'd67;
            8'd244:    inv_div = 15'd67;
            8'd245:    inv_div = 15'd66;
            8'd246:    inv_div = 15'd66;
            8'd247:    inv_div = 15'd66;
            8'd248:    inv_div = 15'd66;
            8'd249:    inv_div = 15'd65;
            8'd250:    inv_div = 15'd65;
            8'd251:    inv_div = 15'd65;
            8'd252:    inv_div = 15'd65;
            8'd253:    inv_div = 15'd64;
            8'd254:    inv_div = 15'd64;
            8'd255:    inv_div = 15'd64;
        endcase
    end

    // --- B?NG TRA C?U NGH?CH ??O CHO MAX_RGB (THAY PHÉP CHIA C?A SATURATION) ---
    // Công th?c tính tr??c: inv_max = 16384 / max_rgb
    reg [14:0] inv_max;
    always @* begin
        case (max_rgb)
            8'd0:    inv_max = 15'd0;
            8'd1:    inv_max = 15'd16384;
            8'd2:    inv_max = 15'd8192;
            8'd3:    inv_max = 15'd5461;
            8'd4:    inv_max = 15'd4096;
            8'd5:    inv_max = 15'd3276;
            8'd6:    inv_max = 15'd2730;
            8'd7:    inv_max = 15'd2340;
            8'd8:    inv_max = 15'd2048;
            8'd9:    inv_max = 15'd1820;
            8'd10:    inv_max = 15'd1638;
            8'd11:    inv_max = 15'd1489;
            8'd12:    inv_max = 15'd1365;
            8'd13:    inv_max = 15'd1260;
            8'd14:    inv_max = 15'd1170;
            8'd15:    inv_max = 15'd1092;
            8'd16:    inv_max = 15'd1024;
            8'd17:    inv_max = 15'd963;
            8'd18:    inv_max = 15'd910;
            8'd19:    inv_max = 15'd862;
            8'd20:    inv_max = 15'd819;
            8'd21:    inv_max = 15'd780;
            8'd22:    inv_max = 15'd744;
            8'd23:    inv_max = 15'd712;
            8'd24:    inv_max = 15'd682;
            8'd25:    inv_max = 15'd655;
            8'd26:    inv_max = 15'd630;
            8'd27:    inv_max = 15'd606;
            8'd28:    inv_max = 15'd585;
            8'd29:    inv_max = 15'd564;
            8'd30:    inv_max = 15'd546;
            8'd31:    inv_max = 15'd528;
            8'd32:    inv_max = 15'd512;
            8'd33:    inv_max = 15'd496;
            8'd34:    inv_max = 15'd481;
            8'd35:    inv_max = 15'd468;
            8'd36:    inv_max = 15'd455;
            8'd37:    inv_max = 15'd442;
            8'd38:    inv_max = 15'd431;
            8'd39:    inv_max = 15'd420;
            8'd40:    inv_max = 15'd409;
            8'd41:    inv_max = 15'd399;
            8'd42:    inv_max = 15'd390;
            8'd43:    inv_max = 15'd381;
            8'd44:    inv_max = 15'd372;
            8'd45:    inv_max = 15'd364;
            8'd46:    inv_max = 15'd356;
            8'd47:    inv_max = 15'd348;
            8'd48:    inv_max = 15'd341;
            8'd49:    inv_max = 15'd334;
            8'd50:    inv_max = 15'd327;
            8'd51:    inv_max = 15'd321;
            8'd52:    inv_max = 15'd315;
            8'd53:    inv_max = 15'd309;
            8'd54:    inv_max = 15'd303;
            8'd55:    inv_max = 15'd297;
            8'd56:    inv_max = 15'd292;
            8'd57:    inv_max = 15'd287;
            8'd58:    inv_max = 15'd282;
            8'd59:    inv_max = 15'd277;
            8'd60:    inv_max = 15'd273;
            8'd61:    inv_max = 15'd268;
            8'd62:    inv_max = 15'd264;
            8'd63:    inv_max = 15'd260;
            8'd64:    inv_max = 15'd256;
            8'd65:    inv_max = 15'd252;
            8'd66:    inv_max = 15'd248;
            8'd67:    inv_max = 15'd244;
            8'd68:    inv_max = 15'd240;
            8'd69:    inv_max = 15'd237;
            8'd70:    inv_max = 15'd234;
            8'd71:    inv_max = 15'd230;
            8'd72:    inv_max = 15'd227;
            8'd73:    inv_max = 15'd224;
            8'd74:    inv_max = 15'd221;
            8'd75:    inv_max = 15'd218;
            8'd76:    inv_max = 15'd215;
            8'd77:    inv_max = 15'd212;
            8'd78:    inv_max = 15'd210;
            8'd79:    inv_max = 15'd207;
            8'd80:    inv_max = 15'd204;
            8'd81:    inv_max = 15'd202;
            8'd82:    inv_max = 15'd199;
            8'd83:    inv_max = 15'd197;
            8'd84:    inv_max = 15'd195;
            8'd85:    inv_max = 15'd192;
            8'd86:    inv_max = 15'd190;
            8'd87:    inv_max = 15'd188;
            8'd88:    inv_max = 15'd186;
            8'd89:    inv_max = 15'd184;
            8'd90:    inv_max = 15'd182;
            8'd91:    inv_max = 15'd180;
            8'd92:    inv_max = 15'd178;
            8'd93:    inv_max = 15'd176;
            8'd94:    inv_max = 15'd174;
            8'd95:    inv_max = 15'd172;
            8'd96:    inv_max = 15'd170;
            8'd97:    inv_max = 15'd168;
            8'd98:    inv_max = 15'd167;
            8'd99:    inv_max = 15'd165;
            8'd100:    inv_max = 15'd163;
            8'd101:    inv_max = 15'd162;
            8'd102:    inv_max = 15'd160;
            8'd103:    inv_max = 15'd159;
            8'd104:    inv_max = 15'd157;
            8'd105:    inv_max = 15'd156;
            8'd106:    inv_max = 15'd154;
            8'd107:    inv_max = 15'd153;
            8'd108:    inv_max = 15'd151;
            8'd109:    inv_max = 15'd150;
            8'd110:    inv_max = 15'd148;
            8'd111:    inv_max = 15'd147;
            8'd112:    inv_max = 15'd146;
            8'd113:    inv_max = 15'd144;
            8'd114:    inv_max = 15'd143;
            8'd115:    inv_max = 15'd142;
            8'd116:    inv_max = 15'd141;
            8'd117:    inv_max = 15'd140;
            8'd118:    inv_max = 15'd138;
            8'd119:    inv_max = 15'd137;
            8'd120:    inv_max = 15'd136;
            8'd121:    inv_max = 15'd135;
            8'd122:    inv_max = 15'd134;
            8'd123:    inv_max = 15'd133;
            8'd124:    inv_max = 15'd132;
            8'd125:    inv_max = 15'd131;
            8'd126:    inv_max = 15'd130;
            8'd127:    inv_max = 15'd129;
            8'd128:    inv_max = 15'd128;
            8'd129:    inv_max = 15'd127;
            8'd130:    inv_max = 15'd126;
            8'd131:    inv_max = 15'd125;
            8'd132:    inv_max = 15'd124;
            8'd133:    inv_max = 15'd123;
            8'd134:    inv_max = 15'd122;
            8'd135:    inv_max = 15'd121;
            8'd136:    inv_max = 15'd120;
            8'd137:    inv_max = 15'd119;
            8'd138:    inv_max = 15'd118;
            8'd139:    inv_max = 15'd117;
            8'd140:    inv_max = 15'd117;
            8'd141:    inv_max = 15'd116;
            8'd142:    inv_max = 15'd115;
            8'd143:    inv_max = 15'd114;
            8'd144:    inv_max = 15'd113;
            8'd145:    inv_max = 15'd112;
            8'd146:    inv_max = 15'd112;
            8'd147:    inv_max = 15'd111;
            8'd148:    inv_max = 15'd110;
            8'd149:    inv_max = 15'd109;
            8'd150:    inv_max = 15'd109;
            8'd151:    inv_max = 15'd108;
            8'd152:    inv_max = 15'd107;
            8'd153:    inv_max = 15'd107;
            8'd154:    inv_max = 15'd106;
            8'd155:    inv_max = 15'd105;
            8'd156:    inv_max = 15'd105;
            8'd157:    inv_max = 15'd104;
            8'd158:    inv_max = 15'd103;
            8'd159:    inv_max = 15'd103;
            8'd160:    inv_max = 15'd102;
            8'd161:    inv_max = 15'd101;
            8'd162:    inv_max = 15'd101;
            8'd163:    inv_max = 15'd100;
            8'd164:    inv_max = 15'd99;
            8'd165:    inv_max = 15'd99;
            8'd166:    inv_max = 15'd98;
            8'd167:    inv_max = 15'd98;
            8'd168:    inv_max = 15'd97;
            8'd169:    inv_max = 15'd96;
            8'd170:    inv_max = 15'd96;
            8'd171:    inv_max = 15'd95;
            8'd172:    inv_max = 15'd95;
            8'd173:    inv_max = 15'd94;
            8'd174:    inv_max = 15'd94;
            8'd175:    inv_max = 15'd93;
            8'd176:    inv_max = 15'd93;
            8'd177:    inv_max = 15'd92;
            8'd178:    inv_max = 15'd92;
            8'd179:    inv_max = 15'd91;
            8'd180:    inv_max = 15'd91;
            8'd181:    inv_max = 15'd90;
            8'd182:    inv_max = 15'd90;
            8'd183:    inv_max = 15'd89;
            8'd184:    inv_max = 15'd89;
            8'd185:    inv_max = 15'd88;
            8'd186:    inv_max = 15'd88;
            8'd187:    inv_max = 15'd87;
            8'd188:    inv_max = 15'd87;
            8'd189:    inv_max = 15'd86;
            8'd190:    inv_max = 15'd86;
            8'd191:    inv_max = 15'd85;
            8'd192:    inv_max = 15'd85;
            8'd193:    inv_max = 15'd84;
            8'd194:    inv_max = 15'd84;
            8'd195:    inv_max = 15'd84;
            8'd196:    inv_max = 15'd83;
            8'd197:    inv_max = 15'd83;
            8'd198:    inv_max = 15'd82;
            8'd199:    inv_max = 15'd82;
            8'd200:    inv_max = 15'd81;
            8'd201:    inv_max = 15'd81;
            8'd202:    inv_max = 15'd81;
            8'd203:    inv_max = 15'd80;
            8'd204:    inv_max = 15'd80;
            8'd205:    inv_max = 15'd79;
            8'd206:    inv_max = 15'd79;
            8'd207:    inv_max = 15'd79;
            8'd208:    inv_max = 15'd78;
            8'd209:    inv_max = 15'd78;
            8'd210:    inv_max = 15'd78;
            8'd211:    inv_max = 15'd77;
            8'd212:    inv_max = 15'd77;
            8'd213:    inv_max = 15'd76;
            8'd214:    inv_max = 15'd76;
            8'd215:    inv_max = 15'd76;
            8'd216:    inv_max = 15'd75;
            8'd217:    inv_max = 15'd75;
            8'd218:    inv_max = 15'd75;
            8'd219:    inv_max = 15'd74;
            8'd220:    inv_max = 15'd74;
            8'd221:    inv_max = 15'd74;
            8'd222:    inv_max = 15'd73;
            8'd223:    inv_max = 15'd73;
            8'd224:    inv_max = 15'd73;
            8'd225:    inv_max = 15'd72;
            8'd226:    inv_max = 15'd72;
            8'd227:    inv_max = 15'd72;
            8'd228:    inv_max = 15'd71;
            8'd229:    inv_max = 15'd71;
            8'd230:    inv_max = 15'd71;
            8'd231:    inv_max = 15'd70;
            8'd232:    inv_max = 15'd70;
            8'd233:    inv_max = 15'd70;
            8'd234:    inv_max = 15'd70;
            8'd235:    inv_max = 15'd69;
            8'd236:    inv_max = 15'd69;
            8'd237:    inv_max = 15'd69;
            8'd238:    inv_max = 15'd68;
            8'd239:    inv_max = 15'd68;
            8'd240:    inv_max = 15'd68;
            8'd241:    inv_max = 15'd67;
            8'd242:    inv_max = 15'd67;
            8'd243:    inv_max = 15'd67;
            8'd244:    inv_max = 15'd67;
            8'd245:    inv_max = 15'd66;
            8'd246:    inv_max = 15'd66;
            8'd247:    inv_max = 15'd66;
            8'd248:    inv_max = 15'd66;
            8'd249:    inv_max = 15'd65;
            8'd250:    inv_max = 15'd65;
            8'd251:    inv_max = 15'd65;
            8'd252:    inv_max = 15'd65;
            8'd253:    inv_max = 15'd64;
            8'd254:    inv_max = 15'd64;
            8'd255:    inv_max = 15'd64;
        endcase
    end

    // Các bi?n ph? x? lư t? h?p h́nh h?c màu s?c
    reg signed [31:0] h_prod;
    reg signed [15:0] h_tmp;
    reg [7:0] h_nxt;
    reg [15:0] s_raw;
    reg [7:0] s_nxt;
    reg [7:0] v_nxt;
    reg       h_in_range;
    reg       s_in_range;
    reg       v_in_range;

    // --- T?NG X? LƯ 2: Tính toán HSV và Phân ng??ng (Dùng Nhân + D?ch bit ph?i 14) ---
    always @* begin
        h_tmp  = 16'sh0;
        h_nxt  = 8'd0;
        h_prod = 24'd0;
        v_nxt  = max_rgb;

        // Tính toán Saturation (S) - Không dùng phép chia
        if (max_rgb == 8'd0) begin
            s_raw = 16'd0;
            s_nxt = 8'd0;
        end else begin
            s_raw = ((delta * 255 * inv_max) >> 14);
            s_nxt = (s_raw > 255) ? 8'd255 : s_raw[7:0];
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
            if (b8_d1 >= r8_d1) begin
                h_prod = (b8_d1 - r8_d1) * 30 * inv_div;
                h_tmp  = 60 + (h_prod >> 14);
            end else begin
                h_prod = (r8_d1 - b8_d1) * 30 * inv_div;
                h_tmp  = 60 - (h_prod >> 14);
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
