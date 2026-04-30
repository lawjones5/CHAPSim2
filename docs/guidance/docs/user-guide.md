# User Guide and How-To's

This section collects practical workflows used after the solver is built. The
pages are ordered roughly as they appear in a normal case-development cycle.

## Case Preparation

- [CHAPSim Input File Guide](input-file.md): meaning, type, and valid values for
  `input_chapsim.ini` variables.
- [Mesh Stretching Reviewer](mesh-reviewer.md): interactive y-mesh stretching
  viewer for choosing `rstret`, stretching method, and clustering location.

## Running and Restarting

- [Restarting on a Different Mesh](mesh-restart.md): two-step interpolation
  workflow for restarting from a source case onto a target mesh with the same
  topology.
- [Regression and Smoke Tests](testing.md): short health checks, standard and
  extended regression suites, and reference-metric updates.

## Output and Analysis

- [Postprocessing and Output Data](postprocessing.md): output folders,
  visualisation, monitor histories, statistics levels, and example plotting
  scripts.
- [Troubleshooting](troubleshooting.md): common practical issues with browser
  previews, missing tools, mounted filesystems, restart setup, and regression
  metrics.

## Suggested Workflow

1. Start from [Benchmark and Example Cases](benchmark-cases.md).
2. Edit the input file with the [CHAPSim Input File Guide](input-file.md).
3. Review the y-mesh before long runs.
4. Run a short smoke-style case and inspect monitors.
5. Enable statistics only after the initial transient.
6. Use regression checks when changing source code or input-generation logic.
