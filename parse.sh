#!/bin/bash

function usage {
	echo "Usage :"
	echo "   -c : show only comic books"
	echo "   -f file : search every title in file"
	echo "   -t title : search only this title"
	echo "   -h : show help"
}

function grep_title {
	title="$*"
	echo "# $title #"
	head -n$max_line $form | egrep -i "$title" | egrep -i $id | awk -F\t '{print $2, $3, $5}' | sed "s/$id //g" | sed "s/SRP: //g"
}

base_link="http://previewsworld.com/support/previews_docs/orderforms/archive/"
year=$(date +"%Y")
id=$(date +"%h%y" | tr '[:lower:]' '[:upper:]')

# Options
comic_only=0
single_title=2
while getopts ":t:f:ch" opt 
do
	case $opt in
		c)
			comic_only=1
			;;
		f)
			single_title=0
			file=$OPTARG
			;;
		t)
			single_title=1
			title=$OPTARG
			;;
		h)
			exit 0
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			usage
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument."
			usage
			exit 1
			;;
	esac
done

form=$id"_cof.txt"
link=$base_link/$year/$form
curl -s $link > $form

# To grab either only comics or everything else
if [ $comic_only -eq 1 ]; then
	max_line=$(sed -n "/BOOKS & MAGAZINES/=" $form)
else
	max_line=$(sed -n '$=' $form)
fi

if [ $single_title -eq 0 ]; then
	cat $file | sort | while read title
	do
		grep_title $title
	done
else 
	grep_title $title
fi

