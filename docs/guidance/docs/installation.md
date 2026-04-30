# Installation and First Run

This page gives the minimal path from source tree to a short CHAPSim2 run.
Platform-specific compiler and MPI module names vary between local machines and
HPC systems, so use the commands here as a checklist rather than a universal
script.

## Prerequisites

CHAPSim2 is a Fortran DNS solver with MPI parallelism and FFT-based components.
A working build environment normally needs:

- A Fortran compiler, for example `gfortran` version 10 or newer.
- An MPI implementation with Fortran support.
- Standard build tools such as `make`.
- The bundled or locally available 2DECOMP&FFT dependency.

On a Debian/Ubuntu workstation, the base compiler tools can be installed with:

```bash
sudo apt-get update
sudo apt-get install gfortran make
```

On an HPC system, prefer the site-provided compiler and MPI modules.


## Download

```bash
git clone https://github.com/CCP-NTH/CHAPSim2.git
cd CHAPSim2
```

## Build

From the repository root:

```bash
./build_make.sh
```

The training workflow uses the compiled solver from the build tree when running
cases under `tests/`.

## Run a Short Test Case

Choose a small case under `tests/`, inspect `input_chapsim.ini`, then run with a
small MPI size:

```bash
cd tests/<case_name>
mpirun -np 4 $PATH/CHAPSim2/bin/chapsim
```

For quick smoke tests, the solver can shorten the final iteration through the
environment variable `CHAPSIM_NITER`:

```bash
CHAPSIM_NITER=20 mpirun -np 4 $PATH/CHAPSim2/bin/chapsim
```

## What to Check

During a first run, monitor:

- Whether the input sections are read in order without errors.
- CFL and time-step diagnostics.
- Mass conservation messages.
- Boundary-condition warnings.
- Restart, visualisation, and statistics files appearing at the requested
  frequencies.

For input-file details, see [CHAPSim Input File Guide](input-file.md).
