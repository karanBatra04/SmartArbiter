# SmartArbiter

A parameterized round-robin arbiter written in Verilog. It selects one active requester from a set of simultaneous requests and rotates priority after an accepted grant.

## Features

- Parameterized requester count (`N_REQ`, default 4)
- Round-robin priority rotation
- One-hot-or-zero grant output
- Active-low asynchronous reset
- Grant advances only when `grant_ready` is high and a request is granted
- Basic simulation testbench for no-request behavior, priority rotation, and one-hot grant behavior

## Interface

| Signal | Direction | Description |
|---|---|---|
| `clk` | input | Clock |
| `rst_n` | input | Active-low asynchronous reset |
| `req[N_REQ-1:0]` | input | One bit per requester; 1 means requesting access |
| `grant_ready` | input | Indicates the selected grant was accepted at the clock edge |
| `grant[N_REQ-1:0]` | output | One-hot-or-zero grant vector |

## Arbitration behavior

The arbiter scans requests starting from `priority_ptr`, wrapping around to requester 0 as needed. It grants the first active request it finds. When `grant_ready` is high at a rising edge and a grant is active, the next priority starts after the granted requester.

**Handshake assumption:** the requester/consumer system should treat a grant as accepted only at a rising edge where `grant_ready` is high. This implementation does not lock a grant while `grant_ready` is low; because grant selection is combinational, changes to `req` can change `grant` before acceptance.

## Run the basic simulation

Requires Icarus Verilog.

```bash
iverilog -g2012 -s tb_arbiter -o results/tb_arbiter.vvp rtl/arbiter.v tb/tb_arbiter.v
vvp results/tb_arbiter.vvp
```

Expected success message:

```text
PASS: SmartArbiter basic tests passed.
```

Run this command yourself before claiming the test passed in your portfolio.

## Synthesis (optional)

If Yosys is installed, a generic synthesis run can be attempted with:

```bash
yosys -p "read_verilog rtl/arbiter.v; hierarchy -top round_robin_arbiter; proc; opt; check; stat"
```

This produces generic synthesis statistics, not a physical chip area, silicon power measurement, or sign-off timing result.

## Limitations

- The supplied testbench is a basic smoke test, not exhaustive verification.
- Fairness assumes requests remain asserted as needed and grants continue to be accepted.
- No formal verification, CDC analysis, or technology-specific physical implementation is included.
- Test results and synthesis numbers should be reported only after running the tools.

## Repository layout

```text
SmartArbiter/
├── rtl/arbiter.v
├── tb/tb_arbiter.v
├── docs/interview-notes.md
├── results/.gitkeep
├── README.md
└── .gitignore
```
