.PHONY: all
all: html pdf toc

# generate HTML from Markdown using marp
.PHONY: html
html:
	 marp presentation.md 

# generate PDF from Markdown using marp
.PHONY: pdf
pdf:
	marp presentation.md --pdf --pdf-outlines

# generate PDF from Markdown using pandoc
.PHONY: toc
toc:
	pandoc -o presentation_toc.pdf  --toc -t pdf --number-sections --shift-heading-level-by=0 presentation.md
