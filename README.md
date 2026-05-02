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

## Target configuration

Both targets instantiate the same `WREB_v4_base` entity, parameterised by a
`RebConfigType` record (defined in
`submodules/lsst_reb/reb_config/rtl/reb_config_pkg.vhd`).

| Field | Type | Description |
|-------|------|-------------|
| `numSequencers` | 1 | Number of sequencer instances |
| `sysClkPer` | real | System clock period (seconds) |
| `gdAddr` | 4-bit | Guard drain DAC channel address |
| `odAddr` | 4-bit | Output drain DAC channel address |
| `rdAddr` | 4-bit | Reset drain DAC channel address |
| `gdThresh` | integer×3 | Guard drain threshold per sensor |
| `odThresh` | integer×3 | Output drain threshold per sensor |
| `rdThresh` | integer×3 | Reset drain threshold per sensor |
| `reserved_1` | 32-bit | DAQ index for location-limited targets |
| `reserved_2` | 32-bit | Reserved |
| `reserved_3` | 32-bit | Reserved |

The single sequencer drives one wavefront sensor.

Both WREB targets use the same configuration values: `gdAddr=0x0`,
`odAddr=0x5`, `rdAddr=0x1`, `gdThresh=(1138,0,0)`, `odThresh=(2275,0,0)`,
`rdThresh=(1632,0,0)`. Elements 1 and 2 are zero because the WREB has only
one active sensor.

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
