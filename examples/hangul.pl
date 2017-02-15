#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Lingua::JA::Moji ':all';
my $h = '와이파이';
binmode STDOUT, ":encoding(utf8)";
print hangul2kana ($h);
