
build: proposal.pdf

proposal.pdf: *.md
	pandoc --pdf-engine=xelatex -o proposal.pdf *.md

clean:
	-rm proposal.pdf

.phony: build clean
