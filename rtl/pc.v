module pc (
    input clk   ,
    input rst_n ,
    input wire jump_flag_i,         // 跳转标志
    input wire[31:0] jump_addr_i,   // 跳转地址
    input wire[2:0] hold_flag_i,    // 流水线暂停标志
    input wire jtag_reset_flag_i,   // 复位标志

    output reg[31:0] pc_o           // PC指针
);

always @(posedge clk) begin
    if(!rst_n || jtag_reset_flag_i) begin
        pc_o <= 32'd0;
    end
    else if(jump_flag_i) begin
        pc_o <= jump_addr_i; 
    end
    else if(hold_flag_i >= 3'd1) begin
        pc_o <= pc_o; 
    end
    else begin
        pc_o <= pc_o + 4'd4;
    end
end

endmodule
