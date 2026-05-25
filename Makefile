# Config
PANDOC = pandoc
TEMPLATES_DIR = templates
POSTS_TMPL = $(TEMPLATES_DIR)/posts.html
INDEX_TMPL = $(TEMPLATES_DIR)/index.html
LUA_DIAGRAM = lua/diagram.lua
MEDIA_DIR = docs/media
NOTES_OUT_DIR = docs/notes
PRIVATE_NOTES = notes/me-iv.md

# Source files
NOTES_SRC = $(filter-out $(PRIVATE_NOTES),$(wildcard notes/*.md))
NOTES_HTML = $(patsubst notes/%.md,$(NOTES_OUT_DIR)/%.html,$(NOTES_SRC))
CSS_SRC = $(wildcard css/*)
CSS_OUT = $(patsubst css/%,docs/css/%,$(CSS_SRC))

# Default target
all: directories docs/index.html docs/notes.html docs/research.html docs/robots.txt $(CSS_OUT) $(NOTES_HTML)

# Create directories
directories:
	@mkdir -p docs
	@mkdir -p $(NOTES_OUT_DIR)
	@mkdir -p $(MEDIA_DIR)
	@mkdir -p docs/css

# Convert root markdown files to HTML (only if source or template changed)
docs/index.html: index.md $(INDEX_TMPL) | directories
	$(PANDOC) --template=$(INDEX_TMPL) --standalone -f markdown -t html -o $@ $<

docs/notes.html: notes.md $(INDEX_TMPL) | directories
	$(PANDOC) --template=$(INDEX_TMPL) --standalone -f markdown -t html -o $@ $<

docs/research.html: research.md $(INDEX_TMPL) | directories
	$(PANDOC) --template=$(INDEX_TMPL) --standalone -f markdown -t html -o $@ $<

docs/robots.txt: robots.txt | directories
	cp $< $@

# Copy CSS files only when their sources changed.
docs/css/%: css/% | directories
	cp $< $@

# Pattern rule for converting notes markdown files to HTML
$(NOTES_OUT_DIR)/%.html: notes/%.md $(POSTS_TMPL) $(LUA_DIAGRAM) | directories
	@echo "Converting $< to $@"
	@cd $(NOTES_OUT_DIR) && \
	$(PANDOC) \
		--template ../../$(POSTS_TMPL) \
		--standalone \
		--mathjax \
		--lua-filter=../../$(LUA_DIAGRAM) \
		--filter pandoc-crossref \
		--extract-media=../media \
		-M linkReferences=true \
		-M nameInLink=true \
		-M crossrefYaml=../../pandoc-crossref.yaml \
		--toc \
		--toc-depth=2 \
		-f markdown -t html \
		-o $(notdir $@) \
		../../$<

# Clean generated files but keep google site verification file
clean:
	find docs -type f ! -name 'google*.html' -delete
	find docs -type d -empty -delete
	mkdir -p $(MEDIA_DIR) $(NOTES_OUT_DIR)

# Force rebuild everything
rebuild: clean all

# Help
help:
	@echo "Available targets:"
	@echo "  all      - Build only changed HTML files and resources (default)"
	@echo "  clean    - Remove generated docs files (keeps docs/media and google*.html)"
	@echo "  rebuild  - Clean and rebuild all"
	@echo "  help     - Show this help"

.PHONY: all directories clean rebuild help
