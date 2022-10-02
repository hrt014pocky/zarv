`include "define.v"

// 流水线控制

module ctrl (
    input clk   ,
    input rst_n ,
    input ex_hold_i,
    input xbus_hold_i,
    input jtag_hold_i,
    input uart_hold_i,
    input intc_hold_i,
    input jump_flag_i,
    output reg [2:0] hold_o
);

always @(*) begin
    if(uart_hold_i) begin
        hold_o = `Hold_Id; // 整条流水线暂停
    end
    else if(ex_hold_i) begin
        hold_o = `Hold_Id; // 整条流水线暂停
    end
    else if(intc_hold_i) begin
        hold_o = `Hold_Id; // 整条流水线暂停
    end
    else if(jump_flag_i) begin
        hold_o = `Hold_Id; // 整条流水线暂停
    end
    else if(jtag_hold_i) begin
        hold_o = `Hold_Id; // 整条流水线暂停
    end
    else if(xbus_hold_i) begin
        hold_o = `Hold_Pc; // PC计数暂停
    end
    else begin
        hold_o = `Hold_None;
    end
end


endmodule