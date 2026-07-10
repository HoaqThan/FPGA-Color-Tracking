`timescale 1ns/1ps

// Sends the OV7670 initialization ROM over SCCB/I2C.
module ov7670_configurator #(
    parameter integer CLK_HZ                   = 48000000,
    parameter integer SCCB_HZ                  = 100000,
    parameter integer STARTUP_DELAY_CYCLES     = 4800000,
    parameter integer INTER_WRITE_DELAY_CYCLES = 24000,
    parameter integer RESET_DELAY_CYCLES       = 2400000
) (
    input  wire clk,
    input  wire rst,
    output wire sioc,
    inout  wire siod,
    output reg  config_done,
    output reg  config_busy,
    output reg  ack_error_sticky,
    output reg  [7:0] rom_index_debug
);

    localparam DEV_ADDR_WRITE = 8'h42;
    localparam ST_STARTUP     = 3'd0;
    localparam ST_LOAD        = 3'd1;
    localparam ST_START_WRITE = 3'd2;
    localparam ST_WAIT_WRITE  = 3'd3;
    localparam ST_DELAY       = 3'd4;
    localparam ST_DONE        = 3'd5;

    reg [2:0]  state;
    reg [31:0] delay_cnt;
    reg        sccb_start;
    reg [7:0]  rom_index;

    wire [7:0] rom_reg;
    wire [7:0] rom_data;
    wire       rom_valid;
    wire       rom_last;
    wire       sccb_busy;
    wire       sccb_done;
    wire       sccb_ack_error;

    ov7670_init_rom rom_u (
        .index   (rom_index),
        .reg_addr(rom_reg),
        .reg_data(rom_data),
        .valid   (rom_valid),
        .last    (rom_last)
    );

    ov7670_sccb_master #(
        .CLK_HZ   (CLK_HZ),
        .SCCB_HZ  (SCCB_HZ),
        .ACK_CHECK(1'b0)
    ) sccb_u (
        .clk      (clk),
        .rst      (rst),
        .start    (sccb_start),
        .dev_addr (DEV_ADDR_WRITE),
        .reg_addr (rom_reg),
        .reg_data (rom_data),
        .busy     (sccb_busy),
        .done     (sccb_done),
        .ack_error(sccb_ack_error),
        .sioc     (sioc),
        .siod     (siod)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state            <= ST_STARTUP;
            delay_cnt        <= STARTUP_DELAY_CYCLES;
            sccb_start       <= 1'b0;
            rom_index        <= 8'd0;
            config_done      <= 1'b0;
            config_busy      <= 1'b1;
            ack_error_sticky <= 1'b0;
            rom_index_debug  <= 8'd0;
        end else begin
            sccb_start      <= 1'b0;
            rom_index_debug <= rom_index;

            if (sccb_ack_error) begin
                ack_error_sticky <= 1'b1;
            end

            case (state)
                ST_STARTUP: begin
                    config_busy <= 1'b1;
                    if (delay_cnt == 32'd0) begin
                        state <= ST_LOAD;
                    end else begin
                        delay_cnt <= delay_cnt - 1'b1;
                    end
                end
                ST_LOAD: begin
                    if (!rom_valid) begin
                        state <= ST_DONE;
                    end else begin
                        state <= ST_START_WRITE;
                    end
                end
                ST_START_WRITE: begin
                    if (!sccb_busy) begin
                        sccb_start <= 1'b1;
                        state      <= ST_WAIT_WRITE;
                    end
                end
                ST_WAIT_WRITE: begin
                    if (sccb_done) begin
                        if (rom_last) begin
                            state <= ST_DONE;
                        end else begin
                            if ((rom_reg == 8'h12) && (rom_data == 8'h80)) begin
                                delay_cnt <= RESET_DELAY_CYCLES;
                            end else begin
                                delay_cnt <= INTER_WRITE_DELAY_CYCLES;
                            end
                            state <= ST_DELAY;
                        end
                    end
                end
                ST_DELAY: begin
                    if (delay_cnt == 32'd0) begin
                        rom_index <= rom_index + 1'b1;
                        state     <= ST_LOAD;
                    end else begin
                        delay_cnt <= delay_cnt - 1'b1;
                    end
                end
                ST_DONE: begin
                    config_done <= 1'b1;
                    config_busy <= 1'b0;
                    state       <= ST_DONE;
                end
                default: begin
                    state <= ST_STARTUP;
                end
            endcase
        end
    end

endmodule
