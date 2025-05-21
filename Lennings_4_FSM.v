module top_module(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging 
); 

    // State encoding
    parameter LEFT       = 3'd0,
              RIGHT      = 3'd1,
              FALLL      = 3'd2,
              FALLR      = 3'd3,
              DIGL       = 3'd4,
              DIGR       = 3'd5,
              SPLAT      = 3'd6;

    reg [2:0] state, next_state;
    reg [7:0] count_20_clk;

    

    // Next state logic
    always @(*) begin
        case (state)
            LEFT: begin
                if (~ground)
                    next_state = FALLL;
                else if (dig)
                    next_state = DIGL;
                else if (bump_left)
                    next_state = RIGHT;
                else
                    next_state = LEFT;
            end

            RIGHT: begin
                if (~ground)
                    next_state = FALLR;
                else if (dig)
                    next_state = DIGR;
                else if (bump_right)
                    next_state = LEFT;
                else
                    next_state = RIGHT;
            end

            FALLL: begin
                if (~ground)
                    next_state = FALLL;
                else
                    next_state = (count_20_clk > 8'd20) ? SPLAT : LEFT;
            end

            FALLR: begin
                if (~ground)
                    next_state = FALLR;
                else
                    next_state = (count_20_clk > 8'd20) ? SPLAT : RIGHT;
            end

            DIGL: begin
                if (~ground)
                    next_state = FALLL;
                else
                    next_state = DIGL;
            end

            DIGR: begin
                if (~ground)
                    next_state = FALLR;
                else
                    next_state = DIGR;
            end

            SPLAT: next_state = SPLAT;

            default: next_state = LEFT;
        endcase
    end
    
    // State transition (with async reset)
    always @(posedge clk or posedge areset) begin
        if (areset)
            state <= LEFT;
        else
            state <= next_state;
    end

    // Fall counter (only increments when not on ground)
    always @(posedge clk or posedge areset) begin 
        if (areset)
            count_20_clk <= 8'd0;
        else
            count_20_clk <= (~ground) ? count_20_clk + 8'd1 : 8'd0;
    end

    // Output logic (Moore-style FSM)
    assign walk_left  = (state == LEFT);
    assign walk_right = (state == RIGHT);
    assign aaah       = (state == FALLL) || (state == FALLR);
    assign digging    = (state == DIGL)  || (state == DIGR);

endmodule
