`timescale 1ns/1ps

// OV7670 DVP RGB565 byte stream to FPGA system-clock pixel stream.
// Camera side: cam_pclk domain, 8-bit bus, HREF valid line, VSYNC frame gap.
// System side: sys_clk domain, 16-bit RGB565 pixels plus frame/line markers.
module ov7670_rgb565_cdc #(
    parameter FIFO_ADDR_WIDTH  = 5,
    parameter VSYNC_ACTIVE_HIGH = 1'b1
) (
    input  wire        cam_pclk,
    input  wire        cam_rst,
    input  wire        cam_vsync,
    input  wire        cam_href,
    input  wire [7:0]  cam_data,
    output wire        cam_fifo_full,
    output reg         cam_overflow_sticky,

    input  wire        sys_clk,
    input  wire        sys_rst,
    input  wire        sys_rd_en,
    output reg  [15:0] sys_pixel,
    output reg         sys_pixel_valid,
    output reg         sys_frame_start,
    output reg         sys_line_start,
    output wire        sys_fifo_empty,
    output wire        sys_overflow_sticky
);

    localparam FIFO_WIDTH = 18; // {frame_start, line_start, pixel[15:0]}

    wire frame_blank;
    wire href_rise;

    reg        href_d;
    reg [7:0]  first_byte;
    reg        byte_phase;
    reg        frame_start_pending;
    reg        line_start_pending;
    reg        fifo_wr_en;
    reg [17:0] fifo_wr_data;

    wire [17:0] fifo_rd_data;
    wire        fifo_wr_overflow;
    wire        fifo_rd_underflow;
    wire        fifo_rd_en;

    reg         fifo_rd_en_d;
    reg [1:0]   overflow_sync;

    assign frame_blank = (VSYNC_ACTIVE_HIGH == 1'b1) ? cam_vsync : ~cam_vsync;
    assign href_rise   = cam_href && !href_d;
    assign fifo_rd_en  = sys_rd_en && !sys_fifo_empty;

    async_fifo_gray #(
        .DATA_WIDTH(FIFO_WIDTH),
        .ADDR_WIDTH(FIFO_ADDR_WIDTH)
    ) pixel_fifo (
        .wr_clk      (cam_pclk),
        .wr_rst      (cam_rst),
        .wr_en       (fifo_wr_en),
        .wr_data     (fifo_wr_data),
        .wr_full     (cam_fifo_full),
        .wr_overflow (fifo_wr_overflow),

        .rd_clk      (sys_clk),
        .rd_rst      (sys_rst),
        .rd_en       (fifo_rd_en),
        .rd_data     (fifo_rd_data),
        .rd_empty    (sys_fifo_empty),
        .rd_underflow(fifo_rd_underflow)
    );

    always @(posedge cam_pclk or posedge cam_rst) begin
        if (cam_rst) begin
            href_d              <= 1'b0;
            first_byte          <= 8'h00;
            byte_phase          <= 1'b0;
            frame_start_pending <= 1'b1;
            line_start_pending  <= 1'b0;
            fifo_wr_en          <= 1'b0;
            fifo_wr_data        <= {FIFO_WIDTH{1'b0}};
            cam_overflow_sticky <= 1'b0;
        end else begin
            href_d     <= cam_href;
            fifo_wr_en <= 1'b0;

            if (fifo_wr_overflow) begin
                cam_overflow_sticky <= 1'b1;
            end

            if (frame_blank) begin
                byte_phase          <= 1'b0;
                frame_start_pending <= 1'b1;
                line_start_pending  <= 1'b0;
            end else if (!cam_href) begin
                byte_phase <= 1'b0;
            end else begin
                if (href_rise) begin
                    line_start_pending <= 1'b1;
                end

                if (href_rise || !byte_phase) begin
                    first_byte <= cam_data;
                    byte_phase <= 1'b1;
                end else begin
                    fifo_wr_data <= {frame_start_pending,
                                     line_start_pending,
                                     first_byte,
                                     cam_data};
                    fifo_wr_en          <= 1'b1;
                    byte_phase          <= 1'b0;
                    frame_start_pending <= 1'b0;
                    line_start_pending  <= 1'b0;
                end
            end
        end
    end

    always @(posedge sys_clk or posedge sys_rst) begin
        if (sys_rst) begin
            fifo_rd_en_d     <= 1'b0;
            sys_pixel        <= 16'h0000;
            sys_pixel_valid  <= 1'b0;
            sys_frame_start  <= 1'b0;
            sys_line_start   <= 1'b0;
            overflow_sync    <= 2'b00;
        end else begin
            fifo_rd_en_d    <= fifo_rd_en;
            sys_pixel_valid <= fifo_rd_en_d;
            sys_frame_start <= 1'b0;
            sys_line_start  <= 1'b0;
            overflow_sync   <= {overflow_sync[0], cam_overflow_sticky};

            if (fifo_rd_en_d) begin
                sys_frame_start <= fifo_rd_data[17];
                sys_line_start  <= fifo_rd_data[16];
                sys_pixel       <= fifo_rd_data[15:0];
            end
        end
    end

    assign sys_overflow_sticky = overflow_sync[1];

endmodule
