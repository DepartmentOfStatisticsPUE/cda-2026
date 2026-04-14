TOOLS_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
REPO_DIR := $(TOOLS_DIR)/..
CODES_DIR := $(REPO_DIR)/codes
QMD_DIR := $(CODES_DIR)/qmd
QMD_FILES := $(wildcard $(QMD_DIR)/*.qmd)
QMD_STEMS := $(basename $(notdir $(QMD_FILES)))
HTML_FILES := $(QMD_FILES:.qmd=.html)

.PHONY: all extract render render-all sort notebooks readme clean publish

all: extract

extract: render sort notebooks readme

# Per-file rule: re-render only when .qmd is newer than .html
$(QMD_DIR)/%.html: $(QMD_DIR)/%.qmd
	@echo "  Rendering $(notdir $<) ..."
	@cd $(QMD_DIR) && quarto render "$(notdir $<)" 2>&1 | tail -1

render: $(HTML_FILES)
	@echo "==> Render up to date."

# Force re-render of every .qmd (use when filters/templates change)
render-all:
	@echo "==> Force-rendering all .qmd files..."
	@cd $(QMD_DIR) && for f in *.qmd; do \
		echo "  Rendering $$f ..."; \
		quarto render "$$f" 2>&1 | tail -1; \
	done

sort:
	@echo "==> Sorting extracted files..."
	@mkdir -p $(CODES_DIR)/R $(CODES_DIR)/python $(CODES_DIR)/julia $(CODES_DIR)/notebooks
	@for stem in $(QMD_STEMS); do \
		[ -f "$(QMD_DIR)/$$stem.R" ] && mv "$(QMD_DIR)/$$stem.R" "$(CODES_DIR)/R/" 2>/dev/null; \
		[ -f "$(QMD_DIR)/$$stem.py" ] && mv "$(QMD_DIR)/$$stem.py" "$(CODES_DIR)/python/" 2>/dev/null; \
		[ -f "$(QMD_DIR)/$$stem.jl" ] && mv "$(QMD_DIR)/$$stem.jl" "$(CODES_DIR)/julia/" 2>/dev/null; \
		rm -f "$(QMD_DIR)/$$stem.sh" 2>/dev/null; \
		true; \
	done
	@echo "  Done."

notebooks:
	@echo "==> Creating Jupyter notebooks..."
	@cd $(TOOLS_DIR) && python3 py_to_notebook.py

readme:
	@echo "==> Updating README..."
	@cd $(TOOLS_DIR) && python3 update_readme.py

publish: extract
	@echo "==> Committing and pushing to GitHub..."
	@cd $(REPO_DIR) && git add -A && git commit -m "Update extracted code files and notebooks" && git push

clean:
	@echo "==> Cleaning extracted code files (HTML in qmd/ preserved)..."
	@rm -rf $(CODES_DIR)/R $(CODES_DIR)/python $(CODES_DIR)/julia $(CODES_DIR)/notebooks
