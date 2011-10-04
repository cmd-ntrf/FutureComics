#!/bin/bash

function usage {
	echo "Usage :"
	echo "   -c : show only comic books"
	echo "   -f file : search every title in file"
	echo "   -g : show only gem item"
	echo "   -p id : search past form (id: mmmyy, i.e OCT11)"
	echo "   -s : show only spot item"
	echo "   -t title : search only this title"
	echo "   -h : show help"
}

function grep_title {
	title="$*"
	results=$(echo "$form" | egrep -i "$title" | egrep -i $id)
	header=$title
	if [ $gem_spot_item ]; then
		header=$header" "$gem_spot_item
		results=$(echo "$results" | egrep -w $gem_spot_item)
	fi
	results=$(echo "$results" | awk -F\t '{print $2, $3, $5}' | sed "s/$id //g" | sed "s/SRP: //g")
	echo "# $header #"
	echo "$results"
}

base_link="http://previewsworld.com/support/previews_docs/orderforms/archive/"
year=$(date +"%Y")
id=$(date +"%h%y" | tr '[:lower:]' '[:upper:]')

# Options
comic_only=0
single_title=1
while getopts ":t:f:p:cgsh" opt 
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
			gem_spot_item="GEM"
			;;
		p)
			id=$(echo $OPTARG | tr '[:lower:]' '[:upper:]')
			year=20$(echo $id | sed 's/[A-Z]//g')
			;;
		s)
			gem_spot_item="SPOT"
			;;
		t)
			single_title=1
			title=$OPTARG
			;;
		h)
			usage
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
if [ $year -lt 2010 ]; then
	link=$base_link/$year/$id/$form
fi
if [ ! -f $form ]; then
	curl -s -f $link > $form
fi

# To grab either only comics or everything items
if [ $comic_only -eq 1 ]; then
	form=$(head -n$(sed -n "/^BOOKS/=" $form) $form)
else
	form=$(cat $form)
fi

if [ $single_title -eq 0 ]; then
	cat $file | sort | while read title
	do
		grep_title $title
	done
else 
	grep_title $title
fi

