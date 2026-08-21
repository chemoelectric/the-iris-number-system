.DELETE_ON_ERROR:
.DEFAULT_GOAL := default

AWK = nawk
SED = sed
ASCIIDOCTOR = asciidoctor
PANDOC = pandoc
PDF_ENGINE = xelatex

VOLUMES =
VOLUMES += Iris_Number_System-01-Volume_I_Fundamentals
VOLUMES += Iris_Number_System-02-Volume_II_Number_Theory_etc
VOLUMES += Iris_Number_System-03-Volume_III_Geometry_Algebra_etc
VOLUMES += Iris_Number_System-04-Volume_IV_Physics_etc
VOLUMES += Iris_Number_System-05-Volume_V_Spectral_Analysis_etc
VOLUMES += Iris_Number_System-06-Volume_VI_Fractals


default: all
all: $(addsuffix .pdf, $(VOLUMES))


.PHONY: clean

define preprocess-adoc
$(AWK) < $(1) > $(2) ' \
/^\*Proof:\*$$/ { print; print ""; next } \
/^\* **[^[:space:]]/ { print ""; print; next } \
{ print } \
'
endef

%.html: %.adoc
	$(call preprocess-adoc,$(<),$(*).preproc.adoc)
	$(ASCIIDOCTOR) -S safe -b html5 $(*).preproc.adoc -o $(@)
	rm $(*).preproc.adoc
.PHONY: clean-html
clean-html::
	-rm -f *.html *.preproc.adoc
clean:: clean-html

%.pdf: %.html header.tex fix-greek.lua GNUmakefile
	$(PANDOC) -f html+tex_math_single_backslash \
	          -t pdf \
	          --pdf-engine=$(PDF_ENGINE) \
	          --lua-filter=fix-greek.lua \
	          --lua-filter=chapter-newpage.lua \
	          -V documentclass=book \
	          -V classoption=oneside \
	          -H header.tex \
	          -V fontsize=12pt \
	          -V classoption=fleqn \
	          -M title="" \
	          $(<) -o $(@)
.PHONY: clean-pdf
clean-pdf::
	-rm -f *.pdf
clean:: clean-pdf
