# Methodology

This page gives a compact orientation to the numerical and modelling choices
that users need to understand when preparing a case. Detailed implementation
information is available in the generated code-structure documentation.

## Solver Scope

CHAPSim2 targets canonical DNS-style configurations, including:

- Cartesian channel and Taylor-Green vortex cases;
- cylindrical pipe and annular cases;
- isothermal flow;
- scalar/thermal cases with wall-temperature or wall-heat-flux boundary
  conditions;
- selected MHD configurations.

## Geometry and Topology

The primary geometry selector is `[domain] icase`:

| `icase` | Geometry |
| ---: | --- |
| `1` | Channel |
| `2` | Pipe |
| `3` | Annular |
| `4` | Taylor-Green vortex |

Pipe and annular cases use cylindrical-coordinate constraints internally.
Several domain values are reset by the input-reading logic for these cases, so
always check the run log for final interpreted values.

## Mesh and Stretching

Wall-normal or radial resolution is controlled by the `[mesh]` section. The main
choices are:

- no stretching;
- centre, two-side, bottom-side, or top-side clustering;
- five-mode spectral, tanh, or power-law stretching method.

Use the [Mesh Stretching Reviewer](mesh-reviewer.md) to inspect a candidate mesh
before launching production runs.

## Boundary Conditions and Driving

Periodic wall-bounded cases normally use a driving-force or flow-rate control
mode. Inlet/outlet cases should usually use database or prescribed inlet
conditions and avoid periodic driving.

The input guide documents the boundary-condition IDs and common combinations:

[CHAPSim Input File Guide](input-file.md)

## Output and Statistics

CHAPSim2 separates restart/checkpoint data, visualisation output, monitor
histories, setup checks, and statistics. Statistics should normally begin only
after the transient has passed. Higher statistics levels are more expensive and
should be enabled only when those quantities are needed.

See [Postprocessing and Output Data](postprocessing.md) for the output workflow.

## Implementation Reference

For module-level details, browse:

```text
docs/code_structure/index.html
```

Important implementation areas include geometry setup, boundary conditions,
momentum and energy equations, restart I/O, monitor I/O, visualisation I/O, and
statistics.
