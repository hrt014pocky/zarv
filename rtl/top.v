module top (
    input clk   ,
    input rst_n
    
);

wire [31:0] pc_addr, pc_data;
wire hold;

wire [31:0] m0_addr_i;
wire [31:0] m1_addr_i;
wire [31:0] m2_addr_i;
wire [31:0] m3_addr_i;
wire [31:0] m0_data_i;
wire [31:0] m1_data_i;
wire [31:0] m2_data_i;
wire [31:0] m3_data_i;
wire [31:0] m0_data_o;
wire [31:0] m1_data_o;
wire [31:0] m2_data_o;
wire [31:0] m3_data_o;
wire m0_we_i  ;
wire m1_we_i  ;
wire m2_we_i  ;
wire m3_we_i  ;
wire m0_req   ;
wire m1_req   ;
wire m2_req   ;
wire m3_req   ;

wire [31:0] s0_addr_o;
wire [31:0] s1_addr_o;
wire [31:0] s2_addr_o;
wire [31:0] s3_addr_o;
wire [31:0] s4_addr_o;
wire [31:0] s5_addr_o;
wire [31:0] s0_data_i;
wire [31:0] s1_data_i;
wire [31:0] s2_data_i;
wire [31:0] s3_data_i;
wire [31:0] s4_data_i;
wire [31:0] s5_data_i;
wire [31:0] s0_data_o;
wire [31:0] s1_data_o;
wire [31:0] s2_data_o;
wire [31:0] s3_data_o;
wire [31:0] s4_data_o;
wire [31:0] s5_data_o;
wire s0_we_o  ;
wire s1_we_o  ;
wire s2_we_o  ;
wire s3_we_o  ;
wire s4_we_o  ;
wire s5_we_o  ;
wire xbus_hold;
wire timer_int;

core u_core(
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .pc_addr_o    (m1_addr_i    ),
    .pc_data_i    (m1_data_o    ),
    .ex_addr_o    (m0_addr_i    ),
    .ex_data_o    (m0_data_i    ),
    .ex_data_i    (m0_data_o    ),
    .ex_we_o      (m0_we_i      ),
    .ex_req_o     (m0_req       ),
    .xbus_hold_i  (xbus_hold    ),
    .jtag_hold_i  (jtag_hold    ),
    .uart_hold_i  (uart_hold    ),
    .timer_int_i  (timer_int    )
);

xbus u_xbus(
    .clk       (clk       ),
    .rst_n     (rst_n     ),
    .m0_addr_i (m0_addr_i ),
    .m0_data_i (m0_data_i ),
    .m0_data_o (m0_data_o ),
    .m0_we_i   (m0_we_i   ),
    .m0_req    (m0_req    ),
    .m1_addr_i (m1_addr_i ),
    .m1_data_i (32'd0     ),
    .m1_data_o (m1_data_o ),
    .m1_we_i   (1'd0      ),
    .m1_req    (1'd1      ),
    .m2_addr_i (m2_addr_i ),
    .m2_data_i (m2_data_i ),
    .m2_data_o (m2_data_o ),
    .m2_we_i   (m2_we_i   ),
    .m2_req    (m2_req    ),
    .m3_addr_i (m3_addr_i ),
    .m3_data_i (m3_data_i ),
    .m3_data_o (m3_data_o ),
    .m3_we_i   (m3_we_i   ),
    .m3_req    (m3_req    ),
    .s0_addr_o (s0_addr_o ),
    .s0_data_i (s0_data_i ),
    .s0_data_o (s0_data_o ),
    .s0_we_o   (s0_we_o   ),
    .s1_addr_o (s1_addr_o ),
    .s1_data_i (s1_data_i ),
    .s1_data_o (s1_data_o ),
    .s1_we_o   (s1_we_o   ),
    .s2_addr_o (s2_addr_o ),
    .s2_data_i (s2_data_i ),
    .s2_data_o (s2_data_o ),
    .s2_we_o   (s2_we_o   ),
    .s3_addr_o (s3_addr_o ),
    .s3_data_i (s3_data_i ),
    .s3_data_o (s3_data_o ),
    .s3_we_o   (s3_we_o   ),
    .s4_addr_o (s4_addr_o ),
    .s4_data_i (s4_data_i ),
    .s4_data_o (s4_data_o ),
    .s4_we_o   (s4_we_o   ),
    .s5_addr_o (s5_addr_o ),
    .s5_data_i (s5_data_i ),
    .s5_data_o (s5_data_o ),
    .s5_we_o   (s5_we_o   ),
    .hold_o    (xbus_hold )
);

rom u_rom(
    .clk    (clk         ),
    .rst_n  (rst_n       ),
    .we_i   (s0_we_o     ),
    .addr_i (s0_addr_o   ),
    .data_i (s0_data_o   ),
    .data_o (s0_data_i   )
);

ram u_ram(
    .clk    (clk       ),
    .rst_n  (rst_n     ),
    .we_i   (s1_we_o   ),
    .addr_i (s1_addr_o ),
    .data_i (s1_data_o ),
    .data_o (s1_data_i )
);

timer u_timer(
    .clk    (clk          ),
    .rst_n  (rst_n        ),
    .data_i (s2_data_o    ),
    .addr_i (s2_addr_o    ),
    .we_i   (s2_we_o      ),
    .data_o (s2_data_i    ),
    .int    (timer_int    )
);


endmodule