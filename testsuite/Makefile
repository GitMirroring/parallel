# SPDX-FileCopyrightText: 2021-2026 Ole Tange, http://ole.tange.dk and Free Software and Foundation, Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

ORACLE_VM_IP = $(shell grep .private_network.*ip:. vagrant-projects/OracleDatabase/26ai-Free/Vagrantfile | grep -oE .\\b[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\\b.)

### Full test set (except mem)
testsuite: short
	true

all: mem short long polar 
	true

#3: ../src/parallel tests-to-run/* wanted-results/* dbstart prereqlocal prereqremote
3: ../src/parallel tests-to-run/* wanted-results/* prereqlocal prereqremote
	TRIES=3 time bash Start.sh '' 'mem|manual' || true
	touch ~/.parallel/will-cite
	make stopvm

1: ../src/parallel tests-to-run/* wanted-results/* prereqlocal dbstart prereqremote
	TRIES=1 time bash Start.sh '' mem || true
	touch ~/.parallel/will-cite
	make stopvm

# Mem
mem: ../src/parallel tests-to-run/*mem* wanted-results/*mem*
	make stopvm || true
	make dbstop || true
	time bash Start.sh mem NONE || true
	touch ~/.parallel/will-cite
	make stopvm

# The output must be inspected visually
manual: ../src/parallel tests-to-run/*manual* wanted-results/*manual*
	bash tests-to-run/parallel-manual.sh

# Tutorial
tutorial: ../src/parallel tests-to-run/*tutorial* wanted-results/*tutorial* prereqlocal
	TRIES=1 time bash Start.sh tutorial NONE || true
	touch ~/.parallel/will-cite
	make stopvm

# 100s and 300s
100s: ../src/parallel tests-to-run/*00s* wanted-results/*00s* prereqlocal
	time bash Start.sh 00s NONE || true
	touch ~/.parallel/will-cite
	make stopvm

# Polarhome
polarhome: polar
	true

polar: ../src/parallel tests-to-run/*polar* wanted-results/*polar* prereqlocal
	time bash Start.sh polar NONE || true
	touch ~/.parallel/will-cite

test-recent: ../src/parallel tests-to-run/recent.sh wanted-results/recent prereqlocal installparallel
	TRIES=1 time bash Start.sh recent NONE

# Generic test runner: make test-local-fast -> bash Start.sh local-fast NONE
test-%:	../src/parallel prereqlocal installparallel
	TRIES=1 time bash Start.sh $* NONE

# *local* only
local:	../src/parallel tests-to-run/*local* wanted-results/*local* prereqlocal installparallel
	time bash Start.sh local 'mem|ssh|manual'

# short
short:	 ../src/parallel tests-to-run/* wanted-results/* prereqlocal installparallel
	TRIES=1 time bash Start.sh '' 'polar|mem|100s|300s|manual'

# Tests not requiring SSH
no-ssh: ../src/parallel tests-to-run/*no-ssh* wanted-results/*no-ssh* prereqlocal installparallel
	TRIES=1 time bash Start.sh no-ssh manual || true
	touch ~/.parallel/will-cite

# Tests using SSH to localhost/lo only
local-ssh: ../src/parallel tests-to-run/*local-ssh* wanted-results/*local-ssh* prereqlocal installparallel
	TRIES=1 time bash Start.sh local-ssh manual || true
	touch ~/.parallel/will-cite

# Tests using SSH to remote servers
remote-ssh: ../src/parallel tests-to-run/*remote-ssh* wanted-results/*remote-ssh* prereqlocal prereqremote installparallel
	TRIES=1 time bash Start.sh remote-ssh manual || true
	touch ~/.parallel/will-cite

# Tests not requiring SSH (includes timing/load tests)
default: ../src/parallel tests-to-run/* wanted-results/* prereqlocal installparallel
	TRIES=1 time bash Start.sh '' 'local-ssh|remote-ssh|mem|manual|polar|install' || true
	touch ~/.parallel/will-cite

# long
long:	 ../src/parallel tests-to-run/* wanted-results/* prereqlocal installparallel
	TRIES=1 time bash Start.sh '00s' NONE

# short and local
localshort: ../src/parallel tests-to-run/*local* wanted-results/*local* prereqlocal installparallel
	TRIES=1 time bash Start.sh local 'mem|100s|300s'

# sql
testdb: ../src/parallel tests-to-run/*sql* wanted-results/*sql* prereqdb
	time bash Start.sh sql NONE

# Portable tests that run everywhere
portable:
	# Cache sudo password
	sudo echo
	time bash Portable.sh

### Prerequisites
REQUIRE=bash -c '\
  is_installed() { \
    eval $$2 >/dev/null 2>/dev/null || (echo "$$1" is required for testsuite; /bin/false); \
  }; \
  export -f is_installed; \
  PARALLEL_SHELL=bash parallel -n2 --tag is_installed ::: \
	script		"echo | script -c echo -q /dev/null"			\
	niceload	"niceload echo niceload is installed"			\
	expect	"expect -c \"spawn cat; puts \\\"expect is installed\\\"\"" 	\
	tcsh		"tcsh -c echo tcsh installed"				\
	seq		"seq 1 2"						\
	stdout		"stdout echo stdout is installed"			\
	convert		"convert -version"					\
	bc		"echo 1+2 | bc"						\
	gawk		"echo | gawk \"{print \\\"gawk is installed\\\"}\""	\
	pv		"echo | pv -qL 10"					\
	timeout		"timeout 1 echo timeout is installed"			\
'

prereqlocal: installparallel
	${REQUIRE}
	# Bug that causes systemd-logind to go into 100%
	sudo modprobe -r ucsi_acpi

prereqremote: installparallel startvm
# TODO Check these are installed and work
#	autossh		"autossh -V"						\
#	lsh	"lsh lo echo lsh is installed"					\
#	"ssh sh@lo"	"timeout 20 ssh sh@lo true"				\
#	sshpass		"sshpass echo sshpass is installed"			\
#	"ssh csh@lo"	"timeout 15 ssh csh@lo true"				
	parallel -j0 --timeout 10 --tag ssh -oStrictHostKeyChecking=accept-new vagrant@parallel-server{} parallel --minversion 20121021 ::: 1 2 || (echo parallel on remote required for testsuite; /bin/true)

namedservers=centos3 centos8 centos9 freebsd13 freebsd14 openindiana rhel8 opensuse15

servers=parallel-server1 parallel-server2 parallel-server3 parallel-server4 ${namedservers}

snapstart: startsnap
	true

startsnap:
	# Restore last snapshot
	touch vagrant/authorized_keys
	sort -u ~/.ssh/*.pub vagrant/authorized_keys > vagrant/authorized_keys.
	mv vagrant/authorized_keys. vagrant/authorized_keys
	parallel -j0 --tagstring {#}-{} -k --timeout 300 bin/vm restoresnapshot ::: ${servers}

checkvm:
	parallel -j0 --delay 0.5 --color-failed --plus --tagstring '/|\ {0#} {}' --timeout 40 bin/vm check ::: ${servers}

startvm:
	touch vagrant/authorized_keys
	sort -u ~/.ssh/*.pub vagrant/authorized_keys > vagrant/authorized_keys.
	mv vagrant/authorized_keys. vagrant/authorized_keys
	bin/vm cleanorphans ${namedservers}
	parallel -j0 --delay 0.2 --plus --tagstring '/|\ {0#} {}' --lb --timeout 300 bin/vm start ::: ${servers}

stopvm:
	parallel -vj0 --tag -k bin/vm stop ::: ${namedservers} || true

haltvm:
	parallel -vj0 --tag -k bin/vm halt ::: ${namedservers} || true

snapshot:
	# Make snapshots of the working, running vms
	parallel -j0 ssh vagrant@{} echo {} ::: ${namedservers} | parallel --tagstring {1} --colsep ' ' bin/vm snapshot
	. ~/.passwords && sql oracle://SYSTEM:$$VM_ORACLE_PWD@/FREE "select 'Oracle is running' from dual;" && bin/vm snapshot 26ai-Free

snapshotclean:
	# Keep 2 snapshots of the running vms
	VBoxManage list runningvms | parallel --colsep ' ' --tagstring {2} -k VBoxManage snapshot {2} list '| head -n -2' | parallel --match '(\S+)\s+.*UUID: (\S+).' -j1 VBoxManage snapshot {1.1} delete {1.2}
	VBoxManage list runningvms | parallel --colsep ' ' --tagstring {2} -k VBoxManage snapshot {2} list

startdb: dbstart
	true

stopdb: dbstop
	true

dbstart:
	make dbtestonip || make dbvagrantstart
	make dbtestonlocalhost || make dbstarttunnel
	make dbtestonip dbtestonlocalhost

dbstop:
	cd vagrant-projects/OracleDatabase/26ai-Free; vagrant suspend
dbhalt:
	cd vagrant-projects/OracleDatabase/26ai-Free; vagrant halt

dbtestonip:
	# Test if db answers on <<ip>>:1521
	. ~/.passwords && sql oracle://SYSTEM:$$VM_ORACLE_PWD@$(ORACLE_VM_IP):1521/FREE "select 'Oracle is running on $(ORACLE_VM_IP)' from dual;"

dbtestonlocalhost:
	# Test if db answers on localhost:1521
	. ~/.passwords && sql oracle://SYSTEM:$$VM_ORACLE_PWD@/FREE "select 'Oracle is running on localhost' from dual;"

dbstarttunnel:
	# sql cannot access lo:1521 => Start SSH tunnel for localhost:1521
	# (bypasses VirtualBox NAT packet corruption of Oracle TNS)
	# Must check the actual listening port, not `pgrep -f`: make passes this
	# whole recipe to `sh -c` as one argument, so a `pgrep -f` pattern that
	# matches the ssh command below also matches that wrapping shell itself,
	# making the check always true and the tunnel never start.
	ss -ltn 'sport = :1521' | grep -q ':1521' || \
	  (cd vagrant-projects/OracleDatabase/26ai-Free && vagrant ssh-config > /tmp/oracle-ssh-config && \
	   ssh -f -N -L 127.0.0.1:1521:localhost:1521 -F /tmp/oracle-ssh-config oracle26ai-free-vagrant)

dbvagrantstart:
	# sql cannot access IP-address:1521 => Start Oracle VM
	cd vagrant-projects/OracleDatabase/26ai-Free && vagrant up

### Distribution
installparallel: ../src/parallel
	cd .. && make -j && sudo make -j install

clean:
	rm -rf input-files/random_dirs_no_newline
	rm -rf input-files/random_dirs_with_newline

dist:
	rm -rf input-files/random_dirs_*_newline || /bin/true
	rm -rf tmp || /bin/true
	( cd ..; tar -cvj --exclude .git --exclude '#*#' --exclude '*~' --exclude CVS -f /tmp/parallel.tar.bz2 parallel-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] )
	mv /tmp/parallel.tar.bz2 parallel-$$(date +"%Y%m%d").tar.bz2
	rsync -Havessh parallel-$$(date +"%Y%m%d").tar.bz2 download.savannah.nongnu.org:/releases/parallel/

### Measure timings
timings: tests-to-run/* ../src/parallel
	ls tests-to-run/*.sh | parallel echo /usr/bin/time -f "'%e\ %P'" bash >/tmp/timing.script
	stdout bash -x /tmp/timing.script | tee /tmp/timing.out
	echo + .usr.bin.time_END >>/tmp/timing.out
	perl -ne '/\+ .usr.bin.time/ and do { print $$last.$$h; $$h=$$_ }; chomp; s/.*\0//;$$last = $$_' /tmp/timing.out |sort -n >timings

timingbar:
	vmstat 1 | timestamp --isotime > vmstat.timestamp.1 &
	stdout make 1 | timestamp --isotime | tee make.timestamp.1
	killall vmstat
	mv vmstat.timestamp.1 vmstat.timestamp
	mv make.timestamp.1 make.timestamp
	sort vmstat.timestamp make.timestamp | perl -pe '/tests-to-run(\S+)/ and $$p=$$1; print "$$p "' | field 6,1,2 | perl -ne '/^\d+ / and print' | histogram -i vh
