# Troubleshooting

This page collects common setup, documentation, run, and postprocessing issues.
Use it as a first stop before changing solver settings.

## Documentation Opens as Raw Markdown

If Chrome shows Markdown source text instead of a formatted page, open the
generated HTML version:

```bash
google-chrome /home/weiwang/Work_RSDevelopment/1_CHAPSim/CHAPSim2/docs/index.html
```

Then choose **User Guidance**. The browser-facing pages are under:

```text
docs/guidance/html/
```

The Markdown source files are still kept under:

```text
docs/guidance/docs/
```

After editing a Markdown source file, regenerate the local HTML preview with:

```bash
python3 docs/guidance/build_static.py
```

This route does not require MkDocs.

## MkDocs Is Not Installed

MkDocs is optional. The dependency-free static builder above is enough for local
preview in a browser. Use MkDocs only when you want the full Material theme site.

## Figure Saving Fails on a Mounted Filesystem

On remote or mounted filesystems, Matplotlib may fail with an error such as:

```text
OSError: [Errno 5] Input/output error
```

A robust workflow is:

- save plots first to a local temporary directory, for example `/tmp`;
- verify the PNG was completed;
- copy the completed file back to the mounted case directory when the filesystem
  is stable.

For long postprocessing batches, this avoids losing all later figures after one
filesystem write failure.

## Restart or Interpolation Case Fails Early

Check these items before changing numerical parameters:

- Source and target cases use the same geometry family and topology.
- `input_chapsim_tgt.ini` contains the intended target mesh and domain values.
- Target `1_data/` contains `domain1_*` files.
- The target `input_chapsim.ini` has `[process] is_prerun = .false.`.
- The initial CFL is conservative for the first target restart.
- Boundary-condition and physics settings are consistent with the source field.

## Visualisation Files Are Missing

Check the input-file output settings:

- `visu_idim` selects full-domain or plane output mode.
- `visu_nfre` controls visualisation write frequency.
- `visu_nskip` controls skipped records or stride behavior.
- The run length is long enough to reach a visualisation write step.

Also inspect the run log for disabled postprocessing or I/O errors.

## Regression Metrics Are Missing

For regression cases, `regression_test_metrics.json` should be produced by the
case run. If it is absent:

- confirm the case was run with the regression wrapper;
- inspect the solver log for early termination;
- check that `run_chapsim.sh` exists and is executable;
- verify the run finished before the metric timeout in `tests/run_regression.sh`.

Use metrics-only mode only when `regression_test_metrics.json` already exists.
