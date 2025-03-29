module uart_rx
    #(
        parameter SB_TICK = 16, // # ticks for stop bits
        DBIT = 8 // # data bit 
    )
    ( 
        input wire clk, reset,
        input wire rx, s_tick,
        output reg rx_done_tick,
        output wire [7:0] dout
    );

    // symbolic state declaration
    localparam [1:0]
    idle = 2'b00,
    start = 2'b01,
    data = 2'b10,
    stop = 2'b11;

    // signal declaration
    reg [1:0] state_reg, next_state;
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next; 

    // body
    always@(posedge clk, posedge reset)
        begin
            if(reset) begin
                state_reg <= idle;
                s_reg <= 0;
                n_reg <= 0;
                b_reg <= 0;
            end else begin
                state_reg <= next_state;
                s_reg <= s_next;
                n_reg <= n_next;
                b_reg <= b_next;
            end
        end
    // FSMD next state logic
    always@(*)
        begin
            next_state = state_reg;
            n_next = n_reg;
            b_next = b_reg;
            s_next = s_reg;
            case(state_reg)
                idle :
                    if(~rx)
                        begin
                            next_state = start;
                            s_next = 0;
                        end
                start :
                    if(s_tick)
                        if(s_reg == 7)
                            begin
                                state_next = data;
                                s_next = 0;
                                n_next = 0;
                            end
                        else 
                            s_next = s_reg + 1;
                data :
                    if(s_tick)
                        if(s_reg == 15)
                            s_next = 0;
                            if(n_reg == D_BIT)
                                state_next = stop;
                            else
                                begin
                                n_next = n_reg + 1;
                                b_next = {rx,b_reg[DBIT-1:1]};
                                end
                        else 
                            s_next = s_reg + 1;     
                stop :
                    if(s_tick)
                        if(s_reg == SB_TICK)
                            begin
                            state_next = idle;
                            rx_done_tick = 1'b1;     
                            end  
                        else
                            s_next = s_reg + 1;                                                
            endcase 
        end
        // output
        assign dout = b_reg;    
endmodule