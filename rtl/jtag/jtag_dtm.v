
module jtag_dtm (
    input rst_n ,

    input  TCK,
    input  TMS,
    input  TDI,
    output reg TDO


);


parameter DTM_TAP_REG_IDCODE = 5'b00001;
parameter DTM_TAP_REG_DTMCS  = 5'b10000;
parameter DTM_TAP_REG_DMI    = 5'b10001;
parameter DTM_TAP_REG_BYPASS = 5'b11111;

localparam TEXT_LOGIC_RESET = 4'h0;
localparam RUN_TEXT_IDLE    = 4'h1;
localparam SELECT_DR_SCAN   = 4'h2;
localparam CAPTURE_DR       = 4'h3;
localparam SHIFT_DR         = 4'h4;
localparam EXIT1_DR         = 4'h5;
localparam PASUE_DR         = 4'h6;
localparam EXIT2_DR         = 4'h7;
localparam UPDATE_DR        = 4'h8;
localparam SELECT_IR_SCAN   = 4'h9;
localparam CAPTURE_IR       = 4'hA;
localparam SHIFT_IR         = 4'hB;
localparam EXIT1_IR         = 4'hC;
localparam PASUE_IR         = 4'hD;
localparam EXIT2_IR         = 4'hE;
localparam UPDATE_IR        = 4'hF;

reg [ 4:0] ir_reg;
reg [39:0] shift_reg;
reg [31:0] idcode;

wire      dmi_hard_reset;
wire      dmi_rest;
reg [2:0] dtmcs_idle;
reg [5:0] dtmcs_abits;
reg [3:0] dtmcs_version;

wire [31:0] dtmcs;



reg [3:0] tap_state, next_state;

always @(posedge TCK or negedge rst_n) begin
    if(!rst_n) begin
        tap_state <= TEXT_LOGIC_RESET;
    end
    else begin
        tap_state <= next_state;
    end
end

always @(*) begin
    case (tap_state)
        TEXT_LOGIC_RESET : next_state = TMS ? TEXT_LOGIC_RESET  : RUN_TEXT_IDLE;
        RUN_TEXT_IDLE    : next_state = TMS ? SELECT_DR_SCAN    : RUN_TEXT_IDLE;
        SELECT_DR_SCAN   : next_state = TMS ? SELECT_IR_SCAN    : CAPTURE_DR;
        CAPTURE_DR       : next_state = TMS ? EXIT1_DR          : SHIFT_DR;
        SHIFT_DR         : next_state = TMS ? EXIT1_DR          : SHIFT_DR;
        EXIT1_DR         : next_state = TMS ? UPDATE_DR         : PASUE_DR;
        PASUE_DR         : next_state = TMS ? EXIT2_DR          : PASUE_DR;
        EXIT2_DR         : next_state = TMS ? UPDATE_DR         : SHIFT_DR;
        UPDATE_DR        : next_state = TMS ? SELECT_DR_SCAN    : RUN_TEXT_IDLE;
        SELECT_IR_SCAN   : next_state = TMS ? TEXT_LOGIC_RESET  : CAPTURE_IR;
        CAPTURE_IR       : next_state = TMS ? EXIT1_IR          : SHIFT_IR;
        SHIFT_IR         : next_state = TMS ? EXIT1_IR          : SHIFT_IR;
        EXIT1_IR         : next_state = TMS ? UPDATE_IR         : PASUE_IR;
        PASUE_IR         : next_state = TMS ? EXIT2_IR          : PASUE_IR;
        EXIT2_IR         : next_state = TMS ? UPDATE_IR         : SHIFT_IR;
        UPDATE_IR        : next_state = TMS ? SELECT_DR_SCAN    : RUN_TEXT_IDLE;
        default: begin
            
        end
    endcase
end

always @(posedge TCK) begin
    case (tap_state)
        CAPTURE_IR : begin
            shift_reg <= {35'd0, DTM_TAP_REG_IDCODE};
        end
        SHIFT_IR : begin
            shift_reg <= {35'd0, {TDI, shift_reg[4:1]}};
        end
        CAPTURE_DR: begin
            case (ir_reg)
                DTM_TAP_REG_IDCODE: shift_reg <= {8'd0, idcode};
                DTM_TAP_REG_DTMCS : shift_reg <= {8'd0, dtmcs};
                DTM_TAP_REG_DMI   : shift_reg <= 0; // TODO 
                DTM_TAP_REG_BYPASS: shift_reg <= 40'd0;
            endcase
        end
        SHIFT_DR:begin
            case (ir_reg)
                DTM_TAP_REG_IDCODE: shift_reg <= {8'd0, TDI, shift_reg[31:1]};
                DTM_TAP_REG_DTMCS : shift_reg <= {8'd0, TDI, shift_reg[31:1]};
                DTM_TAP_REG_DMI   : shift_reg <= 0; // TODO
                DTM_TAP_REG_BYPASS: shift_reg <= 0; // TODO
            endcase
        end
        default: begin
            shift_reg <= shift_reg;
        end
    endcase
end


// TAP reset
always @(posedge TCK) begin
    if(tap_state == TEXT_LOGIC_RESET) begin
        ir_reg <= DTM_TAP_REG_IDCODE;
    end
    else if(tap_state == UPDATE_IR) begin
        ir_reg <= shift_reg[4:0];
    end
end

// TDO output
always @(posedge TCK) begin
    if(tap_state == SHIFT_IR) begin
        TDO <= shift_reg[0];
    end
    else if(tap_state == SHIFT_DR) begin
        TDO <= shift_reg[0];
    end
    else begin
        TDO <= 1'd0;
    end
end

endmodule


