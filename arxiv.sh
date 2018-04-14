#!/bin/bash

##### INPUT #####
##Modify this accordingly
main="main"  #main source file
bib="bibliography" #bib file 
fig_f="plots/" #folder with figures

##### OUTPUT #####
##Modify this with your preferred file names
upload="no_comments" #tex file without comments
archive="all.tar" #compress files so you can upload a single tar

##### FLAGS #####
#Set this to 1 if you want to upload only figures used in the tex
select_figures=0

if [ ! -f $main.tex ]; then
    echo $main.tex "not found!"
    exit 0
fi
if [ ! -f $bib.bib ]; then
    echo $bib.bib "not found!"
    exit 0
fi
if [ ! -d $fig_f ]; then
    echo "Folder" $fig_f "not found!"
    exit 0
fi

#Delete previous files
rm -rf $archive $upload

#Removing all comments from the source
perl -pe 's/(^|[^\\])%.*/\1%/' < $main.tex > $upload.tex

##Compiling source and bibliography
pdflatex $upload.tex
bibtex $upload

#Switch from using the bibfile to including a bbl as requested by ArXiv
s='\\bibliography{'$bib'}'
r='%'$s'\n\\input{'$upload.bbl'}'
#echo $s
#echo $r
perl -pi -e "s/$s/$r/g" $upload.tex

if [ $select_figures -eq "1" ]; then
	echo "here"
	s='\\begin{document}'
	r='\\listfiles\n'$s
	perl -pi -e "s/$s/$r/g" $upload.tex
	pdflatex $upload.tex
	r='\\begin{document}'
	s='\\listfiles\n'$r
	perl -pi -e "s/$s/$r/g" $upload.tex	
	awk '/\*File List*/{flag=1;next}/ \*\*\*\*\*\*\*\*\*\*\*/{flag=0}flag' $upload.log | grep $fig_f > __figures.txt
	#cat __figures.txt
	tar -czf _figures_bk.tar $fig_f 
	tar -cf __selectfigs.tar -T __figures.txt
	rm -rf $fig_f
	tar -xf __selectfigs.tar
	rm -rf __selectfigs.tar __figures.txt
fi


##Remove Copyright
perl -pi -e 's/\\begin{document}/\\makeatletter\n\\def\\\@copyrightspace{\\relax}\n\\makeatother\n\\begin{document} /g' $upload

##Final compilation
pdflatex $upload.tex
pdflatex $upload.tex

##Creating an archive with (hopefully) all files
rm -rf $archive
tar -czf $archive $upload.tex $upload.bbl $fig_f *.cls

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

