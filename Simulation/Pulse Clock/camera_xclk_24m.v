`timescale 1ns/1ps

// Generates OV7670 XCLK when the input clock is already 24 MHz or exactly 48 MHz.
// If the Tang Nano project starts from 27 MHz, create a Gowin PLL that outputs
// 24 MHz or 48 MHz, then feed that PLL output into this module.
module camera_xclk_24m #(
    parameter integer CLK_IN_HZ = 48000000
) (
    input  wire clk_in,
    input  wire rst,
    output wire xclk,
    output wire locked
);

generate
    if (CLK_IN_HZ == 24000000) begin : gen_passthrough
        assign xclk   = clk_in;
        assign locked = ~rst;
    end else if (CLK_IN_HZ == 48000000) begin : gen_div2
        reg xclk_r;
        always @(posedge clk_in or posedge rst) begin
            if (rst) begin
                xclk_r <= 1'b0;
            end else begin
                xclk_r <= ~xclk_r;
            end
        end
        assign xclk   = xclk_r;
        assign locked = ~rst;
    end else begin : gen_invalid
        initial begin
            $display("ERROR: camera_xclk_24m needs CLK_IN_HZ=24000000 or 48000000. Use Gowin PLL for other board clocks.");
        end
        assign xclk   = 1'b0;
        assign locked = 1'b0;
    end
endgenerate

endmodule
