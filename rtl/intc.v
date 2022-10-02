`include "define.v"

module intc (
    input clk   ,
    input rst_n ,
    
    input int_i,

    input [31:0] inst_addr_i,
    input [31:0] inst_i,

    input      [31:0] csr_data_i,
    output reg [31:0] csr_data_o,
    output reg [11:0] csr_addr_o,
    output reg        csr_we_o,
    input wire [31:0] csr_mtvec,           // mtvec寄存器
    input wire [31:0] csr_mepc,            // mepc寄存器
    input wire [31:0] csr_mstatus,         // mstatus寄存器

    output reg        hold_o,

    output reg [31:0] int_addr_o,
    output reg        int_assert_o
);

// 中断状态定义
localparam S_INT_IDLE            = 4'b0001;
localparam S_INT_SYNC_ASSERT     = 4'b0010;
localparam S_INT_ASYNC_ASSERT    = 4'b0100;
localparam S_INT_MRET            = 4'b1000;

// 写CSR寄存器状态定义
localparam S_CSR_IDLE            = 5'b00001;
localparam S_CSR_MSTATUS         = 5'b00010;
localparam S_CSR_MEPC            = 5'b00100;
localparam S_CSR_MSTATUS_MRET    = 5'b01000;
localparam S_CSR_MCAUSE          = 5'b10000;

wire global_int_en;
assign global_int_en = csr_mstatus[3];


// 中断状态
reg [3:0] int_state;

always @(*) begin
    if (!rst_n) begin
        int_state = S_INT_IDLE;
    end
    else if(int_i) begin
        int_state = S_INT_ASYNC_ASSERT;
    end
    else if(inst_i == `INST_MRET) begin
        int_state = S_INT_MRET;
    end
    else begin
        int_state = S_INT_IDLE;
    end
end


// 写CSR寄存器状态
reg [4:0] csr_state; 
reg [31:0] cause;

always @(posedge clk) begin
    if(!rst_n) begin
        csr_state <= S_CSR_IDLE;
        cause <= 32'h0;
    end
    else begin
        case (csr_state)
            S_CSR_IDLE        : begin
                if((int_state == S_INT_ASYNC_ASSERT) && global_int_en) begin
                    csr_state <= S_CSR_MEPC;
                    cause <= 32'h80000004;
                end
                else if(int_state == S_INT_MRET) begin
                    csr_state <= S_CSR_MSTATUS_MRET;
                end
                else begin
                    csr_state <= csr_state;
                end
            end
            S_CSR_MSTATUS     : begin
                csr_state <= S_CSR_MCAUSE;
            end
            S_CSR_MEPC        : begin
                csr_state <= S_CSR_MSTATUS;
            end
            S_CSR_MSTATUS_MRET: begin
                csr_state <= S_CSR_IDLE;
            end
            S_CSR_MCAUSE      : begin
                csr_state <= S_CSR_IDLE;
            end
            default: begin
                csr_state <= S_CSR_IDLE;
            end
        endcase
    end
end

always @(posedge clk ) begin
    if(!rst_n) begin
        csr_data_o <= 32'd0;
        csr_addr_o <= 12'd0;
        csr_we_o   <= 1'd0;
    end
    else begin
        case (csr_state)
                S_CSR_IDLE        : begin
                    csr_data_o <= 32'd0;
                    csr_addr_o <= 12'd0;
                    csr_we_o   <= 1'd0;
                end
                S_CSR_MSTATUS     : begin
                    csr_data_o <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                    csr_addr_o <= `CSR_MSTATUS;
                    csr_we_o   <= 1'd1;
                end
                S_CSR_MEPC        : begin
                    csr_data_o <= inst_addr_i;
                    csr_addr_o <= `CSR_MEPC;
                    csr_we_o   <= 1'd1;
                end
                S_CSR_MSTATUS_MRET: begin
                    csr_data_o <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
                    csr_addr_o <= `CSR_MSTATUS;
                    csr_we_o   <= 1'd1;
                end
                S_CSR_MCAUSE      : begin
                    csr_data_o <= cause;
                    csr_addr_o <= `CSR_MCAUSE;
                    csr_we_o   <= 1'd1;
                end
            default: begin
                csr_data_o <= 32'd0;
                csr_addr_o <= 12'd0;
                csr_we_o   <= 1'd0;
            end
        endcase
    end
end


// 发送中断信号给EX
always @(posedge clk ) begin
    if(!rst_n) begin
        int_addr_o   <= 32'd0;
        int_assert_o <=  1'd0;
    end
    else begin
        case (csr_state)
            S_CSR_MCAUSE: begin
                int_addr_o <= csr_mtvec;
                int_assert_o <=  1'd1;
            end
            S_CSR_MSTATUS_MRET: begin
                int_addr_o   <= csr_mepc;
                int_assert_o <= 1'd1;
            end
            default: begin
                int_addr_o   <= 32'd0;
                int_assert_o <=  1'd0;
            end
        endcase
    end
end




endmodule
