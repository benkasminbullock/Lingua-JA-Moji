#!/home/ben/software/install/bin/perl
use Z;
use lib "$Bin/copied/lib";
use Perl::Build;
perl_build (
    makefile => "makeitfile",
);

