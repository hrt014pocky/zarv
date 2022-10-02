module timer (
    input clk   ,
    input rst_n ,
    input       [31:0] data_i,
    input       [31:0] addr_i,
    input              we_i,
    output reg  [31:0] data_o,
    output             int

);


// 0x20000000 timer control reg  0:en  1:inten  2:intpend 写1清零
// 0x20000004 timer count reg
// 0x20000008 timer value reg
parameter CTRL_ADDR  = 4'h0;
parameter COUNT_ADDR = 4'h4;
parameter VALUE_ADDR = 4'h8;


reg [31:0] ctrl;
reg [31:0] count;
reg [31:0] value;

// interrupt signal
assign int = ctrl[1] && ctrl[2];

// count
always @(posedge clk) begin
    if(!rst_n) begin
        count <= 32'd0;
    end
    else begin
        if(ctrl[0]) begin
            if(count >= value) begin
                count <= 32'd0;
            end
            else begin
                count <= count + 1'd1;
            end
        end
        else begin
            count <= 32'd0;
        end
    end
end

// data read
always @(*) begin
    if(!rst_n) begin
        data_o = 32'd0;
    end
    else begin
        case (addr_i[3:0])
            CTRL_ADDR: begin // ctrl
                data_o = ctrl;
            end
            COUNT_ADDR: begin // count
                data_o = count;
            end
            VALUE_ADDR: begin // value
                data_o = value;
            end
            default: begin
                data_o = 32'd0;
            end
        endcase
    end
end

// data write
always @(posedge clk ) begin
    if(!rst_n) begin
        ctrl  <= 32'd0;
        value <= 32'd0;
    end
    else begin
        if(we_i) begin
            case (addr_i[3:0])
                CTRL_ADDR: begin
                    ctrl  <= {data_i[31:3], ~data_i[2], data_i[1:0]}; // pending写1清零 
                end
                VALUE_ADDR:begin
                    value <= data_i;
                end
                default: begin
                    
                end
            endcase
        end
        else begin
            if((count == value) && (ctrl[1] == 1)) begin
                ctrl[0] = 1'd0;
                ctrl[2] = 1'd1;
            end
        end
    end
end



endmodule

