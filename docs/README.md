# CHAPSim2 Documentation

The documentation is split into two parts:

- [User guidance](guidance/index.html): human-written installation, benchmark
  cases, how-to workflows, input reference, methodology, and troubleshooting.
- [Code structure reference](code_structure/index.html): FORD-generated
  Fortran API and source-structure documentation.

For a browser landing page, open:

```bash
google-chrome docs/index.html
```

To regenerate the user guidance as a MkDocs site, use `docs/guidance/`.
To regenerate the Fortran code-structure reference, use
`docs/code_structure/ford.yaml`.

The user guidance follows this structure:

- Getting Started
- Benchmark Cases
- User Guide and How-To's
- Reference
- Methodology
- Troubleshooting

If MkDocs is unavailable, regenerate the static browser previews with:

```bash
python3 docs/guidance/build_static.py
```
