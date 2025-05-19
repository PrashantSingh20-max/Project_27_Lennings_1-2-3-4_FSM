module top_module(
    input clk,
    input areset,         // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    output walk_left,
    output walk_right,
    output aaah 
);

    // State encoding
    parameter left = 0, right = 1, falll = 3, fallr = 4;

    // 3-bit state registers
    reg [2:0] cs, ns;

    // Next-state logic using only if-else
    always @(*) begin
        if (cs == left) begin
            if (~ground)
                ns = falll;
            else if (bump_left)
                ns = right;
            else
                ns = left;
        end
        else if (cs == right) begin
            if (~ground)
                ns = fallr;
            else if (bump_right)
                ns = left;
            else
                ns = right;
        end
        else if (cs == falll) begin
            if (ground)
                ns = left;
            else
                ns = falll;
        end
        else if (cs == fallr) begin
            if (ground)
                ns = right;
            else
                ns = fallr;
        end
        else begin
            ns = left;  // safe fallback default
        end
    end

    // State register update logic
    always @(posedge clk or posedge areset) begin
        if (areset)
            cs <= left;
        else
            cs <= ns;
    end

    // Output logic (Moore machine)
    assign walk_left  = (cs == left);
    assign walk_right = (cs == right);
    assign aaah       = (cs == falll) || (cs == fallr);

endmodule
