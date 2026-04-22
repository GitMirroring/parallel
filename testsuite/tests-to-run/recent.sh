#!/bin/bash

# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Tests for changes made since release 20260322.
# Covers: sshcleanup/exitstatuswrapper fish fixes, --pipe --tee/--pipepart SSH,
#         env_parallel -S lo, --filter before delay/halt, skip() in {= =}.

export TMPDIR=/tmp/tt/" '"'`touch /tmp/trip`
  />/tmp/trip'
mkdir -p "$TMPDIR"

par_fish_wd_trc() {
    echo '### --wd ... --trc in fish: no bare < /dev/null redirection error'
    myscript=$(cat <<'_EOF'
    echo OK > bug_64222
    parallel --wd ... --sshlogin lo --trc {} cat ::: bug_64222
    rm -f bug_64222
_EOF
    )
    ssh fish@lo "$myscript"
}
# Expected output:
# ### --wd ... --trc in fish: no bare < /dev/null redirection error
# OK

par_fish_wd_transfer() {
    echo '### --wd ... --transfer --return in fish: exitstatuswrapper separator'
    myscript=$(cat <<'_EOF'
    echo OK > bug_64222
    parallel --wd ... --transfer -S lo cat ::: bug_64222
    rm -f bug_64222
_EOF
    )
    ssh fish@lo "$myscript"
}
# Expected output:
# ### --wd ... --transfer --return in fish: exitstatuswrapper separator
# OK

par_csh_wd_trc() {
    echo '### --wd ... --trc in csh: exitstatuswrapper must not produce ;;'
    myscript=$(cat <<'_EOF'
    echo OK > bug_64222
    parallel --wd ... --sshlogin lo --trc {} cat ::: bug_64222
    rm -f bug_64222
_EOF
    )
    ssh csh@lo "$myscript"
}
# Expected output:
# ### --wd ... --trc in csh: exitstatuswrapper must not produce ;;
# OK

par_bug34241() {
    echo "### bug #34241: --pipe should not spawn unneeded processes"
    echo | parallel -r -j2 -N1 --pipe md5sum -c && echo OK
}
# Expected output:
# ### bug #34241: --pipe should not spawn unneeded processes
# OK

par_fifo_under_csh() {
    echo '### Test --fifo under csh'
    doit() {
	csh -c "seq 3000000 | parallel -k --pipe --fifo 'sleep .{#};cat {}|wc -c ; false; echo \$status; false'"
	echo exit $?
    }
    # csh does not seem to work with TMPDIR containing \n
    doit
    TMPDIR=/tmp
    doit
}
# Expected output:
# ### Test --fifo under csh
# parallel: Warning: --cat/--fifo fails under csh if $TMPDIR contains newline.
# (with TMPDIR=/tmp, outputs 3 wc counts + "false" exit code lines)

par__cat_incorrect_exit_csh() {
    echo '### --cat gives incorrect exit value in csh'
    echo false | parallel --pipe --cat   -Scsh@lo 'cat {}; false' ; echo $?
    echo false | parallel --pipe --cat  -Stcsh@lo 'cat {}; false' ; echo $?
    echo true  | parallel --pipe --cat   -Scsh@lo 'cat {}; true' ; echo $?
    echo true  | parallel --pipe --cat  -Stcsh@lo 'cat {}; true' ; echo $?
}
# Expected output:
# ### --cat gives incorrect exit value in csh
# false
# 1
# false
# 1
# true
# 0
# true
# 0

par_tee_ssh() {
    seq 1000000 | parallel --pipe --tee -kS lo,csh@lo,tcsh@lo --tag 'echo {};wc' ::: A B ::: {1..4}
    seq 1000000 > /tmp/1000000
    parallel --pipepart -a /tmp/1000000 --tee -kS lo,csh@lo,tcsh@lo --tag 'echo {};wc' ::: A B ::: {1..4}
    echo "Do we get different shells?"
    parallel --pipepart -a /tmp/1000000 --tee -kS lo,csh@lo,tcsh@lo 'echo $SHELL' ::: A B ::: {1..4} | sort | uniq -c | field 1 | sort -n
}

par_pipe_tee_ssh() {
    echo '### --pipe --tee -S lo: data must reach local and remote (not 0 bytes)'
    seq 1000000 | parallel -j3 --pipe --tee -k -S lo,: 'wc {}' ::: -l -c -w
}
# Expected output:
# ### --pipe --tee -S lo: data must reach local and remote (not 0 bytes)
# 1000000
# 6888896
# 1000000

par_pipe_ssh() {
    echo '### --pipe -S lo,: basic pipe to remote'
    seq 1000000 | parallel --pipe -k -S lo,: wc -l
}

par_pipepart_ssh() {
    echo '### --pipepart -S lo: pipepart data reaches remote and local (sum must equal 100)'
    seq 100 > /tmp/recent-pipepart
    parallel --block -1 --pipepart -a /tmp/recent-pipepart -S :,lo wc -l |
        awk '{s+=$1}END{print s}'
    rm -f /tmp/recent-pipepart
}
# Expected output:
# ### --pipepart -S lo: pipepart data reaches remote and local (sum must equal 100)
# 100

par_pipepart_tee_ssh() {
    echo '### --pipepart --tee -S lo: data reaches each tee copy'
    seq 10 > /tmp/recent-ppteefile
    parallel --pipepart -a /tmp/recent-ppteefile --tee -k -S :,lo --tag wc {} ::: -l -c -w
    rm -f /tmp/recent-ppteefile
}
# Expected output:
# ### --pipepart --tee -S lo: data reaches each tee copy
# -l	10
# -c	21
# -w	10

par_env_parallel_ssh() {
    echo '### env_parallel -S lo: must produce output (not empty)'
    . $(which env_parallel.bash)
    env_parallel -k -S lo,: echo ::: a b c
}
# Expected output:
# ### env_parallel -S lo: must produce output (not empty)
# a
# b
# c

par_env_parallel_func_ssh() {
    echo '### env_parallel -S lo with function: function must transfer'
    . $(which env_parallel.bash)
    myfunc() { echo "func:$1"; }
    env_parallel -k -S lo,: myfunc ::: x y
}
# Expected output:
# ### env_parallel -S lo with function: function must transfer
# func:x
# func:y

par_cat_fifo_exit() {
    echo '### --cat and --fifo exit value in bash'
    echo true  | parallel --pipe --fifo -Slo 'cat {}; true' ; echo $?
    echo false | parallel --pipe --fifo -Slo 'cat {}; false' ; echo $?
}
# Expected output:
# ### --cat and --fifo exit value in bash
# true
# 0
# false
# 1

par_pipe_unneeded_procs() {
    echo 'bug #34241: --pipe should not spawn unneeded processes - part 2'
    tmp="$(mktemp -d)"
    cd "$tmp"
    seq 500 | parallel --tmpdir . -j10 --pipe --block 1k --files wc >/dev/null
    ls *.par | wc -l; rm *.par
    seq 500 | parallel --tmpdir . -j10 --pipe --block 1k --files --dry-run wc >/dev/null
    echo No .par should exist
    stdout ls *.par
    cd ..
    rm -r "$tmp"
}
# Expected output:
# bug #34241: --pipe should not spawn unneeded processes - part 2
# 2
# No .par should exist
# ls: cannot access '*.par': No such file or directory

par_bug45691() {
    echo 'bug #45691: Accessing multiple arguments in {= =}'
    # OK:
    parallel echo {= '$arg[1] eq 2 and $job->skip()' =} ::: {1..5}
    # Fails due to --keep-order because printing is looking for job 2
    parallel --keep-order echo {= '$arg[1] eq 2 and $job->skip()' =} ::: {1..5}
}
# Expected output:
# bug #45691: Accessing multiple arguments in {= =}
# 1
# 3
# 5
# 4
# 1
# 3
# 4
# 5

par_filter_dryrun() {
    echo 'bug #65840: --dry-run doesnot apply filters'
    parallel -k --filter='"{1}" ne "Not"' echo '{1} {2} {3}' ::: Not Is ::: good OK
    parallel --dr -k --filter='"{1}" ne "Not"' echo '{1} {2} {3}' ::: Not Is ::: good OK
}
# Expected output:
# bug #65840: --dry-run doesnot apply filters
# Is good
# Is OK
# echo Is good
# echo Is OK

par_filter_no_halt() {
    echo '### --filter + --halt: filtered jobs must not trigger halt failure'
    parallel --halt soon,fail=1 --filter '(-e "{}")' echo ::: /tmp/recent-noexist /tmp/recent-noexist2
    echo "exit:$?"
}
# Expected output:
# ### --filter + --halt: filtered jobs must not trigger halt failure
# exit:0

par_filter_no_delay() {
    echo '### --filter + --delay: filtered jobs must not consume delay slots'
    start=$SECONDS
    parallel --delay 1 -j1 --filter '{} > 4' echo ::: {1..8}
    elapsed=$((SECONDS - start))
    [ "$elapsed" -lt 7 ] && echo "FAST: filtered jobs skipped delay" || echo "SLOW: $elapsed s"
}
# Expected output:
# ### --filter + --delay: filtered jobs must not consume delay slots
# 5
# 6
# 7
# 8
# FAST: filtered jobs skipped delay

par_filter_no_retries() {
    echo '### --filter + --retries: filtered jobs must not trigger retries'
    parallel -u --retries 3 --filter '{} % 2' 'echo ran {};false' ::: 1 2 3
    echo "exit:$?"
}
# Expected output (odd jobs run 3 times each, even filtered out):
# ### --filter + --retries: filtered jobs must not trigger retries
# ran 1
# ran 1
# ran 1
# ran 3
# ran 3
# ran 3
# exit:2

par_skip_in_expr() {
    echo '### skip() in {= =} with --keep-order: must print a c (not just a)'
    parallel -k echo {= '$_ eq "b" and $job->skip()' =} ::: a b c
}
# Expected output:
# ### skip() in {= =} with --keep-order: must print a c (not just a)
# a
# c

par_skip_no_halt() {
    echo '### skip() must not count as failure for --halt'
    parallel -k --halt soon,fail=1 echo '{= $job->skip() =}' ::: a b c
    echo "exit:$?"
}
# Expected output:
# ### skip() must not count as failure for --halt
# exit:0

par_skip_no_delay() {
    echo '### skip() must not consume --delay slot'
    start=$SECONDS
    parallel --delay 1 -j1 echo '{= 2 < seq and seq() < 10 and skip(); =}' ::: {1..11}
    elapsed=$((SECONDS - start))
    [ "$elapsed" -lt 10 ] && echo "FAST: skipped jobs skipped delay" || echo "SLOW: $elapsed s (should be <10, unfixed would be ~11)"
}
# Expected output:
# ### skip() must not consume --delay slot
# 1
# 2
# 10
# 11
# FAST: skipped jobs skipped delay

par_--onall_--transfer() {
    echo '### bug #46519: --onall ignores --transfer'
    touch bug46519.{a,b,c}; rm -f bug46519.?? bug46519.???
    parallel --onall --tf bug46519.{} --trc bug46519.{}{} --trc bug46519.{}{}{} -S csh@lo,sh@lo 'ls bug46519.{}; touch bug46519.{}{} bug46519.{}{}{}' ::: a b c
    ls bug46519.?? bug46519.???
    parallel --onall -S csh@lo,sh@lo ls bug46519.{}{} bug46519.{}{}{} ::: a b c &&
	echo Cleanup failed
}
# Expected output:
# ### bug #46519: --onall ignores --transfer
# bug46519.aa
# bug46519.aaa
# bug46519.bb
# bug46519.bbb
# bug46519.cc
# bug46519.ccc

par__trc_colon() {
    echo '### Test --trc ./:dir/:foo2'
    mkdir -p ./:dir; echo 'Content :dir/:foo2' > ./:dir/:foo2
    stdout parallel --trc {}.1 -S sh@lo '(cat {}; echo remote1) > {}.1' ::: ./:dir/:foo2
    cat ./:dir/:foo2.1
    stdout parallel --trc {}.2 -S sh@lo '(cat ./{}; echo remote2) > {}.2' ::: :dir/:foo2
    cat ./:dir/:foo2.2
}
# Expected output:
# ### Test --trc ./:dir/:foo2
# Content :dir/:foo2
# remote1
# Content :dir/:foo2
# remote2

par_env_parallel_fish() {
    myscript=$(cat <<'_EOF'
    echo 'bug #50435: Remote fifo broke in 20150522'
    env_parallel --session
    set OK OK
    echo data from stdin | env_parallel --pipe -S lo --fifo 'cat {}; and echo $OK'
    echo data from stdin | env_parallel --pipe -S lo --cat 'cat {}; and echo $OK'
    echo OK: 0==$status
    echo '### Test failing command with --cat'
    echo data from stdin | env_parallel --pipe -S lo --cat 'cat {}; false'
    echo OK: 1==$status
    echo data from stdin | parallel --pipe -S lo --cat 'cat {}; false'
    echo OK: 1==$status
_EOF
    )
    ssh fish@lo "$myscript"
}
# Expected output:
# bug #50435: Remote fifo broke in 20150522
# data from stdin
# OK
# data from stdin
# OK
# OK: 0==0
# ### Test failing command with --cat
# data from stdin
# OK: 1==1
# data from stdin
# OK: 1==1

par__--tmux_different_shells() {
    echo '### Test tmux works on different shells'
    export TMPDIR=/tmp
    (
	stdout parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux echo ::: 1 2 3 4; echo $?
	stdout parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux false ::: 1 2 3 4; echo $?
	export PARTMUX='parallel -Scsh@lo,tcsh@lo,parallel@lo,zsh@lo --tmux '
	stdout ssh zsh@lo      "$PARTMUX" 'true  ::: 1 2 3 4; echo $status'
	stdout ssh zsh@lo      "$PARTMUX" 'false ::: 1 2 3 4; echo $status'
	stdout ssh parallel@lo "$PARTMUX" 'true  ::: 1 2 3 4; echo $?'
	stdout ssh parallel@lo "$PARTMUX" 'false ::: 1 2 3 4; echo $?'
	stdout ssh tcsh@lo     "$PARTMUX" 'true  ::: 1 2 3 4; echo $status'
	stdout ssh tcsh@lo     "$PARTMUX" 'false ::: 1 2 3 4; echo $status'
	echo "# command is currently too long for csh. Maybe it can be fixed?"
	stdout ssh csh@lo      "$PARTMUX" 'true  ::: 1 2 3 4; echo $status'
	stdout ssh csh@lo      "$PARTMUX" 'false ::: 1 2 3 4; echo $status'
    ) | replace_tmpdir | perl -pe 's/tms...../tmsXXXXX/g'
}
# Expected output:
# ### Test tmux works on different shells
# See output with: tmux -S /TMP/tmsXXXXX attach
# 0
# See output with: tmux -S /TMP/tmsXXXXX attach
# 4
# (repeated for each ssh invocation)

par__--tmux_length() {
    echo '### tmux examples that earlier blocked'
    export TMPDIR=/tmp
    (
	stdout parallel -Sparallel@lo --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@
	stdout parallel -Sparallel@lo --tmux echo ::: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	echo '### These blocked due to length'
	stdout parallel -Slo      --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@
	stdout parallel -Scsh@lo  --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@
	stdout parallel -Stcsh@lo --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@
	stdout parallel -Szsh@lo  --tmux echo ::: \\\\\\\"\\\\\\\"\\\;\@
	stdout parallel -Scsh@lo  --tmux echo ::: 111111111111111111111111111111111111111111111111111111111
    ) | replace_tmpdir | perl -pe 's:tms.....:tmsXXXXX:'
}
# Expected output:
# ### tmux examples that earlier blocked
# See output with: tmux -S /TMP/tmsXXXXX attach
# See output with: tmux -S /TMP/tmsXXXXX attach
# ### These blocked due to length
# (5 more "See output with" lines)

par_bin() {
    echo '### Test --bin'
    seq 10 | parallel --pipe --bin 1 -j4 wc | sort
    paste <(seq 10) <(seq 10 -1 1) |
	parallel --pipe --colsep '\t' --bin 2 -j4 wc | sort
    echo '### Test --bin with expression that gives 1..n'
    paste <(seq 10) <(seq 10 -1 1) |
	parallel --pipe --colsep '\t' --bin '2 $_=$_%2+1' -j4 wc | sort
    echo '### Test --bin with expression that gives 0..n-1'
    paste <(seq 10) <(seq 10 -1 1) |
	parallel --pipe --colsep '\t' --bin '2 $_%=2' -j4 wc | sort
    echo '### Blocks in version 20220122'
    echo 10 | parallel --pipe --bin 1 -j100% cat | sort
    paste <(seq 10) <(seq 10 -1 1) |
	parallel --pipe --colsep '\t' --bin 2 cat | sort
}

par_z_roundrobin_blocks() {
    echo "bug #49664: --round-robin does not complete"
    seq 20000000 | parallel -j8 --block 10M --round-robin --pipe wc -c | wc -l
}

par_groupby_compressed() {
    echo '### --groupby --pipepart on plain and gzip files give same line counts'
    seq 1 20 | awk '{print (NR%3), $1}' | sort -k1 > /tmp/test_groupby_plain.txt
    gzip -c /tmp/test_groupby_plain.txt > /tmp/test_groupby_plain.gz
    parallel --pipepart -a /tmp/test_groupby_plain.txt --groupby 1 -k 'wc -l' | sort
    parallel --pipepart -a /tmp/test_groupby_plain.gz  --groupby 1 -k 'wc -l' | sort
    rm /tmp/test_groupby_plain.txt /tmp/test_groupby_plain.gz
}

par_path_remote_bash() {
    echo 'bug #47695: How to set $PATH on remote? Bash'
    rm -rf /tmp/parallel
    cp /usr/local/bin/parallel /tmp

    cat <<'_EOS' |
    echo StArT
    echo BASH Path before: $PATH with no parallel
    parallel echo ::: 1 && echo ERROR
    # Race condition stderr/stdout
    sleep 1
    echo 'OK: if not found ^^^^^^^^'
    # Exporting a big variable should not fail
    export A="`seq 1000`"
    PATH=$PATH:/tmp
    . /usr/local/bin/env_parallel.bash
    # --filter-hosts to see if $PATH with parallel is transferred
    env_parallel --filter-hosts --env A,PATH -Slo echo {}: '$PATH' ::: OK
_EOS
    stdout ssh nopathbash@lo -T |
        perl -ne '/StArT/..0 and print' |
        uniq
    echo
}
# Expected output:
# bug #47695: How to set $PATH on remote? Bash
# StArT
# BASH Path before: /bin:/usr/bin with no parallel
# -bash: line 3: parallel: command not found
# OK: if not found ^^^^^^^^
# OK: /bin:/usr/bin:/tmp
#


export -f $(compgen -A function | grep par_)

# make it possible to run: 'recent.sh tee' to run all par_*tee* functions
compgen -A function | grep par_ | G "$@" | LC_ALL=C sort |
    parallel --timeout 600 -j6 --tag -k --joblog /tmp/jl-$(basename $0) '{} 2>&1'
