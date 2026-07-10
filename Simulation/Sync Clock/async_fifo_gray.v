`timescale 1ns/1ps

// Dual-clock asynchronous FIFO.
// Write side and read side may use unrelated clocks.
// Pointer values cross clock domains as Gray code through two flip-flops.
module async_fifo_gray #(
    parameter DATA_WIDTH = 18,
    parameter ADDR_WIDTH = 4
) (
    input  wire                  wr_clk,
    input  wire                  wr_rst,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output reg                   wr_full,
    output reg                   wr_overflow,

    input  wire                  rd_clk,
    input  wire                  rd_rst,
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output reg                   rd_empty,
    output reg                   rd_underflow
);

    localparam DEPTH = (1 << ADDR_WIDTH);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH:0] wr_bin;
    reg [ADDR_WIDTH:0] wr_gray;
    reg [ADDR_WIDTH:0] rd_bin;
    reg [ADDR_WIDTH:0] rd_gray;

    reg [ADDR_WIDTH:0] rd_gray_wrclk_1;
    reg [ADDR_WIDTH:0] rd_gray_wrclk_2;
    reg [ADDR_WIDTH:0] wr_gray_rdclk_1;
    reg [ADDR_WIDTH:0] wr_gray_rdclk_2;

    wire                wr_fire;
    wire                rd_fire;
    wire [ADDR_WIDTH:0] wr_bin_next;
    wire [ADDR_WIDTH:0] wr_gray_next;
    wire [ADDR_WIDTH:0] rd_bin_next;
    wire [ADDR_WIDTH:0] rd_gray_next;
    wire                wr_full_next;
    wire                rd_empty_next;

    assign wr_fire      = wr_en && !wr_full;
    assign rd_fire      = rd_en && !rd_empty;
    assign wr_bin_next  = wr_bin + {{ADDR_WIDTH{1'b0}}, wr_fire};
    assign rd_bin_next  = rd_bin + {{ADDR_WIDTH{1'b0}}, rd_fire};
    assign wr_gray_next = (wr_bin_next >> 1) ^ wr_bin_next;
    assign rd_gray_next = (rd_bin_next >> 1) ^ rd_bin_next;

    assign wr_full_next =
        (wr_gray_next == {~rd_gray_wrclk_2[ADDR_WIDTH:ADDR_WIDTH-1],
                           rd_gray_wrclk_2[ADDR_WIDTH-2:0]});

    assign rd_empty_next = (rd_gray_next == wr_gray_rdclk_2);

    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            rd_gray_wrclk_1 <= {ADDR_WIDTH+1{1'b0}};
            rd_gray_wrclk_2 <= {ADDR_WIDTH+1{1'b0}};
        end else begin
            rd_gray_wrclk_1 <= rd_gray;
            rd_gray_wrclk_2 <= rd_gray_wrclk_1;
        end
    end

    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            wr_gray_rdclk_1 <= {ADDR_WIDTH+1{1'b0}};
            wr_gray_rdclk_2 <= {ADDR_WIDTH+1{1'b0}};
        end else begin
            wr_gray_rdclk_1 <= wr_gray;
            wr_gray_rdclk_2 <= wr_gray_rdclk_1;
        end
    end

    always @(posedge wr_clk or posedge wr_rst) begin
        if (wr_rst) begin
            wr_bin      <= {ADDR_WIDTH+1{1'b0}};
            wr_gray     <= {ADDR_WIDTH+1{1'b0}};
            wr_full     <= 1'b0;
            wr_overflow <= 1'b0;
        end else begin
            wr_overflow <= wr_en && wr_full;

            if (wr_fire) begin
                mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data;
                wr_bin  <= wr_bin_next;
                wr_gray <= wr_gray_next;
            end

            wr_full <= wr_full_next;
        end
    end

    always @(posedge rd_clk or posedge rd_rst) begin
        if (rd_rst) begin
            rd_bin       <= {ADDR_WIDTH+1{1'b0}};
            rd_gray      <= {ADDR_WIDTH+1{1'b0}};
            rd_data      <= {DATA_WIDTH{1'b0}};
            rd_empty     <= 1'b1;
            rd_underflow <= 1'b0;
        end else begin
            rd_underflow <= rd_en && rd_empty;

            if (rd_fire) begin
                rd_data <= mem[rd_bin[ADDR_WIDTH-1:0]];
                rd_bin  <= rd_bin_next;
                rd_gray <= rd_gray_next;
            end

            rd_empty <= rd_empty_next;
        end
    end

endmodule
