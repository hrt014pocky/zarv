// instruction decoding

`include "define.v"

module id (
    input                clk         ,
    input                rst_n       ,

    input        [31:0]  inst_addr_i ,
    input        [31:0]  inst_i      ,

    input        [31:0]  rs1_data_i  ,
    input        [31:0]  rs2_data_i  ,

    output reg   [31:0]  inst_addr_o ,
    output reg   [31:0]  inst_o      ,

    output reg   [ 4:0]  rd_addr_o   ,

    output reg   [ 4:0]  rs1_addr_o  ,
    output reg   [31:0]  rs1_data_o  ,

    output reg   [ 4:0]  rs2_addr_o  ,
    output reg   [31:0]  rs2_data_o  ,

    input        [31:0]  csr_data_i  , // csr data from csr_regs
    output reg   [11:0]  csr_addr_o  , // csr address to csr_regs
    output reg   [31:0]  csr_data_o    // data to ex

);

wire [6:0] opcode;
wire [2:0] funct3;
wire [4:0] rd_addr;
wire [4:0] rs1_addr;
wire [4:0] rs2_addr;
wire [11:0] csr_addr;
wire [31:0] csr_data;

assign opcode   = inst_i[ 6: 0];
assign funct3   = inst_i[14:12];
assign rd_addr  = inst_i[11: 7];
assign rs1_addr = inst_i[19:15];
assign rs2_addr = inst_i[24:20];
assign csr_addr = inst_i[31:20];
assign csr_data = csr_data_i;

always @(*) begin
    inst_addr_o = inst_addr_i;
    inst_o      = inst_i;
    rd_addr_o   = 32'd0;
    rs1_addr_o  = 32'd0;
    rs1_data_o  = rs1_data_i;
    rs2_addr_o  = 32'd0;
    rs2_data_o  = rs2_data_i;
    csr_data_o  = 32'd0;
    csr_addr_o  = 12'd0;
    case (opcode)
        `INST_LUI: begin
            rd_addr_o  = rd_addr;
        end
        `INST_AUIPC: begin
            rd_addr_o  = rd_addr;
        end
        `INST_TYPE_I: begin // opcode = 0010011
            case (funct3)
                `INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI, `INST_SLLI, `INST_SRI : begin
                    rd_addr_o  = rd_addr;
                    rs1_addr_o = rs1_addr;
                end
                default: begin
                    ;
                end
            endcase
        end
        `INST_TYPE_I_L: begin
            case (funct3)
                `INST_LB, `INST_LH, `INST_LW, `INST_LBU, `INST_LHU : begin
                    rd_addr_o  = rd_addr;
                    rs1_addr_o = rs1_addr;
                    rs2_addr_o = rs2_addr;
                end
                default: begin
                    ;
                end
            endcase
        end
        `INST_TYPE_S: begin
            case (funct3) 
                `INST_SB, `INST_SH, `INST_SW: begin
                    rs1_addr_o = rs1_addr;
                    rs2_addr_o = rs2_addr;
                end
                default: begin
                    ;
                end
            endcase
        end
        `INST_TYPE_R_M: begin
            rs1_addr_o = rs1_addr;
            rs2_addr_o = rs2_addr;
            rd_addr_o  = rd_addr;
        end
        `INST_TYPE_B: begin
            rs1_addr_o = rs1_addr;
            rs2_addr_o = rs2_addr;
        end
        `INST_JAL, `INST_JALR: begin
            rs1_addr_o = rs1_addr;
            rs2_addr_o = rs2_addr;
            rd_addr_o  = rd_addr;
        end
        `INST_CSR: begin
            rs1_addr_o = rs1_addr;
            rd_addr_o  = rd_addr;
            csr_data_o = csr_data;
            csr_addr_o = csr_addr;
        end
        `INST_NOP_OP: begin
            ;
        end
        default: begin
            ;
        end
    endcase
end


endmodule
