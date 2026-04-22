#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

par_groupby_compressed() {
    echo '### --groupby --pipepart on plain and gzip files give same line counts'
    seq 1 20 | awk '{print (NR%3), $1}' | sort -k1 > /tmp/test_groupby_plain.txt
    gzip -c /tmp/test_groupby_plain.txt > /tmp/test_groupby_plain.gz
    parallel --pipepart -a /tmp/test_groupby_plain.txt --groupby 1 -k 'wc -l' | sort
    parallel --pipepart -a /tmp/test_groupby_plain.gz  --groupby 1 -k 'wc -l' | sort
    rm /tmp/test_groupby_plain.txt /tmp/test_groupby_plain.gz
}

export -f $(compgen -A function | grep par_)

# make it possible to run: 'recent.sh tee' to run all par_*tee* functions
compgen -A function | grep par_ | G "$@" | LC_ALL=C sort |
    parallel --timeout 600 -j6 --tag -k --joblog /tmp/jl-$(basename $0) '{} 2>&1'
