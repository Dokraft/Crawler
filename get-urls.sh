#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Missing one argument: the URL to process."
    # use an help function to display doc.
    exit 1
fi

if [ $# -gt 1 ]; then
    echo "Too many arguments."
    # use an help function to display doc.
    exit 2
fi

URL_REGEX='((https?:)?\/\/)?((([a-z0-9\-_]+\.)+[a-z]{2,})|(([0-9]{1,3}\.){3}[0-9]{1,3}))(\/[a-z0-9\-_]+)*\/?'

COUNT=`echo "$1" | grep -i -E -o "$URL_REGEX" | wc -l`

if [$COUNT -eq 0];then
	echo "Not a valid URL."
	exit3
fi

wget -q -O - $1
