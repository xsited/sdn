#!/bin/sh

# using pyang to validate handwritten yang definitions
# apt-get install python-pyang
# astyle works for formatting, but breaks up the type flow:thing line and casues  a syntax validation error
# convert yang to uml to work with in an IDE
# Create UML diagram with plantUML

for i in `ls *.yang` ; do
	fbname=`basename "$i" .yang`
# s=${s##*/}
# echo ${s%.txt}
	echo "\n\nWorking on $fbname ..."
	#echo "Formatting yang file ..."
	#astyle -b -s4 $i
	echo "Validating yang file ..."
	pyang -p ../ietf -p ../odl $i
	echo "Converting yang to uml  ..."
	pyang -p ../ietf -p ../odl $i -f uml -o $fbname.uml
	echo "Creating uml diagram  ..."
	java -jar plantuml.jar $fbname.uml
done
