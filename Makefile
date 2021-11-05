PDF_ENGINE ?= xelatex
VERSION ?= $(shell git log -n 1 --pretty=format:"%H" | head -c 8)

build: proposal-$(VERSION).pdf

proposal-$(VERSION).pdf proposal.pdf: *.md
	pandoc \
		--metadata=subtitle:"Revision: $(VERSION)" \
		--pdf-engine=$(PDF_ENGINE) \
		-o proposal-$(VERSION).pdf *.md

clean:
	-rm proposal.pdf

.phony: build clean
