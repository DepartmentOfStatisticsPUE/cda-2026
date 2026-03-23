#!/usr/bin/env python3
"""Convert extracted .py files to Jupyter notebooks.

Ripper extracts code blocks without section structure.
This script re-reads the original .qmd to get section headers
and creates notebooks with markdown cells for headers and code cells for Python chunks.

Usage:
    python py_to_notebook.py                     # all .qmd files
    python py_to_notebook.py 05-mle.qmd          # one file
"""

import sys
import re
import os
import nbformat
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CODES_DIR = REPO_ROOT / "codes"
QMD_DIR = CODES_DIR / "qmd"
NOTEBOOKS_DIR = CODES_DIR / "notebooks"


def parse_qmd_python(qmd_path):
    """Parse a .qmd file and extract Python code chunks with section context."""
    lines = qmd_path.read_text(encoding="utf-8").splitlines()

    cells = []
    in_code_fence = False
    fence_lang = None
    code_lines = []
    skip_chunk = False
    current_sections = {}  # level -> text
    last_emitted_header = None
    in_yaml = False
    yaml_done = False
    title = ""

    for line in lines:
        # YAML header
        if not yaml_done and line.strip() == "---":
            if not in_yaml:
                in_yaml = True
                continue
            else:
                in_yaml = False
                yaml_done = True
                continue
        if in_yaml:
            m = re.match(r'^title:\s*["\']?(.+?)["\']?\s*$', line)
            if m:
                title = m.group(1)
            continue

        # Code fence open
        m = re.match(r'^```\{(\w+)(?:[\s,]+(.*))?\}\s*$', line)
        if m and not in_code_fence:
            in_code_fence = True
            fence_lang = m.group(1).lower()
            opts_str = m.group(2) or ""

            # Skip setup chunks
            if "setup" in opts_str.lower():
                skip_chunk = True
                code_lines = []
                continue

            # Check eval option
            is_eval_false = bool(re.search(r'eval\s*[=:]\s*(FALSE|F|false)', opts_str))

            code_lines = []
            if fence_lang == "python":
                skip_chunk = False
            else:
                skip_chunk = True
            continue

        # Code fence close
        if in_code_fence and re.match(r'^```\s*$', line):
            if not skip_chunk and fence_lang == "python" and code_lines:
                # Check if it's an install-only chunk
                code_text = "\n".join(code_lines)
                is_install = all(
                    l.strip() == "" or l.strip().startswith("#") or
                    "pip install" in l or "conda install" in l
                    for l in code_lines
                )

                if not is_install:
                    # Emit section header if changed
                    header_key = tuple(sorted(current_sections.items()))
                    if header_key != last_emitted_header and current_sections:
                        max_level = max(current_sections.keys())
                        header_text = current_sections[max_level]
                        cells.append(("markdown", f"## {header_text}"))
                        last_emitted_header = header_key

                    # Check for eval=FALSE
                    if is_eval_false:
                        code_text = f"# NOTE: not evaluated in original notebook\n{code_text}"

                    cells.append(("code", code_text))

            in_code_fence = False
            fence_lang = None
            code_lines = []
            skip_chunk = False
            continue

        # Inside code fence
        if in_code_fence:
            code_lines.append(line)
            continue

        # Markdown heading (outside code fence)
        m = re.match(r'^(#{1,6})\s+(.+)$', line)
        if m:
            level = len(m.group(1))
            text = m.group(2).strip()
            # Skip tab labels (R, Python, Julia)
            if text in ("R", "Python", "Julia"):
                continue
            # Skip panel-tabset labels
            if text in ("Code and result",):
                continue
            current_sections[level] = text
            # Clear deeper levels
            for k in list(current_sections.keys()):
                if k > level:
                    del current_sections[k]

    return title, cells


def create_notebook(title, cells):
    """Create a Jupyter notebook from parsed cells."""
    nb = nbformat.v4.new_notebook()
    nb.metadata.kernelspec = {
        "display_name": "Python 3",
        "language": "python",
        "name": "python3"
    }

    # Title cell
    if title:
        nb.cells.append(nbformat.v4.new_markdown_cell(f"# {title}"))

    for cell_type, content in cells:
        if cell_type == "markdown":
            nb.cells.append(nbformat.v4.new_markdown_cell(content))
        elif cell_type == "code":
            nb.cells.append(nbformat.v4.new_code_cell(content))

    return nb


def process_qmd(qmd_path):
    """Process a single .qmd file into a Jupyter notebook."""
    title, cells = parse_qmd_python(qmd_path)

    if not any(ct == "code" for ct, _ in cells):
        print(f"  Skipping {qmd_path.name} (no Python code)")
        return None

    nb = create_notebook(title, cells)

    out_path = NOTEBOOKS_DIR / qmd_path.with_suffix(".ipynb").name
    NOTEBOOKS_DIR.mkdir(parents=True, exist_ok=True)

    with open(out_path, "w", encoding="utf-8") as f:
        nbformat.write(nb, f)

    print(f"  Created {out_path.relative_to(REPO_ROOT)}")
    return out_path


def main():
    if len(sys.argv) > 1:
        qmd_files = [QMD_DIR / f for f in sys.argv[1:]]
    else:
        qmd_files = sorted(QMD_DIR.glob("*.qmd"))

    print("Creating Jupyter notebooks from .qmd files:")
    for qmd in qmd_files:
        if qmd.exists():
            process_qmd(qmd)
        else:
            print(f"  WARNING: {qmd} not found")


if __name__ == "__main__":
    main()
