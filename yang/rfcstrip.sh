#!/bin/sh
#
# rfcstrip --
#
#       Extract code from text files, like RFCs or I-Ds.
#
# This program is a slightly patched version of smistrip.  In addition to
# MIB modules, it recognizes YANG modules and the markers:
#   &lt;CODE BEGINS&gt; file "name-of-file"
#   &lt;CODE ENDS&gt;
# 
# Modified by Martin Bjorklund, Tail-f Systems.
#
# smistrip:
# Copyright (c) 1999 Frank Strauss, Technical University of Braunschweig.
#
# See the file "COPYING" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# NOTE, that this script relies on awk (tested with GNU awk) and getopts
# (shell builtin like in bash or standalone).
#

AWK=/usr/bin/awk
GETOPTS=getopts
VERSION=0.2


do_version () {
    echo "rfcstrip $VERSION"
}

do_usage () {
    echo "Usage: rfcstrip [-Vhn] [-i dir] [-d dir] [-f file] file1 [file2 [...]]"
    echo "-V         show version"
    echo "-h         show usage information"
    echo "-n         do not write files"
    echo "-i dir     try to read files from directory dir"
    echo "-d dir     write file to directory dir"
    echo "-f file    strip only the specified file"
    echo "file1 ...  input files to parse (RFCs, I-Ds, ...)"
}



do_strip () {
    if [ "$indir" ] ; then
        FILE="$indir/$1"
    else
        FILE="$1"
    fi
    if [ ! -f "$FILE" -a -f "$FILE.gz" ] ; then
        FILE="$FILE.gz"
    fi
    echo "$FILE" | grep -q '\.gz$'
    if [ $? -ne 0 ] ; then
        CMD=cat
    else
        CMD=zcat
    fi

    $CMD "$FILE" | \
    tr -d '\015' | \
    $AWK -vtest="$test" -vdir="$dir" -vsingle="$single" '

    BEGIN {
        type = 0
    }

    # generic start marker
    type == 0 &amp;&amp; /^[ \t]*&lt;CODE BEGINS&gt; +file +"(.*)" *$/ {
        file = substr($4, 2, length($4)-2)
        preskip = 3
        skip = 5
        skipped = -1
        n = 0
        type = 1
        delete line

        next
    }

     # start of SMI module
    type == 0 &amp;&amp;
    /^[ \t]*[A-Za-z0-9-]* *(PIB-)?DEFINITIONS *(::=)? *(BEGIN)? *$/ {
        file = $1
        preskip = 3
	skip = 4
        skipped = -1
        macro = 0
        n = 0
        type = 2
        delete line
    }

    # start of YANG module
    type == 0 &amp;&amp;
    /^[ \t]*(sub)?module +([A-Za-z0-9-]*) *{ *$/ {
	module = $2
        file = module".yang"
   	modindent = match($0, "[^ \t]")
        preskip = 3
	skip = 4
	skipped = -1
	n = 0
        type = 3
        delete line
    }

    # process each line
    {
        # at the end of a page we go back one line (which is expected to
        # be a separator line), and start the counter skipped to skip the
        # next few lines.
        if (type != 0 &amp;&amp; $0 ~ /\[[pP]age [iv0-9]*\] */) {
            for (i = 0 ; i &lt; preskip ; i++) {
                n--
                if (!(line[n] ~ /^[ \t]*$/)) { 
                    print "WARNING: the line:: "line[n]":: \
                       should be blank before a page break. It was kept. "
                    n++
                    break
                }
            }
            # some drafts do not use that separator line. so keep it if
            # there are non-blank characters.

            skipped = 0
        }

        # if we are skipping...
        if (skipped &gt;= 0) {
            skipped++

            # if we have skipped enough lines to the top of the next page...
            if (skipped &gt; skip) {
                skipped = -1
            } else {
                # finish skipping if we find a non-empty line, but not before
                # we have skipped three lines.
                if ((skipped &gt; 3) &amp;&amp; ($0 ~ /[^ \t]/)) {
                    skipped = -1
                }   
            }
        }

        # so, if we are not skipping and inside a file, remember the line.
        if ((skipped == -1) &amp;&amp; (length(file) &gt; 0)) {
            line[n++] = $0
        }
    }

    # remember when we enter a macro definition
    type == 2 &amp;&amp; /^[ \t]*[A-Za-z0-9-]* *MACRO *::=/ {
        macro = 1
    }

    # generic end marker
    type == 1 &amp;&amp; /^[ \t]*&lt;CODE ENDS&gt;.*$/ {
        if ((length(single) == 0) || (single == file)) {
            n--
            strip = 99
            for (i=0 ; i &lt; n ; i++) {
                # find the minimum column that contains non-blank characters
                # in order to cut a blank prefix off. Ignore lines that only
                # contain white spaces.
                if (!(line[i] ~ /^[ \t]*$/)) {
                    p = match(line[i], "[^ \t]")
                    if ((p &lt; strip) &amp;&amp; (length(line[i]) &gt; p)) { strip = p }
                }
            }
            if (dir) {
                f = dir"/"file
            } else {
                f = file
            }
            # skip empty lines in the beginning
            j = 0
            for (i=0 ; i &lt; n ; i++) {
                if (!(line[i] ~ /^[ \t]*$/)) {
                    break
                }
                j++
            }
            # skip empty lines at the end
            m = n-1
            for (i=n-1 ; i &gt;= 0 ; i--) {
                if (!(line[i] ~ /^[ \t]*$/)) {
                    break
                }
                m--
            }

            if (test != "1") {
                for (i = j ; i &lt;= m ; i++) {
                    print substr(line[i], strip) &gt;f
                }
            }
    
            print f ": " 1+m-j " lines."
        }
        file = ""
        type = 0
    }

    # end of SMI module
    type == 2 &amp;&amp; /^[ \t]*END[ \t]*$/ {
        if (macro == 0) {
            if ((length(single) == 0) || (single == file)) {
                strip = 99
                for (i=0 ; i &lt; n ; i++) {
                    # find the minimum column that contains non-blank characters
                    # in order to cut a blank prefix off. Ignore lines that only
                    # contain white spaces.
                    if (!(line[i] ~ /^[ \t]*$/)) {
                        p = match(line[i], "[^ ]")
                        if ((p &lt; strip) &amp;&amp; (length(line[i]) &gt; p)) { strip = p }
                    }
                }
    
                if (dir) {
                   f = dir"/"file
                } else {
                   f = file
                }
                if (test != "1") {
                    for (i=0 ; i &lt; n ; i++) {
                        print substr(line[i], strip) &gt;f
                    }
                }
    
                print file ": " n " lines."
            }
            file = ""
            type = 0
        } else {
            macro = 0
        }
    }

    # end of YANG module
    type == 3 &amp;&amp; /^[ \t]*}.*$/ {
        indent = match($0, "[^ \t]")
        if (indent == modindent) {
            modindent = -1
            # we assume that a module is ended with a single "}" with the
            # same indentation level as the module statement.
	    if ((length(single) == 0) || (single == module)) {
		strip = 99
		for (i=0 ; i &lt; n ; i++) {
		    # find the minimum column that contains non-blank characters
		    # in order to cut a blank prefix off. Ignore lines that only
                    # contain white spaces.
                    if (!(line[i] ~ /^[ \t]*$/)) {
        	        p = match(line[i], "[^ ]")
		        if ((p &lt; strip) &amp;&amp; (length(line[i]) &gt; p)) { strip = p }
                    }
		}
    
		if (test != "1") {
		    if (dir) {
		       f = dir"/"file
		    } else {
		       f = file
		    }
		    for (i=0 ; i &lt; n ; i++) {
			print substr(line[i], strip) &gt;f
		    }
		}
    
		print f ": " n " lines."
	    }            
	    module = ""
            file = ""
            type = 0
	}
    }
    
    '
}



while $GETOPTS Vhnm:i:d: c ; do
    case $c in
        n)      test=1
                ;;
        f)      single=$OPTARG
                ;;
        i)      indir=$OPTARG
                ;;
        d)      dir=$OPTARG
                ;;
        h)      do_usage
                exit 0
                ;;
        V)      do_version
                exit 0
                ;;
        *)      do_usage
                exit 1
                ;;
    esac
done

shift `expr $OPTIND - 1`



if [ $# -eq 0 ] ; then
    do_strip -
else 
    for f in "$@" ; do
        do_strip "$f"
    done
fi

exit 0
