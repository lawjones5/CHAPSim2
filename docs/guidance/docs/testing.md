# Regression and Smoke Tests

The `tests/` directory contains ready-to-run cases and helper scripts for quick
health checks and numerical regression checks.

Use smoke tests for fast confidence after build or input-generation changes. Use
regression tests before merging solver, discretisation, I/O, or physics changes.

## Test Scripts

| Script | Purpose |
| --- | --- |
| `tests/run_smoke.sh` | Runs a short 10-iteration subset of representative cases. |
| `tests/run_regression.sh` | Runs or checks standard/extended regression suites against reference metrics. |
| `tests/update_reference.sh` | Replaces `reference.json` files with newly generated metrics. Use only after intentional validated changes. |
| `tests/tools/check_metrics.py` | Compares `regression_test_metrics.json` with `reference.json` using tolerances. |
| `tests/tools/tolerances.json` | Stores metric comparison tolerances. |

## Smoke Tests

From the `tests/` directory:

```bash
cd tests
bash run_smoke.sh
```

The smoke suite currently targets a short representative set:

- `tgv_iso`
- `channel_iso_inout`
- `channel_scp_inout_Tw`
- `annular_scp_inout_Tw`
- `pipe_scp_inout_Tw`

The script sets `RUN_MODE=smoke` and runs each case with
`CHAPSIM_NITER=10`. This is intended to catch build failures, missing files, bad
input generation, and early runtime errors. It is not a substitute for a
statistically converged validation run.

## Regression Tests

From the `tests/` directory:

```bash
cd tests
bash run_regression.sh
```

The script supports two modes:

| Mode | Meaning |
| --- | --- |
| `run` | Run each case, wait for `regression_test_metrics.json`, then compare metrics. |
| `check` | Skip solver execution and compare existing metrics only. |

It also supports two suites:

| Suite | Meaning |
| --- | --- |
| `standard` | Smaller default set used for routine checks. |
| `extended` | Larger set covering additional thermal, periodic, inlet/outlet, annular, and pipe cases. |

In continuous integration, defaults are used without interactive prompts.

## Reference Metrics

Each regression case should contain:

| File | Meaning |
| --- | --- |
| `input_chapsim.ini` | Case setup. |
| `run_chapsim.sh` | Case run wrapper. |
| `reference.json` | Accepted reference metrics. |
| `regression_test_metrics.json` | Metrics produced by the latest run. |

The comparison is performed by:

```bash
python3 tests/tools/check_metrics.py \
  tests/<case>/regression_test_metrics.json \
  tests/<case>/reference.json \
  tests/tools/tolerances.json
```

## Updating References

Only update references after confirming that the numerical change is intentional
and physically acceptable.

```bash
cd tests
bash update_reference.sh
```

This copies each available `regression_test_metrics.json` to `reference.json`.
Review the resulting diff before committing.

## Recommended Policy

- After editing input-generation tools: run smoke tests and at least the affected
  generated case.
- After editing I/O, restart, mesh, or boundary-condition logic: run smoke tests
  plus the standard regression suite.
- After editing numerical schemes or physics models: run the extended regression
  suite and inspect representative monitor histories.
- Before updating references: keep a note explaining why the new metrics are
  expected.
