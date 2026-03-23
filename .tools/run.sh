#!/bin/bash
set -e

TOOLS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$TOOLS_DIR")"
QMD_DIR="$REPO_DIR/codes/qmd"
CODES_DIR="$REPO_DIR/codes"

render() {
    echo "==> Rendering .qmd files..."
    cd "$QMD_DIR"
    for f in *.qmd; do
        echo "  $f"
        quarto render "$f" --no-execute 2>&1 | tail -1
    done
}

sort_files() {
    echo "==> Sorting extracted files..."
    mkdir -p "$CODES_DIR/R" "$CODES_DIR/python" "$CODES_DIR/julia" "$CODES_DIR/notebooks"
    for f in "$QMD_DIR"/*.R;  do [ -f "$f" ] && mv "$f" "$CODES_DIR/R/";  done
    for f in "$QMD_DIR"/*.py; do [ -f "$f" ] && mv "$f" "$CODES_DIR/python/"; done
    for f in "$QMD_DIR"/*.jl; do [ -f "$f" ] && mv "$f" "$CODES_DIR/julia/"; done
    rm -f "$QMD_DIR"/*.sh
}

notebooks() {
    echo "==> Creating Jupyter notebooks..."
    cd "$TOOLS_DIR" && python3 py_to_notebook.py
}

update_readme() {
    echo "==> Updating README..."
    cd "$TOOLS_DIR" && python3 update_readme.py
}

extract() {
    render
    sort_files
    notebooks
    update_readme
    echo "==> Done!"
}

publish() {
    extract
    echo "==> Pushing to GitHub..."
    cd "$REPO_DIR"
    git add -A
    git commit -m "Update extracted code files and notebooks"
    git push
    echo "==> Published!"
}

clean() {
    echo "==> Cleaning generated files (HTML preserved)..."
    rm -rf "$CODES_DIR/R" "$CODES_DIR/python" "$CODES_DIR/julia" "$CODES_DIR/notebooks"
    echo "==> Clean!"
}

case "${1:-extract}" in
    extract) extract ;;
    publish) publish ;;
    clean)   clean ;;
    *)       echo "Usage: $0 [extract|publish|clean]"; exit 1 ;;
esac
