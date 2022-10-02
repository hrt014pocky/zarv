`include "define.v"

module csr_regs (
    input clk   ,
    input rst_n ,

    // id read csr
    input       [11:0] csr_id_addr_i  ,
    output reg  [31:0] csr_id_data_o  ,

    // ex write csr
    input       [11:0] csr_ex_addr_i  ,
    input       [31:0] csr_ex_data_i  ,
    input              csr_ex_we_i    ,

    // intc read csr
    // input       [11:0] csr_intc_addr_i,
    output reg  [31:0] csr_intc_data_o,

    // intc write csr
    input       [11:0] csr_intc_addr_i,
    input       [31:0] csr_intc_data_i,
    input              csr_intc_we_i  ,
    
    output      [31:0] csr_mtvec      ,
    output      [31:0] csr_mepc       ,
    output      [31:0] csr_mstatus    
);

reg [31:0] mtvec;
reg [31:0] mcause;
reg [31:0] mepc;
reg [31:0] mie;
reg [31:0] mstatus;
reg [31:0] mscratch;


assign csr_mtvec = mtvec;   
assign csr_mepc = mepc;    
assign csr_mstatus = mstatus; 

// id read csr
always @(*) begin
    if(!rst_n) begin
        csr_id_data_o = 32'd0;
    end
    else begin
        case (csr_id_addr_i)
            `CSR_MTVEC   : begin
                csr_id_data_o = mtvec;
            end
            `CSR_MCAUSE  : begin
                csr_id_data_o = mcause;
            end
            `CSR_MEPC    : begin
                csr_id_data_o = mepc;
            end
            `CSR_MIE     : begin
                csr_id_data_o = mie;
            end
            `CSR_MSTATUS : begin
                csr_id_data_o = mstatus;
            end
            `CSR_MSCRATCH: begin
                csr_id_data_o = mscratch;
            end
            default: begin
                csr_id_data_o = 32'd0;
            end
        endcase
    end
end

// intc read csr
always @(*) begin
    if(!rst_n) begin
        csr_intc_data_o = 32'd0;
    end
    else begin
        case (csr_intc_addr_i)
            `CSR_MTVEC   : begin
                csr_intc_data_o = mtvec;
            end
            `CSR_MCAUSE  : begin
                csr_intc_data_o = mcause;
            end
            `CSR_MEPC    : begin
                csr_intc_data_o = mepc;
            end
            `CSR_MIE     : begin
                csr_intc_data_o = mie;
            end
            `CSR_MSTATUS : begin
                csr_intc_data_o = mstatus;
            end
            `CSR_MSCRATCH: begin
                csr_intc_data_o = mscratch;
            end
            default: begin
                csr_intc_data_o = 32'd0;
            end
        endcase
    end
end

// ex intc write csr
always @(posedge clk) begin
    if(!rst_n) begin
        mtvec       <= 32'd0;
        mcause      <= 32'd0;
        mepc        <= 32'd0;
        mie         <= 32'd0;
        mstatus     <= 32'd0;
        mscratch    <= 32'd0;
    end
    else if(csr_ex_we_i) begin
        case (csr_ex_addr_i)
            `CSR_MTVEC   : begin
                mtvec <= csr_ex_data_i;
            end
            `CSR_MCAUSE  : begin
                mcause <= csr_ex_data_i;
            end
            `CSR_MEPC    : begin
                mepc <= csr_ex_data_i;
            end
            `CSR_MIE     : begin
                mie <= csr_ex_data_i;
            end
            `CSR_MSTATUS : begin
                mstatus <= csr_ex_data_i;
            end
            `CSR_MSCRATCH: begin
                mscratch <= csr_ex_data_i;
            end
            default: begin
                
            end
        endcase
    end
    else if(csr_intc_we_i) begin
        case (csr_intc_addr_i)
            `CSR_MTVEC   : begin
                mtvec <= csr_intc_data_i;
            end
            `CSR_MCAUSE  : begin
                mcause <= csr_intc_data_i;
            end
            `CSR_MEPC    : begin
                mepc <= csr_intc_data_i;
            end
            `CSR_MIE     : begin
                mie <= csr_intc_data_i;
            end
            `CSR_MSTATUS : begin
                mstatus <= csr_intc_data_i;
            end
            `CSR_MSCRATCH: begin
                mscratch <= csr_intc_data_i;
            end
            default: begin
                
            end
        endcase
    end
end


endmodule
