use warnings;
use strict;
use Lingua::JA::Moji 'romaji2kana';
use Test::More tests => 1;
my $bye = romaji2kana ("bye");
ok ($bye eq 'ビェ', "Romanization of bye as ビェ");

