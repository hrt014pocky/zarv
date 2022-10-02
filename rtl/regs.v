module regs (
    input clk   ,
    input rst_n ,
    
    // destination registers
    input [ 4:0] rd_addr_i,
    input [31:0] rd_data_i,
    input        rd_we_i,

    // source registers
    input      [ 4:0] rs1_addr_i,
    output reg [31:0] rs1_data_o,
    input      [ 4:0] rs2_addr_i,
    output reg [31:0] rs2_data_o
);

// x0~x31
reg [31:0] regs [0:31];

// write rd
always @(posedge clk) begin
    if(!clk) begin
        
    end
    else if(rd_we_i && (rd_addr_i != 4'd0)) begin
        regs[rd_addr_i] <= rd_data_i;
    end
end

// read rs1
always @(*) begin
    if(rs1_addr_i == 4'd0) begin
        rs1_data_o = 32'd0;
    end
    else if((rs1_addr_i == rd_addr_i) && (rd_we_i)) begin
        rs1_data_o = rd_data_i;
    end
    else begin
        rs1_data_o = regs[rs1_addr_i];
    end
end

// read rs2
always @(*) begin
    if(rs2_addr_i == 4'd0) begin
        rs2_data_o = 32'd0;
    end
    else if((rs2_addr_i == rd_addr_i) && (rd_we_i)) begin
        rs2_data_o = rd_data_i;
    end
    else begin
        rs2_data_o = regs[rs2_addr_i];
    end
end


wire [31:0] x0;
wire [31:0] x1;
wire [31:0] x2;
wire [31:0] x3;
wire [31:0] x4;
wire [31:0] x5;
wire [31:0] x6;
wire [31:0] x7;
wire [31:0] x8;
wire [31:0] x9;
wire [31:0] x10;
wire [31:0] x11;
wire [31:0] x12;
wire [31:0] x13;
wire [31:0] x14;
wire [31:0] x15;
wire [31:0] x16;
wire [31:0] x17;
wire [31:0] x18;
wire [31:0] x19;
wire [31:0] x20;
wire [31:0] x21;
wire [31:0] x22;
wire [31:0] x23;
wire [31:0] x24;
wire [31:0] x25;
wire [31:0] x26;
wire [31:0] x27;
wire [31:0] x28;
wire [31:0] x29;
wire [31:0] x30;
wire [31:0] x31;



assign  x0 = regs[  0];
assign  x1 = regs[  1];
assign  x2 = regs[  2];
assign  x3 = regs[  3];
assign  x4 = regs[  4];
assign  x5 = regs[  5];
assign  x6 = regs[  6];
assign  x7 = regs[  7];
assign  x8 = regs[  8];
assign  x9 = regs[  9];
assign x10 = regs[ 10];
assign x11 = regs[ 11];
assign x12 = regs[ 12];
assign x13 = regs[ 13];
assign x14 = regs[ 14];
assign x15 = regs[ 15];
assign x16 = regs[ 16];
assign x17 = regs[ 17];
assign x18 = regs[ 18];
assign x19 = regs[ 19];
assign x20 = regs[ 20];
assign x21 = regs[ 21];
assign x22 = regs[ 22];
assign x23 = regs[ 23];
assign x24 = regs[ 24];
assign x25 = regs[ 25];
assign x26 = regs[ 26];
assign x27 = regs[ 27];
assign x28 = regs[ 28];
assign x29 = regs[ 29];
assign x30 = regs[ 30];
assign x31 = regs[ 31];

endmodule

