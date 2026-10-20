// SmartArbiter: parameterized round-robin arbiter
// grant is combinational; priority advances only when grant_ready is high
// at a rising clock edge and at least one request is granted.
module round_robin_arbiter #(
    parameter N_REQ = 4
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire [N_REQ-1:0]     req,
    input  wire                 grant_ready,
    output reg  [N_REQ-1:0]     grant
);

    localparam PTR_W = (N_REQ <= 1) ? 1 : $clog2(N_REQ);

    reg [PTR_W-1:0] priority_ptr;
    integer offset;
    integer scan_idx;
    integer k;
    reg found;

    // Select the first active request starting at priority_ptr.
    always @(*) begin
        grant = {N_REQ{1'b0}};
        found = 1'b0;
        scan_idx = 0;

        for (offset = 0; offset < N_REQ; offset = offset + 1) begin
            scan_idx = priority_ptr + offset;
            if (scan_idx >= N_REQ)
                scan_idx = scan_idx - N_REQ;

            if (!found && req[scan_idx]) begin
                grant[scan_idx] = 1'b1;
                found = 1'b1;
            end
        end
    end

    // Move priority to the requester after the accepted grant.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            priority_ptr <= {PTR_W{1'b0}};
        end else if (grant_ready && (|grant)) begin
            // Exactly one bit of grant can be set.
            if (grant[N_REQ-1])
                priority_ptr <= {PTR_W{1'b0}};
            else begin
                for (k = 0; k < N_REQ; k = k + 1) begin
                    if (grant[k])
                        priority_ptr <= k + 1;
                end
            end
        end
    end

endmodule
