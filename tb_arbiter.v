`timescale 1ns/1ps

module tb_arbiter;
    parameter N_REQ = 4;

    reg clk;
    reg rst_n;
    reg [N_REQ-1:0] req;
    reg grant_ready;
    wire [N_REQ-1:0] grant;

    integer i;
    reg [N_REQ-1:0] expected;

    round_robin_arbiter #(.N_REQ(N_REQ)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .grant_ready(grant_ready),
        .grant(grant)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        req = {N_REQ{1'b0}};
        grant_ready = 1'b0;

        // Reset
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        #1;

        // No requests means no grant.
        if (grant !== {N_REQ{1'b0}})
            $fatal(1, "FAIL: grant should be zero when there are no requests");

        // All requesters contend. Accepted grants should rotate 0,1,2,3.
        req = {N_REQ{1'b1}};
        grant_ready = 1'b1;
        for (i = 0; i < N_REQ; i = i + 1) begin
            expected = ({{(N_REQ-1){1'b0}}, 1'b1} << i);
            #1;
            if (grant !== expected)
                $fatal(1, "FAIL: expected grant %b, got %b", expected, grant);

            @(posedge clk);
            #1;
        end

        // With priority wrapped to requester 0, requests 1 and 3 are active.
        // Requester 1 should be selected first.
        @(negedge clk);
        req = (1 << 3) | (1 << 1);
        grant_ready = 1'b0;
        #1;
        if (grant !== (1 << 1))
            $fatal(1, "FAIL: expected requester 1 for req=1010, got %b", grant);

        // Grant must be one-hot-or-zero.
        if ((grant != 0) && ((grant & (grant - 1'b1)) != 0))
            $fatal(1, "FAIL: grant is not one-hot");

        $display("PASS: SmartArbiter basic tests passed.");
        $finish;
    end
endmodule
