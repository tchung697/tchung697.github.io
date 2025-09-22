# Makefile for simple static site generation with pandoc

# Default target
all: docs html css notes

# Create docs directory
docs:
	mkdir -p docs
	mkdir -p docs/notes

# Convert root markdown files to HTML
html: docs
	pandoc -s --template=templates/index.html --standalone -f markdown -t html -o docs/index.html index.md
	pandoc -s --template=templates/index.html --standalone -f markdown -t html -o docs/notes.html notes.md

# Copy CSS files
css: docs
	cp -r css docs/

# Convert notes markdown files to HTML
notes: docs
	for file in notes/*.md; do \
		basename=$$(basename "$$file" .md); \
		pandoc --template=templates/posts.html \
		--standalone \
		--mathjax \
		--filter pandoc-crossref \
		-M linkReferences=true \
		-M nameInLink=true \
		--toc \
		--toc-depth=2 \
		-f markdown -t html -o "docs/notes/$$basename.html" "$$file"; \
	done

# Clean generated files but keep google site verification file
clean:
	find docs -type f ! -name 'google*.html' -delete
	find docs -type d -empty -delete

# Rebuild everything
rebuild: clean all

# Help
help:
	@echo "Available targets:"
	@echo "  all      - Build all HTML files and copy resources (default)"
	@echo "  clean    - Remove generated docs directory"
	@echo "  rebuild  - Clean and rebuild all"
	@echo "  help     - Show this help"

.PHONY: all docs html css notes clean rebuild help
