module ram (
    input clk   ,
    input rst_n ,
    input wire we_i,                   // write enable
    input wire[31:0] addr_i,    // addr
    input wire[31:0] data_i,

    output reg[31:0] data_o         // read data

);

reg [31:0] _ram[0:4095];

// write
always @(posedge clk ) begin
    if(we_i) begin
        _ram[addr_i[31:2]] = data_i;
    end
end

// read
always @(*) begin
    if(!rst_n)begin
        data_o = 32'd0;
    end
    else begin
        data_o = _ram[addr_i[31:2]];
    end
end

endmodule
