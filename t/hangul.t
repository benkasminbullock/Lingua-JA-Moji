use warnings;
use strict;
use Lingua::JA::Moji qw/kana2hangul/;
use utf8;
use Test::More tests => 1;

my $h = kana2hangul ('すごわざ');
ok ($h eq '스고와자', "Hangul conversion");
