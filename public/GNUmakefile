.DELETE_ON_ERROR:
.DEFAULT_GOAL := default

SED = sed
ASCIIDOCTOR = asciidoctor
PANDOC = pandoc
PDF_ENGINE = xelatex

VOLUMES =
VOLUMES += Iris_Number_System-01-Volume_I_Fundamentals
VOLUMES += Iris_Number_System-02-Volume_II_Number_Theory_etc
VOLUMES += Iris_Number_System-03-Volume_III_Geometry_Algebra_etc
VOLUMES += Iris_Number_System-04-Volume_IV_Physics_etc


default: all
all: $(addsuffix .pdf, $(VOLUMES))


.PHONY: clean

%.html: %.adoc
	$(ASCIIDOCTOR) -S safe -b html5 $(<) -o $(@)
.PHONY: clean-html
clean-html::
	-rm -f *.html
clean:: clean-html

%.pdf: %.html header.tex
	$(PANDOC) -f html+tex_math_single_backslash \
	          --metadata title="" \
	          --pdf-engine=$(PDF_ENGINE) \
	          -H header.tex \
	          -V fontsize=12pt \
	          $(<) -o $(@)
.PHONY: clean-pdf
clean-pdf::
	-rm -f *.pdf
clean:: clean-pdf
