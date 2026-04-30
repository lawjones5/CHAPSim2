# CHAPSim2 User Guide

CHAPSim2 is a high-fidelity DNS solver for canonical wall-bounded flows and
related thermo-fluid configurations. It supports isothermal flow, thermal and
variable-property flow, and MHD cases in Cartesian and cylindrical geometries.

The user-facing workflow is:

1. Build the solver.
2. Start from an existing case under `tests/` or generate an input file with the
   Python tools in `prepost/input_generator/`.
3. Edit `input_chapsim.ini` for the target geometry, physics, mesh, and output.
4. Run the solver with MPI.
5. Check logs, CFL/mass conservation diagnostics, restart files, visualisation,
   and statistics.

## Documentation Structure

- **Getting Started:** [Installation and First Run](installation.md).
- **Benchmark Cases:** [Benchmark and Example Cases](benchmark-cases.md).
- **User Guide and How-To's:** [User Guide and How-To's](user-guide.md),
  including input files, mesh review, restart/interpolation, postprocessing, and
  tests.
- **Reference:** [Reference](reference.md) and
  [CHAPSim Input File Guide](input-file.md).
- **Methodology:** [Methodology](methodology.md) and the generated FORD
  code-structure reference.
- **Troubleshooting:** [Troubleshooting](troubleshooting.md).

## Recommended Reading Path

New users should start with installation, then run or copy a benchmark case.
While editing `input_chapsim.ini`, keep the input-file guide open and use the
mesh reviewer to check y-direction stretching. After the first successful run,
inspect monitor histories and visualisation output before trusting statistics.
Use the mesh-restart workflow when moving a developed field to a refined or
resized mesh, and use smoke/regression tests when changing code or
input-generation logic.

## Source Tree Orientation

- `src/`: main Fortran solver source.
- `build/`: build output and compiled solver location.
- `tests/`: regression and smoke-test cases with ready-to-edit input files.
- `examples/`: example-case tooling and visualisation scripts.
- `prepost/`: input-generation and pre/post-processing utilities.
- `docs/`: user guidance and generated code-structure documentation.

The generated FORD code-structure reference is kept separately under
`docs/code_structure/`.
