module core (
    input clk   ,
    input rst_n ,

    output [31:0] pc_addr_o  ,
    input  [31:0] pc_data_i  ,

    output [31:0] ex_addr_o  ,
    output [31:0] ex_data_o  ,
    input  [31:0] ex_data_i  ,
    output        ex_we_o    ,
    output        ex_req_o   ,
    input         xbus_hold_i,
    input         jtag_hold_i,
    input         uart_hold_i,
    input         timer_int_i

);

wire [31:0] inst_addr, inst;
wire [31:0] id_inst_addr, id_inst;
wire [ 4:0] id_rd_addr;
wire [31:0] id_rs1_data, id_rs2_data;

wire [ 4:0] id_ex_rd_addr_o ;
wire [ 4:0] id_ex_rs1_addr_o;
wire [31:0] id_ex_rs1_data_o;
wire [ 4:0] id_ex_rs2_addr_o;
wire [31:0] id_ex_rs2_data_o;
wire [31:0] id_ex_inst_addr;
wire [31:0] id_ex_inst     ;

wire [31:0] ex_rd_data ;
wire [ 4:0] ex_rd_addr ;
wire        ex_rd_we   ;
wire        ex_hold_flag;

wire [ 4:0] rd_addr ;
wire [31:0] rd_data ;
wire        rd_we   ;
wire [ 4:0] rs1_addr;
wire [31:0] rs1_data;
wire [ 4:0] rs2_addr;
wire [31:0] rs2_data;

wire [31:0] csr_data_to_ex;
wire [31:0] csr_data_to_idex;
wire [11:0] csr_id_addr;
wire [31:0] csr_id_data;
wire [11:0] csr_ex_addr;
wire [31:0] csr_ex_data;
wire        csr_ex_we  ;
wire [31:0] csr_intc_rdata;
wire [11:0] csr_intc_addr ;
wire [31:0] csr_intc_wdata;
wire        csr_intc_we   ;
wire [31:0] csr_mtvec;  
wire [31:0] csr_mepc;   
wire [31:0] csr_mstatus;

wire [31:0] int_addr  ;
wire        int_assert;
wire intc_hold;

wire ex_hold  ;
wire [2:0] hold_flag;
wire jump_flag;
wire [31:0] jump_addr;

pc u_pc(
    .clk               (clk               ),
    .rst_n             (rst_n             ),
    .jump_flag_i       (jump_flag         ),
    .jump_addr_i       (jump_addr         ),
    .hold_flag_i       (hold_flag         ),
    .jtag_reset_flag_i (1'd0              ),
    .pc_o              (pc_addr_o         )
);

if_id u_if_id(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
    .inst_addr_i (pc_addr_o   ),
    .inst_i      (pc_data_i   ),
    .jump_addr_i (jump_addr   ),
    .hold_flag_i (hold_flag   ),
    .inst_addr_o (inst_addr   ),
    .inst_o      (inst        )
);

regs u_regs(
    .clk         (clk            ),
    .rst_n       (rst_n          ),
    .rd_addr_i   (ex_rd_addr     ),
    .rd_data_i   (ex_rd_data     ),
    .rd_we_i     (ex_rd_we       ),
    .rs1_addr_i  (rs1_addr       ),
    .rs1_data_o  (rs1_data       ),
    .rs2_addr_i  (rs2_addr       ),
    .rs2_data_o  (rs2_data       )
);


id u_id(
    .clk         (clk              ),
    .rst_n       (rst_n            ),
    .inst_addr_i (inst_addr        ),
    .inst_i      (inst             ),
    .rs1_data_i  (rs1_data         ),
    .rs2_data_i  (rs2_data         ),
    .inst_addr_o (id_inst_addr     ),
    .inst_o      (id_inst          ),
    .rd_addr_o   (id_rd_addr       ),
    .rs1_addr_o  (rs1_addr         ),
    .rs1_data_o  (id_rs1_data      ),
    .rs2_addr_o  (rs2_addr         ),
    .rs2_data_o  (id_rs2_data      ),
    .csr_data_i  (csr_id_data      ),
    .csr_addr_o  (csr_id_addr      ),
    .csr_data_o  (csr_data_to_idex )
);

id_ex u_id_ex(
    .clk         (clk               ),
    .rst_n       (rst_n             ),
    .inst_addr_i (id_inst_addr      ),
    .inst_i      (id_inst           ),
    .rd_addr_i   (id_rd_addr        ),
    .rs1_addr_i  (rs1_addr          ),
    .rs1_data_i  (id_rs1_data       ),
    .rs2_addr_i  (rs2_addr          ),
    .rs2_data_i  (id_rs2_data       ),
    .csr_data_i  (csr_data_to_idex  ),
    .inst_addr_o (id_ex_inst_addr   ),
    .inst_o      (id_ex_inst        ),
    .hold_flag_i (hold_flag         ),
    .rd_addr_o   (id_ex_rd_addr_o   ),
    .rs1_addr_o  (id_ex_rs1_addr_o  ),
    .rs1_data_o  (id_ex_rs1_data_o  ),
    .rs2_addr_o  (id_ex_rs2_addr_o  ),
    .rs2_data_o  (id_ex_rs2_data_o  ),
    .csr_data_o  (csr_data_to_ex    )
);

ex u_ex(
    .clk              (clk              ),
    .rst_n            (rst_n            ),
    .inst_addr_i      (id_ex_inst_addr  ),
    .inst_i           (id_ex_inst       ),
    .rd_addr_i        (id_ex_rd_addr_o  ),
    .rs1_addr_i       (id_ex_rs1_addr_o ),
    .rs1_data_i       (id_ex_rs1_data_o ),
    .rs2_addr_i       (id_ex_rs2_addr_o ),
    .rs2_data_i       (id_ex_rs2_data_o ),
    .csr_data_i       (csr_data_to_ex   ),
    .mem_addr_o       (ex_addr_o        ),
    .mem_data_o       (ex_data_o        ),
    .mem_data_i       (ex_data_i        ),
    .mem_we_o         (ex_we_o          ),
    .mem_req_o        (ex_req_o         ),
    .rd_data_o        (ex_rd_data       ),
    .rd_addr_o        (ex_rd_addr       ),
    .rd_we_o          (ex_rd_we         ),
    .ex_hold_o        (ex_hold          ),
    .csr_waddr_o      (csr_ex_addr      ),
    .csr_wdata_o      (csr_ex_data      ),
    .csr_we_o         (csr_ex_we        ),
    .int_addr_i       (int_addr         ),
    .int_assert_i     (int_assert       ),
    .jump_addr_o      (jump_addr        ),
    .jump_flag_o      (jump_flag        ),
    .hold_o           (ex_hold_flag     )
);

ctrl u_ctrl(
    .clk              (clk            ),
    .rst_n            (rst_n          ),
    .ex_hold_i        (ex_hold_flag   ),
    .xbus_hold_i      (xbus_hold_i    ),
    .jtag_hold_i      (jtag_hold_i    ),
    .uart_hold_i      (uart_hold_i    ),
    .intc_hold_i      (intc_hold      ),
    .jump_flag_i      (jump_flag      ),
    .hold_o           (hold_flag      )
);

csr_regs u_csr_regs(
    .clk              (clk            ),
    .rst_n            (rst_n          ),
    .csr_id_addr_i    (csr_id_addr    ),
    .csr_id_data_o    (csr_id_data    ),
    .csr_ex_addr_i    (csr_ex_addr    ),
    .csr_ex_data_i    (csr_ex_data    ),
    .csr_ex_we_i      (csr_ex_we      ),
    .csr_intc_data_o  (csr_intc_rdata ),
    .csr_intc_addr_i  (csr_intc_addr  ),
    .csr_intc_data_i  (csr_intc_wdata ),
    .csr_intc_we_i    (csr_intc_we    ),
    .csr_mtvec        (csr_mtvec      ),
    .csr_mepc         (csr_mepc       ),
    .csr_mstatus      (csr_mstatus    )
);

intc u_intc(
    .clk             (clk             ),
    .rst_n           (rst_n           ),
    .int_i           (timer_int_i     ),
    .inst_addr_i     (id_inst_addr    ),
    .inst_i          (id_inst         ),
    .csr_data_i      (csr_intc_rdata  ),
    .csr_data_o      (csr_intc_wdata  ),
    .csr_addr_o      (csr_intc_addr   ),
    .csr_we_o        (csr_intc_we     ),
    .csr_mtvec       (csr_mtvec       ),
    .csr_mepc        (csr_mepc        ),
    .csr_mstatus     (csr_mstatus     ),
    .hold_o          (intc_hold       ),
    .int_addr_o      (int_addr        ),
    .int_assert_o    (int_assert      )
);



endmodule

