
Summary:	Shell tool for executing jobs in parallel
Name: 		parallel
Version: 	20241022
Release: 	2.1
License: 	GPL-3.0-or-later
Group: 		Productivity/File utilities
URL: 		ftp://ftp.gnu.org/gnu/parallel
Source0: 	%{name}_%{version}.tar.gz
BuildArch:	noarch
BuildRoot: 	%{_tmppath}/%{name}-%{version}-buildroot

%description
GNU Parallel is a shell tool for executing jobs in parallel using one
or more computers. A job can be a single command or a small script
that has to be run for each of the lines in the input. The typical
input is a list of files, a list of hosts, a list of users, a list of
URLs, or a list of tables. A job can also be a command that reads from
a pipe. GNU Parallel can then split the input and pipe it into
commands in parallel.

If you use xargs and tee today you will find GNU Parallel very easy to
use as GNU Parallel is written to have the same options as xargs. If
you write loops in shell, you will find GNU Parallel may be able to
replace most of the loops and make them run faster by running several
jobs in parallel.

GNU Parallel makes sure output from the commands is the same output as
you would get had you run the commands sequentially. This makes it
possible to use output from GNU Parallel as input for other programs.

For each line of input GNU Parallel will execute command with the line
as arguments. If no command is given, the line of input is
executed. Several lines will be run in parallel. GNU Parallel can
often be used as a substitute for xargs or cat | bash.

%prep
if [ "${RPM_BUILD_ROOT}x" == "x" ]; then
        echo "RPM_BUILD_ROOT empty, bad idea!"
        exit 1
fi
if [ "${RPM_BUILD_ROOT}" == "/" ]; then
        echo "RPM_BUILD_ROOT is set to "/", bad idea!"
        exit 1
fi
%setup -q

%build
./configure
make

%install
rm -rf $RPM_BUILD_ROOT
make install prefix=$RPM_BUILD_ROOT%{_prefix} exec_prefix=$RPM_BUILD_ROOT%{_prefix} \
    datarootdir=$RPM_BUILD_ROOT%{_prefix} docdir=$RPM_BUILD_ROOT%{_docdir} \
    mandir=$RPM_BUILD_ROOT%{_mandir}

rm $RPM_BUILD_ROOT%{_docdir}/parallel.html
rm $RPM_BUILD_ROOT%{_docdir}/env_parallel.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel_examples.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel_tutorial.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel_design.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel_alternatives.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel_book.html
rm $RPM_BUILD_ROOT%{_docdir}/niceload.html
rm $RPM_BUILD_ROOT%{_docdir}/sem.html
rm $RPM_BUILD_ROOT%{_docdir}/sql.html
rm $RPM_BUILD_ROOT%{_docdir}/parcat.html
rm $RPM_BUILD_ROOT%{_docdir}/parset.html
rm $RPM_BUILD_ROOT%{_docdir}/parsort.html
rm $RPM_BUILD_ROOT%{_docdir}/parallel.texi
rm $RPM_BUILD_ROOT%{_docdir}/env_parallel.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel_examples.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel_tutorial.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel_design.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel_alternatives.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel_book.texi
rm $RPM_BUILD_ROOT%{_docdir}/niceload.texi
rm $RPM_BUILD_ROOT%{_docdir}/sem.texi
rm $RPM_BUILD_ROOT%{_docdir}/sql.texi
rm $RPM_BUILD_ROOT%{_docdir}/parcat.texi
rm $RPM_BUILD_ROOT%{_docdir}/parset.texi
rm $RPM_BUILD_ROOT%{_docdir}/parsort.texi
rm $RPM_BUILD_ROOT%{_docdir}/parallel.pdf
rm $RPM_BUILD_ROOT%{_docdir}/env_parallel.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_examples.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_tutorial.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_design.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_alternatives.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_book.pdf
rm $RPM_BUILD_ROOT%{_docdir}/niceload.pdf
rm $RPM_BUILD_ROOT%{_docdir}/sem.pdf
rm $RPM_BUILD_ROOT%{_docdir}/sql.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parcat.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parset.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parsort.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_cheat_bw.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel_options_map.pdf
rm $RPM_BUILD_ROOT%{_docdir}/parallel.rst
rm $RPM_BUILD_ROOT%{_docdir}/env_parallel.rst
rm $RPM_BUILD_ROOT%{_docdir}/parallel_examples.rst
rm $RPM_BUILD_ROOT%{_docdir}/parallel_tutorial.rst
rm $RPM_BUILD_ROOT%{_docdir}/parallel_design.rst
rm $RPM_BUILD_ROOT%{_docdir}/parallel_alternatives.rst
rm $RPM_BUILD_ROOT%{_docdir}/parallel_book.rst
rm $RPM_BUILD_ROOT%{_docdir}/niceload.rst
rm $RPM_BUILD_ROOT%{_docdir}/sem.rst
rm $RPM_BUILD_ROOT%{_docdir}/sql.rst
rm $RPM_BUILD_ROOT%{_docdir}/parcat.rst
rm $RPM_BUILD_ROOT%{_docdir}/parset.rst
rm $RPM_BUILD_ROOT%{_docdir}/parsort.rst

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/usr/bin/*
/usr/share/bash-completion
/usr/share/bash-completion/completions
/usr/share/bash-completion/completions/parallel
/usr/share/zsh
/usr/share/zsh/site-functions
/usr/share/zsh/site-functions/_parallel
/usr/share/man/man1/*
/usr/share/man/man7/*
%doc README NEWS src/parallel.html src/env_parallel.html src/parallel_examples.html src/parallel_tutorial.html src/parallel_design.html src/parallel_alternatives.html src/parallel_book.html src/sem.html src/sql.html src/parcat.html src/parset.html src/parsort.html src/niceload.html src/parallel.texi src/env_parallel.texi src/parallel_examples.texi src/parallel_tutorial.texi src/parallel_design.texi src/parallel_alternatives.texi src/parallel_book.texi src/niceload.texi src/sem.texi src/sql.texi src/parcat.texi src/parset.texi src/parsort.texi src/parallel.pdf src/env_parallel.pdf src/parallel_examples.pdf src/parallel_tutorial.pdf src/parallel_design.pdf src/parallel_alternatives.pdf src/parallel_book.pdf src/niceload.pdf src/sem.pdf src/sql.pdf src/parcat.pdf src/parset.pdf src/parsort.pdf src/parallel_cheat_bw.pdf src/parallel_options_map.pdf src/parallel.rst src/env_parallel.rst src/parallel_examples.rst src/parallel_tutorial.rst src/parallel_design.rst src/parallel_alternatives.rst src/parallel_book.rst src/niceload.rst src/sem.rst src/sql.rst src/parcat.rst src/parset.rst src/parsort.rst

%changelog
* Sat Jan 22 2011 Ole Tange
- Upgrade to 20110122
* Wed Dec 22 2010 Ole Tange
- Upgrade to 20101222
* Wed Sep 22 2010 Ole Tange
- Upgrade to 20100922
* Mon Sep 06 2010 Ole Tange
- Upgrade to current git-version of source. Tested on build.opensuse.org 
* Fri Aug 27 2010 Ole Tange
- Untested upgrade to current git-version of source.

