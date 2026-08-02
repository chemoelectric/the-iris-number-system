.DELETE_ON_ERROR:

ASCIIDOCTOR = asciidoctor
PANDOC = pandoc
PDF_ENGINE = xelatex

%.html: %.adoc
	$(ASCIIDOCTOR) -S safe -b html5 $(<) -o $(@)
clean-html::
	-rm -f *.html
clean:: clean-html

%.pdf: %.html
	$(PANDOC) -f html+tex_math_single_backslash \
	          --metadata title="" \
	          --pdf-engine=$(PDF_ENGINE) \
	          $(<) -o $(@)
clean-pdf::
	-rm -f *.pdf
clean:: clean-pdf
