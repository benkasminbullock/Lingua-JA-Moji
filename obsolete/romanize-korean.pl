#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use Lingua::KO::Munja 'roman2hangul';
binmode STDOUT, ':utf8';

print $initial_re, "\n";
my $test = 'munja';
print roman2hangul ($test);
print "\n";
my $test2 = 'pyeonji';
print roman2hangul ($test2);
print "\n";
my $test3 = 'arpabes';
print roman2hangul ($test3);
print "\n";
my $test4 = 'toseuteu e syupeo sosiji';
print roman2hangul ($test4);
print "\n";



