// instruction fetch

module if_id (
    input clk   ,
    input rst_n ,

    input [31:0] inst_addr_i,
    input [31:0] inst_i,
    input [31:0] jump_addr_i,
    input [2:0 ] hold_flag_i,
    output reg [31:0] inst_addr_o,
    output reg [31:0] inst_o
);

always @(posedge clk) begin
    if(!rst_n) begin
        inst_addr_o <= 32'd0;
    end
    else if(hold_flag_i > 3'd1) begin
        inst_addr_o <= jump_addr_i;
    end
    else begin
        inst_addr_o <= inst_addr_i;
    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        inst_o <= 32'd0;
    end
    else if(hold_flag_i > 3'd1) begin
        inst_o <= 32'd1;
    end
    else begin
        inst_o <= inst_i;
    end
end

endmodule