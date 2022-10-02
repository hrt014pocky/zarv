module id_ex (
    input              clk           ,
    input              rst_n         ,

    input      [31:0]  inst_addr_i   ,
    input      [31:0]  inst_i        ,

    input      [ 2:0]  hold_flag_i   ,

    input      [ 4:0]  rd_addr_i     ,
    input      [ 4:0]  rs1_addr_i    ,
    input      [31:0]  rs1_data_i    ,

    input      [ 4:0]  rs2_addr_i    ,
    input      [31:0]  rs2_data_i    ,
    input      [31:0]  csr_data_i    ,

    output reg [31:0]  inst_addr_o   ,
    output reg [31:0]  inst_o        ,

    output reg [ 4:0]  rd_addr_o     ,

    output reg [ 4:0]  rs1_addr_o    ,
    output reg [31:0]  rs1_data_o    ,

    output reg [ 4:0]  rs2_addr_o    ,
    output reg [31:0]  rs2_data_o    ,
    output reg [31:0]  csr_data_o
);

always @(posedge clk) begin
    if(!rst_n) begin
        inst_addr_o <= 32'd0;
        inst_o      <= 32'd0;
        rd_addr_o   <=  5'd0;
        rs1_addr_o  <=  5'd0;
        rs1_data_o  <= 32'd0;
        rs2_addr_o  <=  5'd0;
        rs2_data_o  <= 32'd0;
        csr_data_o  <= 32'd0;
    end
    else if(hold_flag_i > 3'd1) begin
        inst_addr_o <= 32'd0;
        inst_o      <= 32'd1;
        rd_addr_o   <=  5'd0;
        rs1_addr_o  <=  5'd0;
        rs1_data_o  <= 32'd0;
        rs2_addr_o  <=  5'd0;
        rs2_data_o  <= 32'd0;
        csr_data_o  <= 32'd0;
    end
    else begin
        inst_addr_o <= inst_addr_i;
        inst_o      <= inst_i     ;
        rd_addr_o   <= rd_addr_i  ;
        rs1_addr_o  <= rs1_addr_i ;
        rs1_data_o  <= rs1_data_i ;
        rs2_addr_o  <= rs2_addr_i ;
        rs2_data_o  <= rs2_data_i ;
        csr_data_o  <= csr_data_i ;
    end
end


endmodule
