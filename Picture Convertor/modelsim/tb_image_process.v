`timescale 1ns/1ps

module tb_image_process;

//====================================================
// Parameters
//====================================================

parameter WIDTH  = 640;
parameter HEIGHT = 480;

localparam TOTAL_PIXEL = WIDTH * HEIGHT;

//====================================================
// Clock & Reset
//====================================================

reg clk;
reg rst;

//====================================================
// Image Memory
//====================================================

reg [15:0] image_mem [0:TOTAL_PIXEL-1];

//====================================================
// Input Pixel
//====================================================

reg [15:0] pixel_data;

//====================================================
// Variables
//====================================================

integer pixel_index;
integer outfile;
reg [1:0] flush_cnt;
//====================================================
// Output
//====================================================

wire [7:0] hue;
wire [7:0] sat;
wire [7:0] val;

wire mask;
wire mask_valid;

//====================================================
// Pixel Valid
//====================================================

wire pixel_valid;

assign pixel_valid = (!rst) && (pixel_index < TOTAL_PIXEL);

//====================================================
// Clock Generation
//====================================================

always #5 clk = ~clk;

//====================================================
// Reset
//====================================================

initial
begin

    clk = 0;
    outfile = $fopen("D:/FPT lon/Ky 4/FAP/Color Tracking/Image_Project_again_1/Image_Project/output/threshold_out.txt","w");

    if(outfile==0)
    begin
        $display("Cannot create output file!");
        $stop;
    end
    rst = 1;

    pixel_index = 0;
    pixel_data  = 16'd0;

    #20;

    rst = 0;

end

//====================================================
// Read Image
//====================================================

initial
begin

    $display("--------------------------------");
    $display("Loading image_rgb.txt...");
    $display("--------------------------------");

    $readmemh("D:/FPT lon/Ky 4/FAP/Color Tracking/Image_Project_again_1/Image_Project/output/image_rgb.txt", image_mem);

    $display("--------------------------------");
    $display("Image Loaded Successfully!");
    $display("--------------------------------");

end

//====================================================
// Feed Pixel
//====================================================

always @(posedge clk)
begin

    if(rst)
    begin

        pixel_index <= 0;
        pixel_data  <= 16'd0;
        flush_cnt   <= 2'd0;

    end

    else
    begin

        if(pixel_index < TOTAL_PIXEL)
        begin

            pixel_data <= image_mem[pixel_index];

            $display("Pixel=%0d RGB565=%h Mask=%b",
                     pixel_index,
                     image_mem[pixel_index],
                     mask);

            pixel_index <= pixel_index + 1;

        end

        else if (flush_cnt < 3)
        begin

            flush_cnt <= flush_cnt + 1;

        end

        else
        begin

            $display("--------------------------------");
            $display("Simulation Finished");
            $display("--------------------------------");

            $fclose(outfile);

            $display("----------------------");
            $display("Threshold Saved");
            $display("----------------------");

            $stop;

        end

    end

end

//====================================================
// DUT
//====================================================

rgb565_to_hsv_threshold DUT
(
    .clk(clk),
    .rst(rst),

    .rgb565(pixel_data),
    .pixel_valid(pixel_valid),

    .hue(hue),
    .sat(sat),
    .val(val),

    .mask(mask),
    .mask_valid(mask_valid)
);
always @(posedge clk)
begin

    if(mask_valid)
    begin
        $fdisplay(outfile,"%0d",mask);
    end

end
endmodule