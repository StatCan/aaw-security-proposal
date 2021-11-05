PDF_ENGINE ?= xelatex

build: proposal.pdf

proposal.pdf: *.md
	pandoc --pdf-engine=$(PDF_ENGINE) -o proposal.pdf *.md

clean:
	-rm proposal.pdf

.phony: build clean
