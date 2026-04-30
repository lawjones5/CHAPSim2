# Postprocessing and Output Data

CHAPSim2 writes several classes of output. The best postprocessing route depends
on whether you need restart data, flow-field visualisation, monitor histories, or
statistical profiles.

## Output Folders

| Folder | Main content | Typical use |
| --- | --- | --- |
| `1_data/` | Restart/checkpoint data and domain files | Restarting, interpolation, wall-unit postprocessing, and low-level data checks. |
| `2_visu/` | Visualisation files, commonly XDMF/HDF-style outputs | ParaView or VisIt inspection, field slices, and flow snapshots. |
| `3_monitor/` | Monitor history files and plotting scripts | Bulk quantities, point probes, convergence checks, and transient diagnostics. |
| `4_check/` | Mesh and setup check outputs | Mesh quality, grid distribution, and early validation plots. |

Not every case writes every folder. Output depends on the switches and
frequencies in `[io]`, `[statistics]`, and related input-file sections.

## Visualisation Data

Visualisation is controlled mainly by `visu_idim`, `visu_nfre`, and
`visu_nskip` in the input file. Full-domain and plane outputs can be opened in
ParaView or VisIt when XDMF files are present.

Common example scripts:

| Script | Purpose |
| --- | --- |
| `examples/channel_iso_periodic/case/2_visu/plot_channel_velo_stress.py` | Plot channel mean velocity and Reynolds-stress profiles. |
| `examples/channel_iso_periodic/case/2_visu/postprocess_channel_wall_units.py` | Convert channel output to wall-unit profiles. |
| `examples/pipe_iso_periodic/case/2_visu/plot_pipe_velo_stress_v2.py` | Plot pipe velocity and stress statistics with robust figure saving. |
| `examples/pipe_iso_periodic/case/2_visu/plot_pipe_velo_stress.py` | Earlier pipe profile plotting script. |

For production postprocessing, copy the closest example script into the case
directory, update the run index, mesh/domain assumptions, and file paths, then
run it from the folder containing the output files.

## Monitor Data

Monitor output is useful for deciding whether a run is healthy before expensive
statistics are trusted. The examples include:

| Script | Purpose |
| --- | --- |
| `examples/3_monitor/plot_monitor_bulk_change_history.py` | Plot bulk-value evolution. |
| `examples/3_monitor/plot_monitor_points.py` | Plot monitor-point histories. |
| `examples/3_monitor/plot_monitor_points_seperate.py` | Plot monitor points in separate figures. |
| `examples/channel_iso_periodic/case/3_monitor/plot_monitor_bulk_change_history.py` | Case-local channel monitor plotting. |
| `examples/pipe_iso_periodic/case/3_monitor/plot_monitor_points.py` | Case-local pipe monitor plotting. |

Recommended checks:

- CFL remains within the intended range.
- Flow rate, pressure gradient, or driving force reaches the expected regime.
- Monitor points do not show sudden jumps after restart.
- Statistics are not started until the transient period has passed.

## Statistics Levels

The input variable `stat_level` controls how much statistical output is gathered.
Use the lowest level that contains the quantities you need, because higher
levels can increase memory, I/O, and postprocessing cost.

| `stat_level` | Meaning | Typical use |
| --- | --- | --- |
| `0` | Statistics disabled | Startup tests, mesh checks, and short smoke runs. |
| `1` | Basic mean quantities | Mean-flow development and light monitoring. |
| `2` | Second-order statistics | Reynolds stresses and most wall-bounded turbulence profiles. |
| `3` | Extended statistics where supported | Detailed budgets or advanced diagnostics. |

Use `stat_istart`, `stat_nskip`, and related sampling controls to avoid
collecting statistics during the initial transient.

## Mesh and Setup Checks

Before trusting a new case, inspect the mesh:

```bash
python3 examples/4_check/plot_check_mesh.py
```

Case-local copies also exist, for example:

- `examples/channel_iso_periodic/case/4_check/plot_check_mesh.py`
- `examples/pipe_iso_periodic/case/4_check/plot_check_mesh.py`

Check near-wall spacing, stretching smoothness, and whether the physical domain
matches the intended geometry.

## Practical Workflow

1. Run a short case and inspect log diagnostics.
2. Plot monitor histories from `3_monitor/`.
3. Check mesh and initial condition outputs from `4_check/`.
4. Open XDMF visualisation outputs from `2_visu/`.
5. Start statistics only after the flow is developed.
6. Use the closest example plotting script as a template for final profiles.

For mounted filesystems, figure saving can occasionally fail with an I/O error.
In that case, save figures to a local temporary directory first and copy them
back after the filesystem is stable.

For interactive tuning of the y-direction stretching before a run, see the
[Mesh Stretching Reviewer](mesh-reviewer.md).
