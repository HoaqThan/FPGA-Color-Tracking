`timescale 1ns/1ps

// Write-only SCCB/I2C master for OV7670 register initialization.
// OV7670 write ID is 8'h42, equivalent to 7-bit I2C address 7'h21 plus write bit.
module ov7670_sccb_master #(
    parameter integer CLK_HZ    = 48000000,
    parameter integer SCCB_HZ   = 100000,
    parameter         ACK_CHECK = 1'b0
) (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] dev_addr,
    input  wire [7:0] reg_addr,
    input  wire [7:0] reg_data,

    output reg        busy,
    output reg        done,
    output reg        ack_error,
    output reg        sioc,
    inout  wire       siod
);

    localparam integer TICK_DIV_RAW = CLK_HZ / (SCCB_HZ * 4);
    localparam integer TICK_DIV     = (TICK_DIV_RAW < 1) ? 1 : TICK_DIV_RAW;

    localparam ST_IDLE      = 4'd0;
    localparam ST_START_A   = 4'd1;
    localparam ST_START_B   = 4'd2;
    localparam ST_START_C   = 4'd3;
    localparam ST_BIT_SETUP = 4'd4;
    localparam ST_BIT_HIGH  = 4'd5;
    localparam ST_BIT_LOW   = 4'd6;
    localparam ST_ACK_SETUP = 4'd7;
    localparam ST_ACK_HIGH  = 4'd8;
    localparam ST_ACK_LOW   = 4'd9;
    localparam ST_STOP_A    = 4'd10;
    localparam ST_STOP_B    = 4'd11;
    localparam ST_STOP_C    = 4'd12;

    reg [3:0]  state;
    reg [31:0] tick_cnt;
    reg        tick;
    reg        siod_drive_low;
    reg [7:0]  byte0;
    reg [7:0]  byte1;
    reg [7:0]  byte2;
    reg [7:0]  tx_byte;
    reg [2:0]  bit_index;
    reg [1:0]  byte_index;

    assign siod = siod_drive_low ? 1'b0 : 1'bz;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tick_cnt <= 32'd0;
            tick     <= 1'b0;
        end else begin
            if (tick_cnt == TICK_DIV - 1) begin
                tick_cnt <= 32'd0;
                tick     <= 1'b1;
            end else begin
                tick_cnt <= tick_cnt + 1'b1;
                tick     <= 1'b0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state          <= ST_IDLE;
            busy           <= 1'b0;
            done           <= 1'b0;
            ack_error      <= 1'b0;
            sioc           <= 1'b1;
            siod_drive_low <= 1'b0;
            byte0          <= 8'h00;
            byte1          <= 8'h00;
            byte2          <= 8'h00;
            tx_byte        <= 8'h00;
            bit_index      <= 3'd7;
            byte_index     <= 2'd0;
        end else begin
            done <= 1'b0;

            if (state == ST_IDLE) begin
                sioc           <= 1'b1;
                siod_drive_low <= 1'b0;
                busy           <= 1'b0;

                if (start) begin
                    byte0      <= dev_addr;
                    byte1      <= reg_addr;
                    byte2      <= reg_data;
                    tx_byte    <= dev_addr;
                    bit_index  <= 3'd7;
                    byte_index <= 2'd0;
                    ack_error  <= 1'b0;
                    busy       <= 1'b1;
                    state      <= ST_START_A;
                end
            end else if (tick) begin
                case (state)
                    ST_START_A: begin
                        sioc           <= 1'b1;
                        siod_drive_low <= 1'b0;
                        state          <= ST_START_B;
                    end
                    ST_START_B: begin
                        sioc           <= 1'b1;
                        siod_drive_low <= 1'b1;
                        state          <= ST_START_C;
                    end
                    ST_START_C: begin
                        sioc           <= 1'b0;
                        siod_drive_low <= 1'b1;
                        state          <= ST_BIT_SETUP;
                    end
                    ST_BIT_SETUP: begin
                        sioc           <= 1'b0;
                        siod_drive_low <= ~tx_byte[bit_index];
                        state          <= ST_BIT_HIGH;
                    end
                    ST_BIT_HIGH: begin
                        sioc  <= 1'b1;
                        state <= ST_BIT_LOW;
                    end
                    ST_BIT_LOW: begin
                        sioc <= 1'b0;
                        if (bit_index == 3'd0) begin
                            state <= ST_ACK_SETUP;
                        end else begin
                            bit_index <= bit_index - 1'b1;
                            state     <= ST_BIT_SETUP;
                        end
                    end
                    ST_ACK_SETUP: begin
                        sioc           <= 1'b0;
                        siod_drive_low <= 1'b0;
                        state          <= ST_ACK_HIGH;
                    end
                    ST_ACK_HIGH: begin
                        sioc <= 1'b1;
                        if (ACK_CHECK && siod) begin
                            ack_error <= 1'b1;
                        end
                        state <= ST_ACK_LOW;
                    end
                    ST_ACK_LOW: begin
                        sioc <= 1'b0;
                        if (byte_index == 2'd2) begin
                            state <= ST_STOP_A;
                        end else begin
                            byte_index <= byte_index + 1'b1;
                            bit_index  <= 3'd7;
                            if (byte_index == 2'd0) begin
                                tx_byte <= byte1;
                            end else begin
                                tx_byte <= byte2;
                            end
                            state <= ST_BIT_SETUP;
                        end
                    end
                    ST_STOP_A: begin
                        sioc           <= 1'b0;
                        siod_drive_low <= 1'b1;
                        state          <= ST_STOP_B;
                    end
                    ST_STOP_B: begin
                        sioc           <= 1'b1;
                        siod_drive_low <= 1'b1;
                        state          <= ST_STOP_C;
                    end
                    ST_STOP_C: begin
                        sioc           <= 1'b1;
                        siod_drive_low <= 1'b0;
                        busy           <= 1'b0;
                        done           <= 1'b1;
                        state          <= ST_IDLE;
                    end
                    default: begin
                        state <= ST_IDLE;
                    end
                endcase
            end
        end
    end

endmodule
