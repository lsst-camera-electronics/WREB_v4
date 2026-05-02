# WREB_v4

Firmware for the LSST Wavefront Raft Electronics Board (WREB), version 4.
Targets a Xilinx Kintex-7 (XC7K160T) FPGA. Built with the ruckus framework
and Vivado.

## Build targets

| Target | System clock |
|--------|--------------|
| `WREB_v4` | 10 ns (100 MHz) |
| `WREB_v4_6p4ns` | 6.4 ns (156.25 MHz) |

Both targets use the same RTL and produce identical register-level behaviour.

## Repository layout

| Path | Contents |
|------|----------|
| `targets/WREB_v4/` | Top-level entity, constraints, build scripts, binary images |
| `targets/WREB_v4_6p4ns/` | Same structure, high-speed variant |
| `common/command_interpreter/` | Register decode and command routing |
| `common/wreb_v4_base/` | Board-level integration entity |
| `submodules/` | External dependencies (see below) |
| `build/` | Vivado project trees (local, not committed) |

## Submodules

| Submodule | Purpose |
|-----------|---------|
| `lsst_reb` | Shared REB IP library (sequencer, peripheral drivers) |
| `lsst_sci` | Science data path (PGP, image readout) |
| `surf` | SLAC firmware utilities |
| `ruckus` | Build framework |

## Building

Builds require Vivado 2025.1 and are run via ruckus:

```
cd targets/WREB_v4
make
```

Binary outputs (`.bit.gz`, `.mcs.gz`) are committed to
`targets/<target>/images/`.

## Register map

See [`REGISTERS.md`](REGISTERS.md) for the full register address map.

## Documentation

- Sequencer architecture: [`submodules/lsst_reb/sequencer_v4/SEQUENCER_THEORY.md`](submodules/lsst_reb/sequencer_v4/SEQUENCER_THEORY.md)
- Sequencer testbench: [`submodules/lsst_reb/sequencer_v4/TB/README.md`](submodules/lsst_reb/sequencer_v4/TB/README.md)
