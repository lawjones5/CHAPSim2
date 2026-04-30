# Restarting on a Different Mesh

This workflow is used when a case should continue from an existing solution but
the target case uses a different mesh or box size with the same topology. Typical
uses are mesh refinement, mesh coarsening, or changing the domain length while
keeping the same flow configuration.

The helper scripts are:

| Script | Run location | Purpose |
| --- | --- | --- |
| `prepost/input_generator/setup_chapsim_interp_step1.sh` | Source case directory | Prepare the source case for interpolation output and create `input_chapsim_tgt.ini`. |
| `prepost/input_generator/setup_chapsim_interp_step2.sh` | Target case directory | Copy interpolation files, rename them for the target run, and update the target `input_chapsim.ini`. |

## When to Use This Workflow

Use this route when:

- The source and target have the same geometry family and topology, for example
  channel-to-channel or pipe-to-pipe.
- The target mesh differs in `ncx`, `ncy`, `ncz`, `istret`, `rstret`, or domain
  lengths such as `lxx`, `lyt`, `lyb`, and `lzz`.
- The target case should be initialized from a physically developed source
  solution rather than from a synthetic initial field.

Do not use it to convert between unrelated topologies, for example channel to
pipe, or between incompatible physics choices without checking the generated
fields carefully.

## Step 1: Prepare the Source Case

From the source case directory, run:

```bash
bash /home/weiwang/Work_RSDevelopment/1_CHAPSim/CHAPSim2/prepost/input_generator/setup_chapsim_interp_step1.sh
```

The script requires `input_chapsim.ini` in the current directory. It creates a
backup named `input_chapsim.ini.bak`, then updates the source input file:

| Section | Variable | New value | Meaning |
| --- | --- | --- | --- |
| `[process]` | `is_prerun` | `.true.` | Enable the interpolation/prerun preparation stage. |
| `[flow]` | `initfl` | `0` | Restart flow from existing data. |
| `[flow]` | `irestartfrom` | user selected | Restart index to read from the source case. |

The script also creates `input_chapsim_tgt.ini`. This file stores only the
target `[domain]` and `[mesh]` settings:

```ini
[domain]
icase= ...
lxx= ...
lyt= ...
lyb= ...
lzz= ...

[mesh]
ncx= ...
ncy= ...
ncz= ...
istret= ...
rstret= ...
```

After running the script, run the source case in serial mode, using one MPI
rank. The source run should finish successfully and write `domain0_*` files in
`1_data/`.

## Step 2: Prepare the Target Case

Create or enter the target case directory, then run:

```bash
bash /home/weiwang/Work_RSDevelopment/1_CHAPSim/CHAPSim2/prepost/input_generator/setup_chapsim_interp_step2.sh
```

When prompted, give the path to the completed source case from Step 1. The script
checks that the source directory contains:

- `1_data/`
- `input_chapsim.ini`
- `input_chapsim_tgt.ini`
- one or more `1_data/domain0_*` files

It then prepares the target case by:

- creating `1_data/` if needed;
- copying each source `domain0_*` file into the target `1_data/`;
- renaming those files to `domain1_*`;
- copying `input_chapsim.ini` and `input_chapsim_tgt.ini`;
- setting `[process] is_prerun = .false.`;
- setting `[flow] irestartfrom = 0`;
- replacing the target `[domain]` and `[mesh]` values using
  `input_chapsim_tgt.ini`.

After Step 2, run the target case normally. The runtime mesh should match the
values in `input_chapsim_tgt.ini`.

## Practical Checks

Before running the target case:

- Compare `input_chapsim.ini.bak`, `input_chapsim.ini`, and
  `input_chapsim_tgt.ini` if the source setup looks unexpected.
- Confirm that `1_data/domain1_*` exists in the target case.
- Confirm that `icase` is unchanged unless you have intentionally prepared a
  compatible case conversion.
- Check that the target `ncx`, `ncy`, `ncz`, stretching method, and domain
  lengths are the values you intended.
- Start with a short run and check CFL, mass conservation, and early monitor
  history before launching a long production run.

## Common Problems

| Symptom | Likely cause | Action |
| --- | --- | --- |
| `input_chapsim.ini not found` | Script was run from the wrong directory. | Run Step 1 inside the source case directory. |
| `No domain0_* files found` | Source prerun did not complete or wrote output elsewhere. | Re-run the source case in serial and inspect `1_data/`. |
| Target starts from the wrong mesh | `input_chapsim_tgt.ini` does not match the intended target case. | Edit or regenerate `input_chapsim_tgt.ini`, then rerun Step 2. |
| Target run becomes unstable immediately | Interpolated field and target setup are inconsistent. | Check topology, physics options, wall units, CFL, and boundary conditions. |
