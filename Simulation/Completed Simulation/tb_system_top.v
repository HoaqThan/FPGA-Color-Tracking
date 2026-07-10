`timescale 1ns/1ps

module tb_system_top;

    // --- Thông s? h? th?ng (Chu?n VGA) ---
    parameter IMG_WIDTH  = 640;
    parameter IMG_HEIGHT = 480;
    localparam TOTAL_PIXELS = IMG_WIDTH * IMG_HEIGHT;

    // --- Tín hi?u ??u vào (Stimulus) ---
    reg        sys_clk;
    reg        sys_rst;
    reg        cam_pclk;
    reg        cam_rst;
    reg        cam_vsync;
    reg        cam_href;
    reg [7:0]  cam_data;
    reg [1:0]  color_sel;

    // --- Tín hi?u ??u ra quan sát (Observed) ---
    wire        cam_xclk;
    wire        cam_sioc;
    wire        cam_siod;
    wire        vga_hsync;
    wire        vga_vsync;
    wire [15:0] vga_rgb;
    
    wire [9:0] final_x_center;
    wire [9:0] final_y_center;
    wire       final_object_valid;
    wire       final_error_flag;

    // --- B? nh? ??m ch?a ?nh Test ---
    reg [15:0] image_mem [0:TOTAL_PIXELS-1];
    integer i, x, y;
    integer file_id; 

    // =========================================================================
    // KH?I T?O M?CH C?N TEST (DUT)
    // =========================================================================
    system_top #(
        .IMG_WIDTH(IMG_WIDTH),
        .IMG_HEIGHT(IMG_HEIGHT)
    ) DUT (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .cam_xclk(cam_xclk),
        .cam_sioc(cam_sioc),
        .cam_siod(cam_siod),
        .cam_pclk(cam_pclk),
        .cam_rst(cam_rst),
        .cam_vsync(cam_vsync),
        .cam_href(cam_href),
        .cam_data(cam_data),
        .color_sel(color_sel),
        
        .final_x_center(final_x_center),
        .final_y_center(final_y_center),
        .final_object_valid(final_object_valid),
        .final_error_flag(final_error_flag),
        
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .vga_rgb(vga_rgb)
    );

    // =========================================================================
    // T?O XUNG NH?P (Clock Generation)
    // =========================================================================
    initial begin
        sys_clk = 0;
        forever #10 sys_clk = ~sys_clk; // 50 MHz
    end

    initial begin
        cam_pclk = 0;
        forever #20.8 cam_pclk = ~cam_pclk; // ~24 MHz
    end

    // =========================================================================
    // K?CH B?N MÔ PH?NG (Simulation Scenario)
    // =========================================================================
    initial begin
        // 1. Kh?i t?o ban ??u
        sys_rst = 1;
        cam_rst = 1;
        cam_vsync = 1; 
        cam_href = 0;
        cam_data = 0;
        color_sel = 2'b00; 

        // 2. M? file ?nh m?u
        // L?U Ý: B?n c?n ??m b?o file "input_image_rgb.txt" có ?? dài ?? 640x480 = 307200 dòng.
        file_id = $fopen("input/image_rgb.txt", "r");
        if (file_id == 0) begin
            $display("-> KHONG TIM THAY FILE image_rgb.txt");
            $stop; 
        end else begin
            $display("-> DA TIM THAY FILE image_rgb.txt");
            $fclose(file_id); 
            $readmemh("input/image_rgb.txt", image_mem);
        end

        #100;
        sys_rst = 0;
        cam_rst = 0;
        #100;
        $display("=== BAT DAU MO PHONG ===");

        // 3. B?t ??u truy?n 1 khung hình (Frame 1)
        @(negedge cam_pclk);
        cam_vsync = 0; 
        #200; 

        i = 0;
        for (y = 0; y < IMG_HEIGHT; y = y + 1) begin
            for (x = 0; x < IMG_WIDTH; x = x + 1) begin
                @(negedge cam_pclk);
                cam_href = 1; 
                cam_data = image_mem[i][15:8]; // ??y Byte cao
                
                @(negedge cam_pclk);
                cam_data = image_mem[i][7:0];  // ??y Byte th?p
                i = i + 1;
            end
            
            @(negedge cam_pclk);
            cam_href = 0;
            cam_data = 8'h00;
            #150; 
        end

        @(negedge cam_pclk);
        cam_vsync = 1;
        #500; 

        // =========================================================
        // FRAME 2 ?? ÉP CH?T D? LI?U C?A FRAME 1
        // =========================================================
        $display("-> Dang tao xung Frame 2 de chot toa do...");
        @(negedge cam_pclk);
        cam_vsync = 0; 
        #200; 
        
        @(negedge cam_pclk);
        cam_href = 1; 
        cam_data = 8'h00; // Byte cao
        @(negedge cam_pclk);
        cam_data = 8'h00; // Byte th?p
        
        @(negedge cam_pclk);
        cam_href = 0; // Ng?t href
        
        #1000; // ??i d? li?u ch?y qua h?t FIFO và module HSV

        // 4. In k?t qu? t?a ??
        if (final_object_valid) begin
            $display("-> TOA DO TRUNG TAM: X = %0d, Y = %0d", final_x_center, final_y_center);
            if (final_error_flag)
                $display("-> CANH BAO: VAT THE NAM NGOAI VUNG AN TOAN!");
            else
                $display("-> AN TOAN: Vat the nam trong Safe Zone.");
        end else begin
            $display("-> KHONG TIM THAY VAT THE!");
        end
        
        $stop;
    end
endmodule
