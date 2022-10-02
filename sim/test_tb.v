
`timescale 1 ns / 1 ps

module tb;

reg       clk;
reg       rst_n;

integer n ,i;

always #5 clk = ~clk;

top u_top(
    .clk   (clk   ),
    .rst_n (rst_n )
);


initial begin
    $readmemh ("inst.data", u_top.u_rom._rom);
    for(i=0;i<10;i=i+1)begin   //把八个存储单元的数字都读取出来，若存的数不到八个单元输出x态，程序结果中会看到
		$display("%h",u_top.u_rom._rom[i]);
	end
end

reg [31:0] inst1, inst2, inst3, inst4, inst5, inst6;

initial begin
    clk  = 1'b0;
    rst_n = 1'b1;
    #10;
    rst_n = 1'b0;
    #10;
    rst_n = 1'b1;
    $display("Hello ICARUS verilog!");
    #1000;
    inst1 = u_top.u_rom._rom[1];
    inst2 = u_top.u_rom._rom[2];
    inst3 = u_top.u_rom._rom[3];
    inst4 = u_top.u_rom._rom[4];
    inst5 = u_top.u_rom._rom[5];
    inst6 = u_top.u_rom._rom[6];
    
    #1000;
    #30000;
    $finish;
end

// always @(cnt)begin
//     $display("%0t, cnt=%d",$time,cnt);
// end

reg [15:0] aa, bb;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        aa <= 16'b0;
    end
    else begin
        aa <= aa + 1'd1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        bb <= 16'd0;
    end
    else begin
        bb <= aa;
    end
end


wire lt1, lt2;

reg [31:0] num1, num2;

initial begin
    #20;
    num1 = 32'd5;
    num2 = 32'd6;
    #20;
    num1 = 32'd8;
    num2 = 32'd6;
    #20;
    num1 = -32'd5;
    num2 = 32'd6;
end

wire [31:0] n1, n2;
assign n1 = num1;
assign n2 = num2;

wire signed [31:0] n3; 
wire        [31:0] n4;

assign n3 = num1;
assign n4 = num2;

assign lt1 = (n1 < n2);
assign lt2 = (n3 < n4);


reg        [31:0] m1, m2;
reg signed [31:0] m3, m4;
reg signed [63:0] m5;
reg        [63:0] m6;
wire signed [63:0] mul_res1;
wire        [63:0] mul_res2;

assign mul_res1 = m1 * m2;
assign mul_res2 = m3 * m4;

initial begin
    m1 = 32'd3;
    m2 = -32'd5;
    m3 = 32'd3;
    m4 = -32'd5;
    #20;
    m5 = m2;
    m6 = m2;
end

initial
begin
   $dumpfile("tb.vcd");
   $dumpvars(0,tb);
end
 
endmodule

