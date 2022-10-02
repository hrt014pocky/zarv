`include "define.v"

module ex (
    input clk   ,
    input rst_n ,

    // input from id_ex
    input [31:0] inst_addr_i,
    input [31:0] inst_i,
    input [ 4:0] rd_addr_i,
    input [ 4:0] rs1_addr_i,
    input [31:0] rs1_data_i,
    input [ 4:0] rs2_addr_i,
    input [31:0] rs2_data_i,
    input [31:0] csr_data_i,

    // xbus
    output reg [31:0] mem_addr_o,
    output reg [31:0] mem_data_o,
    input      [31:0] mem_data_i,
    output reg        mem_we_o  ,
    output reg        mem_req_o ,

    // regs
    output reg [31:0] rd_data_o,
    output reg [ 4:0] rd_addr_o,
    output reg        rd_we_o  ,
    output reg        ex_hold_o,

    // csr_reg
    output reg [11:0] csr_waddr_o,
    output reg [31:0] csr_wdata_o,
    output reg        csr_we_o   ,

    input      [31:0] int_addr_i  ,
    input             int_assert_i,

    // ctrl
    output     [31:0] jump_addr_o,
    output            jump_flag_o,
    output            hold_o
);

wire [6:0] opcode;
wire [2:0] funct3;
wire [4:0] rd_addr;
wire [4:0] rs1_addr;
wire [4:0] rs2_addr;
wire [5:0] shamt;

assign opcode   = inst_i[6:0];
assign funct3   = inst_i[14:12];
assign rd_addr  = inst_i[11:7];
assign rs1_addr = inst_i[19:15];
assign rs2_addr = inst_i[24:20];
assign shamt    = inst_i[25:20];

wire signed [31:0] rs1_siged = rs1_data_i;
wire signed [31:0] rs2_siged = rs2_data_i;
wire [31:0] rs1_unsiged = rs1_data_i;
wire [31:0] rs2_unsiged = rs2_data_i;

wire [6:0] funct7;
assign funct7   = inst_i[31:25];

wire [11:0] imm_i;
assign imm_i = inst_i[31:20];

wire [11:0] imm_s;
assign imm_s = {inst_i[31:25], inst_i[11:7]};

wire [19:0] imm_u;
assign imm_u = inst_i[31:12];

wire [4:0] zimm;
assign zimm = inst_i[19:15];

// 无条件跳转
wire [19:0] imm_jal;
wire [11:0] imm_jalr;
assign imm_jalr = inst_i[31:20];
assign imm_jal = {inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21]};

wire signed [31:0] jal_addr;
assign jal_addr = {{11{imm_jal[19]}}, imm_jal, 1'd0} + inst_addr_i;

// wire [31:0] jalr_imm_plus_rs1;
// wire unsigned [31:0] jalr_addr;
// assign jalr_addr = jalr_imm_plus_rs1 & 32'hfffffffe;
// assign jalr_imm_plus_rs1 = {{20{imm_jalr[11]}}, imm_jalr};

wire signed [31:0] jalr_sign_extend;
wire signed [31:0] jalr_addr;
assign jalr_sign_extend = {{20{imm_jalr[11]}}, imm_jalr};
assign jalr_addr = (jalr_sign_extend + rs1_siged) & 32'hfffffffe;

// 指令地址链接
wire [31:0] pc_puls4;
assign pc_puls4 = inst_addr_i + 32'd4;

wire signed [31:0] imm_signed = {{20{imm_i[11]}}, imm_i}; // 有符号扩展的立即数
wire [31:0] imm_unsigned = {{20{imm_i[11]}}, imm_i}; // 有符号扩展的立即数, 计算时当做无符号数使用

wire [31:0] rs1_plus_imm_i;
assign rs1_plus_imm_i = rs1_data_i + imm_signed;

wire [31:0] mem_addr;
assign mem_addr = rs1_data_i + imm_signed;

// 有符号数比较
wire rs1_lt_imm_signed;
assign rs1_lt_imm_signed = (rs1_siged < imm_signed);

// 无符号数比较
wire rs1_lt_imm_unsigned; 
assign rs1_lt_imm_unsigned = (rs1_unsiged < imm_unsigned);

wire [31:0] rs1_xor_imm;
assign rs1_xor_imm = rs1_siged ^ imm_signed;

wire [31:0] rs1_or_imm;
assign rs1_or_imm = rs1_siged | imm_signed;

wire [31:0] rs1_and_imm;
assign rs1_and_imm = rs1_siged & imm_signed;

// 左移立即数
wire [31:0] rs1_slli;
assign rs1_slli = rs1_unsiged << shamt;

// 右移立即数
wire [31:0] rs1_srli;
wire [31:0] rs1_srai;
wire [31:0] rs1_sri;
assign rs1_srli = rs1_unsiged >> shamt;
assign rs1_srai = rs1_siged >>> shamt;
assign rs1_sri = (inst_i[30])? rs1_srai:rs1_srli;

// load读内存
wire [31:0] il_lb;
wire [31:0] il_lh;
wire [31:0] il_lw;
wire [31:0] il_lbu;
wire [31:0] il_lhu;
assign il_lb  = {{24{mem_data_i[7]}},mem_data_i[7:0]};
assign il_lh  = {{16{mem_data_i[7]}},mem_data_i[15:0]};
assign il_lw  = mem_data_i[31:0];
assign il_lbu = {24'd0,mem_data_i[7:0]};
assign il_lhu = {16'd0,mem_data_i[15:0]};

// store写内存
wire [31:0] s_sb;
wire [31:0] s_sh;
wire [31:0] s_sw;
assign s_sb = {24'd0,rs2_data_i[7:0]};
assign s_sh = {16'd0,rs2_data_i[15:0]};
assign s_sw = rs2_data_i;
wire [31:0] s_addr;
wire signed [31:0] s_addr_signed = {{20{imm_s[11]}}, imm_s}; // 有符号扩展的立即数
assign s_addr = s_addr_signed + rs1_data_i;

// 加减
wire [31:0] rs1_plus_rs2 ;
wire [31:0] rs1_minus_rs2;
assign rs1_plus_rs2  = rs1_data_i + rs2_data_i;
assign rs1_minus_rs2 = rs1_data_i - rs2_data_i;

// 移位
wire [31:0] rs1_sll_rs2;
wire [31:0] rs1_srl_rs2;
assign rs1_sll_rs2  = rs1_data_i << rs2_data_i;
assign rs1_srl_rs2  = rs1_data_i >> rs2_data_i;

// 比较
wire [31:0] rs1_slt_rs2;
wire [31:0] rs1_sltu_rs2;
assign rs1_slt_rs2  = (rs1_siged < rs2_siged); // 有符号数比较
assign rs1_sltu_rs2 = (rs1_unsiged < rs2_unsiged); // 无符号数比较

// 逻辑运算
wire [31:0] rs1_xor_rs2;
wire [31:0] rs1_and_rs2;
wire [31:0] rs1_or_rs2 ;
assign rs1_xor_rs2 = rs1_siged ^ rs2_siged;
assign rs1_and_rs2 = rs1_siged & rs2_siged;
assign rs1_or_rs2  = rs1_siged | rs2_siged;

// 乘法
wire signed   [63:0] rs1s_mul_rs2s;
wire unsigned [63:0] rs1u_mul_rs2u;
wire signed   [63:0] rs1s_mul_rs2u;
assign rs1s_mul_rs2s = rs1_siged * rs2_siged;
assign rs1u_mul_rs2u = rs1_unsiged * rs2_unsiged;
assign rs1u_mul_rs2s = rs1_siged * rs2_unsiged;

// 条件跳转
wire beq_jump  = (rs1_siged   ==   rs2_siged);
wire bne_jump  = (rs1_siged   !=   rs2_siged);
wire blt_jump  = (rs1_siged   <    rs2_siged);
wire bge_jump  = (rs1_siged   >=   rs2_siged);
wire bltu_jump = (rs1_unsiged <  rs2_unsiged);
wire bgeu_jump = (rs1_unsiged >= rs2_unsiged);
wire [31:0] jump_offset = {{20{inst_i[31]}}, {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]}, 1'b0};
wire [31:0] beq_jump_addr  = (beq_jump ) ? (inst_addr_i + jump_offset) : 32'd0;
wire [31:0] bne_jump_addr  = (bne_jump ) ? (inst_addr_i + jump_offset) : 32'd0;
wire [31:0] blt_jump_addr  = (blt_jump ) ? (inst_addr_i + jump_offset) : 32'd0;
wire [31:0] bge_jump_addr  = (bge_jump ) ? (inst_addr_i + jump_offset) : 32'd0;
wire [31:0] bltu_jump_addr = (bltu_jump) ? (inst_addr_i + jump_offset) : 32'd0;
wire [31:0] bgeu_jump_addr = (bgeu_jump) ? (inst_addr_i + jump_offset) : 32'd0;

// csr
wire [11:0] csr_addr;
assign csr_addr = inst_i[31:20];
wire [31:0] csr_imm_extend;
assign csr_imm_extend = {{27{zimm[4]}}, zimm};

// jump
reg [31:0] jump_addr;
reg        jump_flag;
reg        hold;
assign jump_addr_o = (int_assert_i) ? int_addr_i : jump_addr;
assign hold_o = hold;
assign jump_flag_o = jump_flag || int_assert_i;

always @(*) begin
    // rd_data_o  = 32'd0;
    // rd_addr_o  = 32'd0;
    // rd_we_o    = 1'd0 ;
    // mem_addr_o = 32'd0;
    // mem_data_o = 32'd0;
    // mem_we_o   = 1'd0 ;
    // mem_req_o  = 1'd0 ;
    csr_waddr_o = 12'd0;
    csr_wdata_o = 32'd0;
    csr_we_o    = 1'd0;
    case (opcode)
        `INST_TYPE_I: begin
            case (funct3)
                `INST_ADDI: begin
                    rd_data_o = rs1_plus_imm_i;
                    rd_addr_o = rd_addr_i;
                    rd_we_o   = 1'd1;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_SLTI: begin
                    rd_data_o = rs1_lt_imm_signed;
                    rd_addr_o = rd_addr_i;
                    rd_we_o   = 1'd1;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_SLTIU: begin
                    rd_data_o = rs1_lt_imm_unsigned;
                    rd_addr_o = rd_addr_i;
                    rd_we_o   = 1'd1;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_XORI: begin
                    rd_data_o = rs1_xor_imm;
                    rd_addr_o = rd_addr_i;
                    rd_we_o   = 1'd1;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_ORI: begin
                    rd_data_o = rs1_or_imm;
                    rd_addr_o = rd_addr_i;
                    rd_we_o   = 1'd1;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_ANDI: begin
                    rd_data_o = rs1_and_imm;
                    rd_addr_o = rd_addr_i;
                    rd_we_o   = 1'd1;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_SLLI: begin // 立即数逻辑左移
                    rd_data_o = rs1_slli;
                    rd_addr_o = rd_addr_i;
                    rd_we_o   = 1'd1;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_SRI: begin
                    rd_data_o = rs1_sri;
                    rd_addr_o = rd_addr_i;
                    rd_we_o   = 1'd1;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                default: begin
                    rd_data_o  = 32'd0;
                    rd_addr_o  = 32'd0;
                    rd_we_o    = 1'd0 ;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
            endcase
        end
        `INST_TYPE_I_L: begin 
            
            case (funct3)
                `INST_LB: begin
                    rd_data_o  = il_lb;
                    rd_addr_o  = rd_addr;
                    rd_we_o    = 1'd1;
                    mem_addr_o = mem_addr;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd1 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_LH: begin
                    rd_data_o  = il_lh;
                    rd_addr_o  = rd_addr;
                    rd_we_o    = 1'd1;
                    mem_addr_o = mem_addr;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd1 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_LW: begin
                    rd_data_o  = il_lw;
                    rd_addr_o  = rd_addr;
                    rd_we_o    = 1'd1;
                    mem_addr_o = mem_addr;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd1 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_LBU: begin
                    rd_data_o  = il_lbu;
                    rd_addr_o  = rd_addr;
                    rd_we_o    = 1'd1;
                    mem_addr_o = mem_addr;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd1 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_LHU: begin
                    rd_data_o  = il_lhu;
                    rd_addr_o  = rd_addr;
                    rd_we_o    = 1'd1;
                    mem_addr_o = mem_addr;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd1 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                default: begin
                    rd_data_o  = 32'd0;
                    rd_addr_o  = 32'd0;
                    rd_we_o    = 1'd0 ;
                    mem_addr_o = 32'd0;
                    mem_data_o = 32'd0;
                    mem_we_o   = 1'd0 ;
                    mem_req_o  = 1'd0 ;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
            endcase
        end
        `INST_TYPE_S: begin
            case (funct3)
                `INST_SB: begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   = 32'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = s_addr;
                    mem_req_o   =  1'd1;
                    mem_data_o  =  s_sb;
                    mem_we_o    =  1'd1;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_SH: begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   = 32'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = s_addr;
                    mem_req_o   =  1'd1;
                    mem_we_o    =  1'd1;
                    mem_data_o  =  s_sh;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                `INST_SW:  begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   = 32'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = s_addr;
                    mem_req_o   =  1'd1;
                    mem_data_o  =  s_sw;
                    mem_we_o    =  1'd1;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
                default: begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   = 32'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = 32'd0;
                    mem_req_o   =  1'd0;
                    mem_we_o    =  1'd0;
                    mem_data_o  = 32'd0;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
            endcase
        end
        `INST_TYPE_R_M: begin
            rd_addr_o = rd_addr_i;
            rd_we_o   = 1'd1;
            mem_addr_o = 32'd0;
            mem_data_o = 32'd0;
            mem_we_o   = 1'd0 ;
            mem_req_o  = 1'd0 ;
            jump_addr   = 32'd0;
            jump_flag   =  1'd0;
            hold        =  1'd0;
            case (funct7[0])
                1'd0 : begin
                    case (funct3)
                        `INST_ADD_SUB : begin
                            if(funct7[5]) begin // 减法
                                rd_data_o = rs1_minus_rs2;
                            end
                            else begin  // 加法
                                rd_data_o = rs1_plus_rs2;
                            end
                        end
                        `INST_SLL    : begin // 左移
                            rd_data_o = rs1_sll_rs2;
                        end
                        `INST_SLT    : begin // 有符号数小于
                            rd_data_o = rs1_slt_rs2;
                        end
                        `INST_SLTU   : begin // 无符号数小于
                            rd_data_o = rs1_sltu_rs2;
                        end
                        `INST_XOR    : begin 
                            rd_data_o = rs1_xor_rs2;
                        end
                        `INST_SRL    : begin // 右移
                            rd_data_o = rs1_srl_rs2;
                        end
                        `INST_OR     : begin
                            rd_data_o = rs1_or_rs2;
                        end
                        `INST_AND    : begin
                            rd_data_o = rs1_and_rs2;
                        end
                        default: begin
                            rd_addr_o = 5'd0;
                            rd_we_o   = 1'd0;
                        end
                    endcase
                end
                1'd1 : begin
                    case (funct3)
                        `INST_MUL    :begin
                            rd_data_o = rs1s_mul_rs2s[31:0];
                        end
                        `INST_MULH   :begin
                            rd_data_o = rs1s_mul_rs2s[63:32];
                        end
                        `INST_MULHSU :begin
                            rd_data_o = rs1s_mul_rs2u[63:32];
                        end
                        `INST_MULHU  :begin
                            rd_data_o = rs1u_mul_rs2u[63:32];
                        end
                        `INST_DIV    :begin
                            ;
                        end
                        `INST_DIVU   :begin
                            ;
                        end
                        `INST_REM    :begin
                            ;
                        end
                        `INST_REMU   :begin
                            ;
                        end
                        default: begin
                            rd_addr_o = 5'd0;
                            rd_we_o   = 1'd0;
                        end
                    endcase
                end
                default: begin
                    rd_addr_o = 5'd0;
                    rd_we_o   = 1'd0;
                end
            endcase
        end
        `INST_TYPE_B: begin
            case (funct3)
                `INST_BEQ : begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   =  5'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = 32'd0;
                    mem_data_o  = 32'd0;
                    mem_we_o    =  1'd0;
                    mem_req_o   =  1'd0;
                    jump_addr   = beq_jump_addr;
                    jump_flag   = beq_jump;
                    hold        = beq_jump;
                end
                `INST_BNE : begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   =  5'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = 32'd0;
                    mem_data_o  = 32'd0;
                    mem_we_o    =  1'd0;
                    mem_req_o   =  1'd0;
                    jump_addr   = bne_jump_addr;
                    jump_flag   = bne_jump;
                    hold        = bne_jump;
                end
                `INST_BLT : begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   =  5'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = 32'd0;
                    mem_data_o  = 32'd0;
                    mem_we_o    =  1'd0;
                    mem_req_o   =  1'd0;
                    jump_addr   = blt_jump_addr;
                    jump_flag   = blt_jump;
                    hold        = blt_jump;
                end
                `INST_BGE : begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   =  5'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = 32'd0;
                    mem_data_o  = 32'd0;
                    mem_we_o    =  1'd0;
                    mem_req_o   =  1'd0;
                    jump_addr   = bge_jump_addr;
                    jump_flag   = bge_jump;
                    hold        = bge_jump;
                end
                `INST_BLTU: begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   =  5'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = 32'd0;
                    mem_data_o  = 32'd0;
                    mem_we_o    =  1'd0;
                    mem_req_o   =  1'd0;
                    jump_addr   = bltu_jump_addr;
                    jump_flag   = bltu_jump;
                    hold        = bltu_jump;
                end
                `INST_BGEU: begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   =  5'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = 32'd0;
                    mem_data_o  = 32'd0;
                    mem_we_o    =  1'd0;
                    mem_req_o   =  1'd0;
                    jump_addr   = bgeu_jump_addr;
                    jump_flag   = bgeu_jump;
                    hold        = bgeu_jump;
                end
                default: begin
                    rd_data_o   = 32'd0;
                    rd_addr_o   =  5'd0;
                    rd_we_o     =  1'd0;
                    mem_addr_o  = 32'd0;
                    mem_data_o  = 32'd0;
                    mem_we_o    =  1'd0;
                    mem_req_o   =  1'd0;
                    jump_addr   = 32'd0;
                    jump_flag   =  1'd0;
                    hold        =  1'd0;
                end
            endcase
        end
        `INST_CSR: begin
            rd_data_o   = 32'd0;
            rd_addr_o   =  5'd0;
            rd_we_o     =  1'd0;
            mem_addr_o  = 32'd0;
            mem_data_o  = 32'd0;
            mem_we_o    =  1'd0;
            mem_req_o   =  1'd0;
            jump_addr   = 32'd0;
            jump_flag   =  1'd0;
            hold        =  1'd0;
            case (funct3)
                `INST_CSRRW: begin
                    csr_waddr_o = csr_addr;
                    csr_wdata_o = rs1_siged;
                    csr_we_o    = 1'd1;
                    rd_data_o   = csr_data_i;
                    rd_addr_o   = rd_addr;
                    rd_we_o     = 1'd1;
                end 
                `INST_CSRRS: begin
                    csr_waddr_o = csr_addr;
                    csr_wdata_o = rs1_siged | csr_data_i;
                    csr_we_o    = 1'd1;
                    rd_data_o   = csr_data_i;
                    rd_addr_o   = rd_addr;
                    rd_we_o     = 1'd1;
                end 
                `INST_CSRRC: begin
                    csr_waddr_o = csr_addr;
                    csr_wdata_o = rs1_siged & csr_data_i;
                    csr_we_o    = 1'd1;
                    rd_data_o   = csr_data_i;
                    rd_addr_o   = rd_addr;
                    rd_we_o     = 1'd1;
                end 
                `INST_CSRRWI: begin
                    csr_waddr_o = csr_addr;
                    csr_wdata_o = csr_imm_extend;
                    csr_we_o    = 1'd1;
                    rd_data_o   = csr_data_i;
                    rd_addr_o   = rd_addr;
                    rd_we_o     = 1'd1;
                end
                `INST_CSRRSI: begin
                    csr_waddr_o = csr_addr;
                    csr_wdata_o = csr_imm_extend & csr_data_i;
                    csr_we_o    = 1'd1;
                    rd_data_o   = csr_data_i;
                    rd_addr_o   = rd_addr;
                    rd_we_o     = 1'd1;
                end
                `INST_CSRRCI: begin
                    csr_waddr_o = csr_addr;
                    csr_wdata_o = csr_imm_extend & csr_data_i;
                    csr_we_o    = 1'd1;
                    rd_data_o   = csr_data_i;
                    rd_addr_o   = rd_addr;
                    rd_we_o     = 1'd1;
                end
                default: begin
                    csr_waddr_o = 32'd0;
                    csr_wdata_o = 32'd0;
                    csr_we_o    = 1'd0;
                end
            endcase
        end
        `INST_JAL: begin // 无条件跳转
            rd_data_o   = pc_puls4;
            rd_addr_o   = rd_addr_i;
            rd_we_o     = 1'd1  ;
            mem_addr_o  = 32'd0 ;
            mem_data_o  = 32'd0 ;
            mem_we_o    = 1'd0  ;
            mem_req_o   = 1'd0  ;
            jump_addr   = jal_addr ;
            jump_flag   = 1'd1  ;
            hold        = 1'd1  ;
        end
        `INST_JALR: begin // 无条件跳转
            rd_data_o   = pc_puls4;
            rd_addr_o   = rd_addr_i;
            rd_we_o     = 1'd1  ;
            mem_addr_o  = 32'd0 ;
            mem_data_o  = 32'd0 ;
            mem_we_o    = 1'd0  ;
            mem_req_o   = 1'd0  ;
            jump_addr   = jalr_addr ;
            jump_flag   = 1'd1  ;
            hold        = 1'd1  ;
        end
        `INST_LUI: begin
            rd_addr_o   = rd_addr;
            rd_data_o   = {imm_u, 12'd0};
            rd_we_o     =  1'd1;
            mem_addr_o  = 32'd0;
            mem_data_o  = 32'd0;
            mem_we_o    =  1'd0;
            mem_req_o   =  1'd0;
            jump_addr   = 32'd0;
            jump_flag   =  1'd0;
            hold        =  1'd0;
        end
        `INST_AUIPC: begin
            rd_addr_o   = rd_addr;
            rd_data_o   = {imm_u, 12'd0} + inst_addr_i;
            rd_we_o     = 1'd1;
            mem_addr_o  = 32'd0;
            mem_data_o  = 32'd0;
            mem_we_o    =  1'd0;
            mem_req_o   =  1'd0;
            jump_addr   = 32'd0;
            jump_flag   =  1'd0;
            hold        =  1'd0;
        end
        `INST_NOP_OP: begin
            rd_data_o   = 32'd0;
            rd_addr_o   =  5'd0;
            rd_we_o     =  1'd0;
            mem_addr_o  = 32'd0;
            mem_data_o  = 32'd0;
            mem_we_o    =  1'd0;
            mem_req_o   =  1'd0;
            jump_addr   = 32'd0;
            jump_flag   =  1'd0;
            hold        =  1'd0;
        end
        default: begin
            rd_data_o   = 32'd0;
            rd_addr_o   =  5'd0;
            rd_we_o     =  1'd0;
            mem_addr_o  = 32'd0;
            mem_data_o  = 32'd0;
            mem_we_o    =  1'd0;
            mem_req_o   =  1'd0;
            jump_addr   = 32'd0;
            jump_flag   =  1'd0;
            hold        =  1'd0;
        end
    endcase
end

endmodule


