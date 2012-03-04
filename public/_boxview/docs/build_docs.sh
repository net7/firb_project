#!/bin/sh
# The location of your yuidoc install
yuidoc_home=yuidocs

# The location of the files to parse.  Parses subdirectories, but will fail if
# there are duplicate file names in these directories.  You can specify multiple
# source trees:
#     parser_in="%HOME/www/yui/src %HOME/www/event/src"
parser_in="../src"

# The location to output the parser data.  This output is a file containing a 
# json string, and copies of the parsed files.
parser_out=yuidocs/parser

# The directory to put the html file outputted by the generator
generator_out=.

# The location of the template files.  Any subdirectories here will be copied
# verbatim to the destination directory.
#template=$yuidoc_home/template
template=$yuidoc_home/dana_template

# The version of your project to display within the documentation.
v=`/usr/bin/head -1 ../VERSION.txt`

pname="BoxView $v"

##############################################################################
# add -s to the end of the line to show items marked private

rm -f *.html *json *.js

$yuidoc_home/bin/yuidoc.py $parser_in -p $parser_out -o $generator_out -t $template -m "$pname"

rm -rf $parser_out/*