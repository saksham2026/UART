// This is interfacing of the uart reciver with the main system.
module flag_buff
#(
    parameter W = 8
)
(
    input wire clk, reset,
    input wire clr_flag, set_flag,
    input wire [W-1, 0] d_in,
    output wire flag,
    output wire [W-1,0] d_out
);

    // signal declaration
    reg [W-1 : 0] buff_reg, buff_next;
    reg flag_reg, flag_next;

    // body
    // next_state assignment
    always@(posedge clk)
        begin
            if(reset) 
                begin
                flag_reg <= 0;
                buff_reg <= 0;
                end
            else
                begin
                flag_reg <= flag_next;
                buff_reg <= buff_next;
                end    
        end

    // FSMD flag_next logic
    always@(*)
        begin
            flag_next = flag_reg;
            if(clr_flag)
                flag_next = 1'b0;
            else if(set_flag)
                flag_next = 1'b1;    
        end 
    // FSMD buff_next logic
        always@(*)
            begin
                buff_next = buff_reg;
                if(set_flag)
                    buff_next <= din;
            end
    // output
    assign flag = flag_reg;
    assign d_out = buff_reg;               
endmodule
