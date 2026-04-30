# Benchmark and Example Cases

The best way to start a new CHAPSim2 setup is to copy the closest existing case
and then edit `input_chapsim.ini`. The `tests/` directory contains compact cases
used for smoke and regression checks. The `examples/` directory contains
postprocessing scripts and reference data for selected production-style cases.

## Case Families

| Family | Representative test cases | Main purpose |
| --- | --- | --- |
| Taylor-Green vortex | `tgv_iso`, `tgv_scp` | Periodic validation case for core numerics, scalar/thermal coupling, and regression metrics. |
| Channel flow | `channel_iso_periodic`, `channel_iso_inout`, `channel_scp_*` | Wall-bounded Cartesian cases, periodic or inlet/outlet, isothermal or thermal. |
| Pipe flow | `pipe_iso_periodic`, `pipe_iso_inout`, `pipe_scp_*` | Cylindrical wall-bounded cases with radial/azimuthal constraints. |
| Annular flow | `annular_iso_periodic`, `annular_iso_inout`, `annular_scp_*` | Cylindrical annular cases with inner and outer wall treatment. |

Suffixes in case names are used consistently:

| Suffix | Meaning |
| --- | --- |
| `iso` | Isothermal flow. |
| `scp` | Scalar/thermal property case. |
| `periodic` | Periodic streamwise direction, usually driven by pressure gradient or flow-rate control. |
| `inout` | Inlet/outlet case. |
| `Tw` | Wall-temperature thermal boundary condition. |
| `qw` | Wall-heat-flux thermal boundary condition. |

## Recommended Starting Points

| Goal | Start from |
| --- | --- |
| First successful solver run | `tests/tgv_iso` |
| Periodic channel DNS | `tests/channel_iso_periodic` |
| Channel inlet/outlet setup | `tests/channel_iso_inout` |
| Periodic pipe DNS | `tests/pipe_iso_periodic` |
| Pipe inlet/outlet setup | `tests/pipe_iso_inout` |
| Annular periodic setup | `tests/annular_iso_periodic` |
| Thermal wall-temperature case | closest `*_Tw` case |
| Thermal wall-heat-flux case | closest `*_qw` case |

After copying a case, check:

1. `[domain] icase` and domain lengths.
2. `[mesh] ncx`, `ncy`, `ncz`, `istret`, and `rstret`.
3. `[flow] initfl`, `ren`, `idriven`, and boundary-condition choices.
4. `[thermo]` only when thermal/scalar physics is required.
5. `[io]` and `[statistics]` output frequency before launching production runs.

## Example Postprocessing Assets

| Example path | Content |
| --- | --- |
| `examples/channel_iso_periodic/case/2_visu/` | Channel velocity/stress plotting and wall-unit postprocessing scripts. |
| `examples/channel_iso_periodic/MKM180_profiles/` | Reference profile data for channel comparison. |
| `examples/channel_iso_periodic/MKM395_profiles/` | Higher-Re channel reference profiles. |
| `examples/pipe_iso_periodic/case/2_visu/` | Pipe velocity/stress plotting scripts. |
| `examples/pipe_iso_periodic/TDL180/` | Pipe reference data at friction Reynolds number near 180. |
| `examples/pipe_iso_periodic/TDL550/` | Pipe reference data at higher friction Reynolds number. |
| `examples/3_monitor/` | Generic monitor plotting scripts. |
| `examples/4_check/` | Generic mesh-check plotting script. |

## How Benchmarks Fit the Workflow

Use benchmark cases in three stages:

1. **Build confidence:** run a small smoke or TGV case after compiling.
2. **Create a new setup:** copy the closest case and adjust the input file.
3. **Validate results:** compare monitor histories, mean profiles, stresses, and
   reference data where available.

For automated checking, see [Regression and Smoke Tests](testing.md). For
profile plotting and visualisation, see [Postprocessing and Output Data](postprocessing.md).
