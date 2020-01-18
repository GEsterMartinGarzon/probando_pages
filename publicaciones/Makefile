default:	index.html

all:	default entries

index.html:	*.tex \
		articles.bbl 

# Regla para generar los .bbl a partir de los .tex
%.bbl:	../%.tex
	(export TEXINPUTS=${TEXINPUTS}; latex $*)
	(export BIBINPUTS=${BIBINPUTS}; bibtex $*)

# Regla para generar los .html a partir de los .tex
%.html: %.tex
	(export TEXINPUTS=${TEXINPUTS}; latex $*)
	(export TEXINPUTS=${TEXINPUTS}; latex $*)
	(export TEXINPUTS=${TEXINPUTS}; latex $*)
	(export TEXINPUTS=${TEXINPUTS}; htlatex $* "tex4ht.cfg, charset=utf-8" " -cunihtf -utf8")
#       (export TEXINPUTS=${TEXINPUTS}; tth $* > $*.html)

clean:
	rm -f *.bbl *.blg *.log *.out *.aux *.html *.dvi *.idv *.lg *.css *.4ct *.4tc *.tmp *.xref ResearcherID_URL.tex ORCID_URL.tex Scholar_URL.tex UAL_URL.tex GitHub_URL.tex

mrproper:
	make clean
	rm *.bib

entries:
	for i in `grep citation articles.aux inproceedings.aux | cut -f 2 -d "{" | cut -f 1 -d "}"`; do bibtool -X $$i $(HOME)/home/vruiz.bib -o $$i.bib -- 'delete.field={quality quality_long url history abstract es_abstract}'; done

TEXINPUTS := ".:"
BIBINPUTS := "$(HOME)/home:"

