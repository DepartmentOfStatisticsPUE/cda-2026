#!/usr/bin/env python3
"""Update readme.md with a download table for extracted code files.

Scans codes/R/, codes/python/, codes/julia/, codes/notebooks/
and generates a markdown table with links.

Usage:
    python update_readme.py
"""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CODES_DIR = REPO_ROOT / "codes"
README = REPO_ROOT / "readme.md"

GITHUB_BASE = "https://github.com/DepartmentOfStatisticsPUE/cda-2026/blob/main/codes"

# Map QMD stem to display title (extracted from filenames)
TOPIC_ORDER = [
    "01-categorical-data",
    "02-simpson-paradox",
    "03-ctables",
    "04-distributions",
    "05-mle",
    "05a-optimization-methods",
    "06-gof",
    "07-linreg",
    "08-glm-lr",
]

TOPIC_NAMES = {
    "01-categorical-data": "Categorical data",
    "02-simpson-paradox": "Simpson's paradox",
    "03-ctables": "Contingency tables",
    "04-distributions": "Discrete distributions",
    "05-mle": "Maximum likelihood estimation",
    "05a-optimization-methods": "Optimization methods",
    "06-gof": "Goodness of fit",
    "07-linreg": "Linear regression",
    "08-glm-lr": "GLM: Logistic regression",
}


def find_files():
    """Scan output directories and return available files per topic."""
    dirs = {
        "R": ("R", ".R"),
        "Python": ("python", ".py"),
        "Julia": ("julia", ".jl"),
        "Jupyter": ("notebooks", ".ipynb"),
    }

    results = {}
    for stem in TOPIC_ORDER:
        results[stem] = {}
        for lang, (subdir, ext) in dirs.items():
            fpath = CODES_DIR / subdir / f"{stem}{ext}"
            if fpath.exists():
                rel = f"codes/{subdir}/{stem}{ext}"
                results[stem][lang] = rel

    return results


def generate_table(files):
    """Generate markdown table."""
    lines = []
    lines.append("## Code files for download\n")
    lines.append("| # | Topic | R | Python | Julia | Jupyter |")
    lines.append("|---|-------|---|--------|-------|---------|")

    for i, stem in enumerate(TOPIC_ORDER, 1):
        name = TOPIC_NAMES.get(stem, stem)
        row = [str(i), name]
        for lang in ["R", "Python", "Julia", "Jupyter"]:
            if lang in files[stem]:
                ext_map = {"R": ".R", "Python": ".py", "Julia": ".jl", "Jupyter": ".ipynb"}
                row.append(f"[{ext_map[lang]}]({files[stem][lang]})")
            else:
                row.append("--")
        lines.append("| " + " | ".join(row) + " |")

    lines.append("")
    return "\n".join(lines)


def update_readme(table_text):
    """Insert or replace the download table in readme.md."""
    content = README.read_text(encoding="utf-8")

    # Pattern to find existing section
    pattern = r"## Code files for download\n.*?(?=\n## |\Z)"
    if re.search(pattern, content, re.DOTALL):
        content = re.sub(pattern, table_text, content, flags=re.DOTALL)
    else:
        # Insert after "Case study" section
        insert_after = "## Case study\n\n[TBA]\n"
        if insert_after in content:
            content = content.replace(insert_after, insert_after + "\n" + table_text + "\n")
        else:
            # Fallback: insert before "## Example final test"
            content = content.replace("## Example final test", table_text + "\n## Example final test")

    README.write_text(content, encoding="utf-8")
    print(f"Updated {README.relative_to(REPO_ROOT)}")


def generate_html_table(files):
    """Generate HTML table with full GitHub URLs for Moodle."""
    lines = []
    lines.append('<table border="1" cellpadding="6" cellspacing="0">')
    lines.append("<thead>")
    lines.append("<tr>")
    for h in ["#", "Topic", "R", "Python", "Julia", "Jupyter"]:
        lines.append(f"  <th>{h}</th>")
    lines.append("</tr>")
    lines.append("</thead>")
    lines.append("<tbody>")

    for i, stem in enumerate(TOPIC_ORDER, 1):
        name = TOPIC_NAMES.get(stem, stem)
        lines.append("<tr>")
        lines.append(f"  <td>{i}</td>")
        lines.append(f"  <td>{name}</td>")
        for lang in ["R", "Python", "Julia", "Jupyter"]:
            if lang in files[stem]:
                ext_map = {"R": ".R", "Python": ".py", "Julia": ".jl", "Jupyter": ".ipynb"}
                url = f"{GITHUB_BASE}/{files[stem][lang].removeprefix('codes/')}"
                lines.append(f'  <td><a href="{url}">{ext_map[lang]}</a></td>')
            else:
                lines.append("  <td>--</td>")
        lines.append("</tr>")

    lines.append("</tbody>")
    lines.append("</table>")
    return "\n".join(lines)


def write_moodle_html(html_text):
    """Write HTML table to moodle-table.html for easy copy-paste."""
    out = REPO_ROOT / "moodle-table.html"
    out.write_text(html_text, encoding="utf-8")
    print(f"Generated {out.relative_to(REPO_ROOT)} (copy-paste into Moodle)")


def main():
    files = find_files()
    table = generate_table(files)
    update_readme(table)
    html = generate_html_table(files)
    write_moodle_html(html)


if __name__ == "__main__":
    main()
