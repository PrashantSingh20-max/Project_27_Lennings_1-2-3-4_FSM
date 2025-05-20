module top_module(
    input clk,
    input areset,         // Freshly brainwashed Lemmings walk left.
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
    parameter left = 0, right = 1, falll = 2, fallr = 3, digl = 4, digr = 5;

    reg [2:0] cs, ns;

    // Next-state logic using if-else
    always @(*) begin
        if (cs == left) begin
            if (~ground)
                ns = falll;
            else if (dig)
                ns = digl;
            else if (bump_left)
                ns = right;
            else
                ns = left;
        end
        else if (cs == right) begin
            if (~ground)
                ns = fallr;
            else if (dig)
                ns = digr;
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
        else if (cs == digl) begin
            if (ground)
                ns = digl;
            else
                ns = falll;
        end
        else if (cs == digr) begin
            if (ground)
                ns = digr;
            else
                ns = fallr;
        end
        else begin
            ns = left; // default fallback
        end
    end

    // State register update (synchronous logic with async reset)
    always @(posedge clk or posedge areset) begin
        if (areset)
            cs <= left;
        else
            cs <= ns;
    end

    // Output logic (Moore machine style)
    assign walk_left  = (cs == left);
    assign walk_right = (cs == right);
    assign aaah       = (cs == falll) || (cs == fallr);
    assign digging    = (cs == digl)  || (cs == digr);

endmodule
