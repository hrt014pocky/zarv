module xbus (
    input clk   ,
    input rst_n ,
    
    // ex
    input      [31:0] m0_addr_i,
    input      [31:0] m0_data_i,
    output reg [31:0] m0_data_o,
    input             m0_we_i,
    input             m0_req,

    // pc
    input      [31:0] m1_addr_i,
    input      [31:0] m1_data_i,
    output reg [31:0] m1_data_o,
    input             m1_we_i,
    input             m1_req,

    // jtag
    input      [31:0] m2_addr_i,
    input      [31:0] m2_data_i,
    output reg [31:0] m2_data_o,
    input             m2_we_i,
    input             m2_req,

    // uart
    input      [31:0] m3_addr_i,
    input      [31:0] m3_data_i,
    output reg [31:0] m3_data_o,
    input             m3_we_i,
    input             m3_req,

    // rom
    output reg [31:0] s0_addr_o,
    input      [31:0] s0_data_i,
    output reg [31:0] s0_data_o,
    output reg        s0_we_o,

    // ram
    output reg [31:0] s1_addr_o,
    input      [31:0] s1_data_i,
    output reg [31:0] s1_data_o,
    output reg        s1_we_o,

    // timer
    output reg [31:0] s2_addr_o,
    input      [31:0] s2_data_i,
    output reg [31:0] s2_data_o,
    output reg        s2_we_o,

    // uart
    output reg [31:0] s3_addr_o,
    input      [31:0] s3_data_i,
    output reg [31:0] s3_data_o,
    output reg        s3_we_o,

    // gpio
    output reg [31:0] s4_addr_o,
    input      [31:0] s4_data_i,
    output reg [31:0] s4_data_o,
    output reg        s4_we_o,

    // spi
    output reg [31:0] s5_addr_o,
    input      [31:0] s5_data_i,
    output reg [31:0] s5_data_o,
    output reg        s5_we_o  ,

    output reg        hold_o
);

localparam ZERO = 32'd0;
localparam WE_DISABLE = 1'd0;
localparam NOP = 32'd1;


// 总线仲裁
localparam MASTER0 = 4'b0001;
localparam MASTER1 = 4'b0010;
localparam MASTER2 = 4'b0100;
localparam MASTER3 = 4'b1000;
reg [3:0] grant;

always @(*) begin
    if(m3_req) begin
        grant  = MASTER3;
        hold_o = 1'd1;
    end
    else if(m0_req) begin
        grant  = MASTER0;
        hold_o = 1'd1;
    end
    else if(m2_req) begin
        grant  = MASTER2;
        hold_o = 1'd1;
    end
    else begin
        grant  = MASTER1;
        hold_o = 1'd0;
    end
end


always @(*) begin
    
    m0_data_o = ZERO;
    m1_data_o = NOP;
    m2_data_o = ZERO;
    m3_data_o = ZERO;

    s0_addr_o = ZERO;
    s0_data_o = ZERO;
    s0_we_o   = WE_DISABLE;

    s1_addr_o = ZERO;
    s1_data_o = ZERO;
    s1_we_o   = WE_DISABLE;

    s2_addr_o = ZERO;
    s2_data_o = ZERO;
    s2_we_o   = WE_DISABLE;

    s3_addr_o = ZERO;
    s3_data_o = ZERO;
    s3_we_o   = WE_DISABLE;

    s4_addr_o = ZERO;
    s4_data_o = ZERO;
    s4_we_o   = WE_DISABLE;

    s5_addr_o = ZERO;
    s5_data_o = ZERO;
    s5_we_o   = WE_DISABLE;

    case (grant)
        MASTER0: begin
            case (m0_addr_i[31:28])
                4'd0: begin
                    s0_addr_o = {4'd0, m0_addr_i[27:0]};
                    s0_data_o = m0_data_i;
                    m0_data_o = s0_data_i;
                    s0_we_o   = m0_we_i;
                end
                4'd1: begin
                    s1_addr_o = {4'd0, m0_addr_i[27:0]};
                    s1_data_o = m0_data_i;
                    m0_data_o = s1_data_i;
                    s1_we_o   = m0_we_i;
                end
                4'd2: begin
                    s2_addr_o = {4'd0, m0_addr_i[27:0]};
                    s2_data_o = m0_data_i;
                    m0_data_o = s2_data_i;
                    s2_we_o   = m0_we_i;
                end
                4'd3: begin
                    s3_addr_o = {4'd0, m0_addr_i[27:0]};
                    s3_data_o = m0_data_i;
                    m0_data_o = s3_data_i;
                    s3_we_o   = m0_we_i;
                end
                4'd4: begin
                    s4_addr_o = {4'd0, m0_addr_i[27:0]};
                    s4_data_o = m0_data_i;
                    m0_data_o = s4_data_i;
                    s4_we_o   = m0_we_i;
                end
                4'd5: begin
                    s5_addr_o = {4'd0, m0_addr_i[27:0]};
                    s5_data_o = m0_data_i;
                    m0_data_o = s5_data_i;
                    s5_we_o   = m0_we_i;
                end
                default: 
                begin
                    
                end
            endcase
        end
        MASTER1: begin
            case (m1_addr_i[31:28])
                4'd0: begin
                    s0_addr_o = {4'd0, m1_addr_i[27:0]};
                    s0_data_o = m1_data_i;
                    m1_data_o = s0_data_i;
                    s0_we_o   = m1_we_i;
                end
                4'd1: begin
                    s1_addr_o = {4'd0, m1_addr_i[27:0]};
                    s1_data_o = m1_data_i;
                    m1_data_o = s1_data_i;
                    s1_we_o   = m1_we_i;
                end
                4'd2: begin
                    s2_addr_o = {4'd0, m1_addr_i[27:0]};
                    s2_data_o = m1_data_i;
                    m1_data_o = s2_data_i;
                    s2_we_o   = m1_we_i;
                end
                4'd3: begin
                    s3_addr_o = {4'd0, m1_addr_i[27:0]};
                    s3_data_o = m1_data_i;
                    m1_data_o = s3_data_i;
                    s3_we_o   = m1_we_i;
                end
                4'd4: begin
                    s4_addr_o = {4'd0, m1_addr_i[27:0]};
                    s4_data_o = m1_data_i;
                    m1_data_o = s4_data_i;
                    s4_we_o   = m1_we_i;
                end
                4'd5: begin
                    s5_addr_o = {4'd0, m1_addr_i[27:0]};
                    s5_data_o = m1_data_i;
                    m1_data_o = s5_data_i;
                    s5_we_o   = m1_we_i;
                end
                default: 
                begin
                    
                end
            endcase
        end
        MASTER2: begin
            case (m2_addr_i[31:28])
                4'd0: begin
                    s0_addr_o = {4'd0, m2_addr_i[27:0]};
                    s0_data_o = m2_data_i;
                    m2_data_o = s0_data_i;
                    s0_we_o   = m2_we_i;
                end
                4'd1: begin
                    s1_addr_o = {4'd0, m2_addr_i[27:0]};
                    s1_data_o = m2_data_i;
                    m2_data_o = s1_data_i;
                    s1_we_o   = m2_we_i;
                end
                4'd2: begin
                    s2_addr_o = {4'd0, m2_addr_i[27:0]};
                    s2_data_o = m2_data_i;
                    m2_data_o = s2_data_i;
                    s2_we_o   = m2_we_i;
                end
                4'd3: begin
                    s3_addr_o = {4'd0, m2_addr_i[27:0]};
                    s3_data_o = m2_data_i;
                    m2_data_o = s3_data_i;
                    s3_we_o   = m2_we_i;
                end
                4'd4: begin
                    s4_addr_o = {4'd0, m2_addr_i[27:0]};
                    s4_data_o = m2_data_i;
                    m2_data_o = s4_data_i;
                    s4_we_o   = m2_we_i;
                end
                4'd5: begin
                    s5_addr_o = {4'd0, m2_addr_i[27:0]};
                    s5_data_o = m2_data_i;
                    m2_data_o = s5_data_i;
                    s5_we_o   = m2_we_i;
                end
                default: 
                begin
                    
                end
            endcase
        end
        MASTER3: begin
            case (m3_addr_i[31:28])
                4'd0: begin
                    s0_addr_o = {4'd0, m3_addr_i[27:0]};
                    s0_data_o = m3_data_i;
                    m3_data_o = s0_data_i;
                    s0_we_o   = m3_we_i;
                end
                4'd1: begin
                    s1_addr_o = {4'd0, m3_addr_i[27:0]};
                    s1_data_o = m3_data_i;
                    m3_data_o = s1_data_i;
                    s1_we_o   = m3_we_i;
                end
                4'd2: begin
                    s2_addr_o = {4'd0, m3_addr_i[27:0]};
                    s2_data_o = m3_data_i;
                    m3_data_o = s2_data_i;
                    s2_we_o   = m3_we_i;
                end
                4'd3: begin
                    s3_addr_o = {4'd0, m3_addr_i[27:0]};
                    s3_data_o = m3_data_i;
                    m3_data_o = s3_data_i;
                    s3_we_o   = m3_we_i;
                end
                4'd4: begin
                    s4_addr_o = {4'd0, m3_addr_i[27:0]};
                    s4_data_o = m3_data_i;
                    m3_data_o = s4_data_i;
                    s4_we_o   = m3_we_i;
                end
                4'd5: begin
                    s5_addr_o = {4'd0, m3_addr_i[27:0]};
                    s5_data_o = m3_data_i;
                    m3_data_o = s5_data_i;
                    s5_we_o   = m3_we_i;
                end
                default: 
                begin
                    
                end
            endcase
        end
        default: begin
            
        end
    endcase
end



endmodule