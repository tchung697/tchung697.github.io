# Config
PANDOC = pandoc
TEMPLATES_DIR = templates
POSTS_TMPL = $(TEMPLATES_DIR)/posts.html
INDEX_TMPL = $(TEMPLATES_DIR)/index.html
LUA_DIAGRAM = lua/diagram.lua
MEDIA_DIR = docs/media
NOTES_OUT_DIR = docs/notes

# Source files
NOTES_SRC = $(wildcard notes/*.md)
NOTES_HTML = $(patsubst notes/%.md,$(NOTES_OUT_DIR)/%.html,$(NOTES_SRC))

# Default target
all: directories docs/index.html docs/notes.html docs/css $(NOTES_HTML)

# Create directories
directories:
	@mkdir -p docs
	@mkdir -p $(NOTES_OUT_DIR)
	@mkdir -p $(MEDIA_DIR)

# Convert root markdown files to HTML (only if source or template changed)
docs/index.html: index.md $(INDEX_TMPL) | directories
	$(PANDOC) --template=$(INDEX_TMPL) --standalone -f markdown -t html -o $@ $<

docs/notes.html: notes.md $(INDEX_TMPL) | directories
	$(PANDOC) --template=$(INDEX_TMPL) --standalone -f markdown -t html -o $@ $<

# Copy CSS files (only if changed)
docs/css: css | directories
	@if [ ! -d "$@" ] || [ "$(shell find css -newer docs/css 2>/dev/null | head -1)" ]; then \
		echo "Copying CSS files..."; \
		cp -r css docs/; \
		touch docs/css; \
	fi

# Pattern rule for converting notes markdown files to HTML
$(NOTES_OUT_DIR)/%.html: notes/%.md $(POSTS_TMPL) $(LUA_DIAGRAM) | directories
	@echo "Converting $< to $@"
	@cd $(NOTES_OUT_DIR) && \
	$(PANDOC) \
		--template ../../$(POSTS_TMPL) \
		--standalone \
		--mathjax \
		--filter pandoc-crossref \
		--lua-filter=../../$(LUA_DIAGRAM) \
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

.PHONY: all docs html css notes clean rebuild help
