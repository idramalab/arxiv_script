#!/bin/bash

##### INPUT #####
##Modify this accordingly
main="main"  #main source file
bib="biblio" #bib file 
fig_f="figures/" #folder with figures

##### OUTPUT #####
##Modify this with your preferred file names
upload="no_comments" #tex file without comments
archive="all.tar" #compress files so you can upload a single tar


#Removing all comments from the source
perl -pe 's/(^|[^\\])%.*/\1%/' < $main.tex > $upload.tex

##Compiling source and bibliography
pdflatex $upload.tex
bibtex $upload

#Switch from using the bibfile to including a bbl as requested by ArXiv
s='\\bibliography{'$bib'}'
r='%'$s'\n\\input{'$upload.bbl'}'
echo $s
echo $r
perl -pi -e "s/$s/$r/g" $upload.tex

##Remove Copyright
perl -pi -e 's/\\begin{document}/\\makeatletter\n\\def\\\@copyrightspace{\\relax}\n\\makeatother\n\\begin{document} /g' $upload

##Final compilation
pdflatex $upload.tex
pdflatex $upload.tex

##Creating an archive with (hopefully) all files
tar -cvzf $archive $upload.tex $upload.bbl $fig_f *.cls

##Cleaning up
rm -f *~
rm -f *.log
rm -f *.blg
rm -f $main.bbl
rm -f *.aux
rm -f *.lof
rm -f *.toc
rm -f *.loa
rm -f *.lot
rm -f *.lot
rm -f *.out
rm -f *.ps
rm -f *.dvi
rm -f *.dep
rm -f *.synctex.gz

