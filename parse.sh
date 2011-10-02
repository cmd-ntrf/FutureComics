#!/bin/bash

function usage {
	echo "Usage :"
	echo "   -c : show only comic books"
	echo "   -f file : search every title in file"
	echo "   -g : show only gem item"
	echo "   -s : show only spot item"
	echo "   -t title : search only this title"
	echo "   -h : show help"
}

function grep_title {
	title="$*"
	echo "# $title $gem_spot_title #"
	head -n$max_line $form | egrep -i "$title" | egrep -i $id | egrep -w $gem_spot_title | awk -F\t '{print $2, $3, $5}' | sed "s/$id //g" | sed "s/SRP: //g"
}

base_link="http://previewsworld.com/support/previews_docs/orderforms/archive/"
year=$(date +"%Y")
id=$(date +"%h%y" | tr '[:lower:]' '[:upper:]')

# Options
comic_only=0
single_title=2
gem_spot_item=""
while getopts ":t:f:cgsh" opt 
do
	case $opt in
		c)
			comic_only=1
			;;
		f)
			single_title=0
			file=$OPTARG
			;;
		g)
			gem_spot_title="GEM"
			;;
		s)
			gem_spot_title="SPOT"
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
if [ ! -f $form ]; then
	curl -s $link > $form
fi

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

