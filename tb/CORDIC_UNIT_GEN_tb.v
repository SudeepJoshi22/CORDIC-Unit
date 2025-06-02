`timescale 1ns/1ps

module CORDIC_UNIT_tb;

    // ------------------------------------------------------------
    // Parameter declarations (match the DUT)
    // ------------------------------------------------------------
    parameter N = 32;
    parameter I = 20;   // Q1.30 implies 1 integer bit and 30 fractional bits

    // ------------------------------------------------------------
    // Signal declarations
    // ------------------------------------------------------------
    reg                         clk;
    reg                         rst_n;
    reg                         start;
    reg  signed [N-1:0]         Xi;
    reg  signed [N-1:0]         Yi;
    reg  signed [N-1:0]         Zi;
    reg                         rot_vec;   // 0 = rotation mode, 1 = vectoring mode

    wire signed [N-1:0]         Xr;
    wire signed [N-1:0]         Yr;
    wire signed [N-1:0]         Zr;
    wire                        done;

    // ------------------------------------------------------------
    // Instantiate the DUT
    // ------------------------------------------------------------
    CORDIC_UNIT #(
        .N(N),
        .I(I)
    ) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (start),
        .Xi      (Xi),
        .Yi      (Yi),
        .Zi      (Zi),
        .rot_vec (rot_vec),
        .Xr      (Xr),
        .Yr      (Yr),
        .Zr      (Zr),
        .done    (done)
    );

    // ------------------------------------------------------------
    // Clock generation: 10 ns period (100 MHz)
    // ------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ------------------------------------------------------------
    // Test‐vector application
    // ------------------------------------------------------------
    initial begin
        // 1) Initialize all inputs
        rst_n    = 1'b0;
        start    = 1'b0;
        Xi       = {N{1'b0}};
        Yi       = {N{1'b0}};
        Zi       = {N{1'b0}};
        rot_vec  = 1'b0;

        // 2) Hold reset for a few clock cycles
        #20;            // wait 20 ns
        rst_n = 1'b1;   // deassert reset
        #20;

        // ----------------------------------------------------
        // Test Case 1: Rotation mode (rot_vec = 0)
        //   Rotate the vector (X = 0.8, Y = 0.2) by +30° (π/6).
        //   All values are in Q1.30 (signed 32-bit).
        //
        //   Constants (in Q1.30):
        //     0.8      = 32'h3333_3333
        //     0.2      = 32'h0CCC_CCCD
        //     +π/6     = 32'h2182_A470
        // ----------------------------------------------------
        @(posedge clk);
        rot_vec = 1'b0;                            // rotation mode
        Xi      = 32'h3333_3333;  // ≈ 0.8 in Q1.30
        Yi      = 32'h0CCC_CCCD;  // ≈ 0.2 in Q1.30
        Zi      = 32'h2182_A470;  // ≈ +0.5235988 (π/6) in Q1.30
        start   = 1'b1;
        @(posedge clk);
        start   = 1'b0;   // pulse start

        // Wait for 'done' to assert
        wait (done == 1'b1);
        #10;  // small delay to let outputs settle

        $display("----- Test 1: Rotation Mode -----");
        $display(" Xi = 0x%08h   Yi = 0x%08h   Zi = 0x%08h", Xi, Yi, Zi);
        $display("→ Results: Xr = 0x%08h   Yr = 0x%08h   Zr = 0x%08h", Xr, Yr, Zr);
        $display("");

        // ----------------------------------------------------
        // Test Case 2: Vectoring mode (rot_vec = 1)
        //   Vector‐mode input: (X = 0.6, Y = 0.8), Zi = 0.
        //   Should compute magnitude ≈ 1.0, and Zr ≈ atan(0.8/0.6).
        //
        //   Constants (in Q1.30):
        //     0.6           = 32'h2666_6666
        //     0.8           = 32'h3333_3333
        //     initial Z = 0 = 32'h0000_0000
        //     atan(0.8/0.6) ≈ 0.9272952 rad = 32'h3B58_CE0B
        // ----------------------------------------------------
        @(posedge clk);
        rot_vec = 1'b1;                            // vectoring mode
        Xi      = 32'h2666_6666;  // ≈ 0.6 in Q1.30
        Yi      = 32'h3333_3333;  // ≈ 0.8 in Q1.30
        Zi      = 32'h0000_0000;  // start angle = 0
        start   = 1'b1;
        @(posedge clk);
        start   = 1'b0;

        // Wait for 'done' to assert
        wait (done == 1'b1);
        #10;

        $display("----- Test 2: Vectoring Mode -----");
        $display(" Xi = 0x%08h   Yi = 0x%08h   Zi = 0x%08h", Xi, Yi, Zi);
        $display("→ Results: Xr = 0x%08h   Yr = 0x%08h   Zr = 0x%08h", Xr, Yr, Zr);
        $display("");

        // ----------------------------------------------------
        // End of simulation
        // ----------------------------------------------------
        #20;
        $finish;
    end

    // ------------------------------------------------------------
    // Optional: monitor done signal and outputs at each clock
    // ------------------------------------------------------------
    initial begin
        $display("Time(ns) | rst_n | start | rot_vec |    Xi     |    Yi     |    Zi     |   Xr     |   Yr     |   Zr     | done");
        $monitor("%8t |   %b   |   %b   |    %b    | %08h | %08h | %08h | %08h | %08h | %08h |   %b",
                  $time, rst_n, start, rot_vec, Xi, Yi, Zi, Xr, Yr, Zr, done);
    end

endmodule
