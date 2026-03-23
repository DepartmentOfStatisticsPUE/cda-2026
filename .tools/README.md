# .tools — Build scripts for code extraction

## Pipeline

```
1. Edit .qmd files in codes/qmd/
2. cd .tools && make extract    (or make publish to also push to GitHub)
3. Done — students download files from GitHub
```

## What `make extract` does

| Step | Command | What it does |
|------|---------|-------------|
| 1 | `make render` | Runs `quarto render` on each .qmd → generates HTML (for presentation) + Ripper extracts .R/.py/.jl |
| 2 | `make sort` | Moves .R/.py/.jl from `codes/qmd/` to `codes/R/`, `codes/python/`, `codes/julia/`. Deletes .sh files |
| 3 | `make notebooks` | Creates clean Jupyter notebooks (Python only) in `codes/notebooks/` |
| 4 | `make readme` | Updates the download table in `readme.md` |

## Available targets

```bash
make extract     # Full pipeline: render → sort → notebooks → readme
make publish     # extract + git commit + git push
make clean       # Remove generated code files (HTML preserved)
make render      # Only render .qmd files
make sort        # Only sort extracted files
make notebooks   # Only create Jupyter notebooks
make readme      # Only update README
```

## Output structure

```
codes/
  qmd/             ← .qmd source files + rendered .html + _extensions/
  R/               ← standalone R scripts (auto-generated)
  python/          ← standalone Python scripts (auto-generated)
  julia/           ← standalone Julia scripts (auto-generated)
  notebooks/       ← Jupyter notebooks, Python only (auto-generated)
```

## How it works

- **Ripper** is a Quarto Lua filter (`codes/qmd/_extensions/`) that extracts code blocks by language during `quarto render`
- **py_to_notebook.py** re-parses the .qmd to get section headers and creates Jupyter notebooks with markdown cells (headers) + code cells (Python only)
- **update_readme.py** scans output directories and generates a download table in `readme.md`

## Requirements

- Quarto >= 1.7.0 (for Ripper extension)
- Python 3 with `nbformat` (included in Anaconda)
