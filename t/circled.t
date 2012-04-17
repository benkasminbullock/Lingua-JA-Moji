use warnings;
use strict;
use utf8;
use Lingua::JA::Moji ':all';
use Test::More tests => 4;

my $circled = '㊄';
my $expect = '五';
my $output = circled2kanji ($circled);
ok ($output eq $expect);
my $round_trip = kanji2circled ($output);
ok ($round_trip eq $circled);

my $bracketed = '㈱';
my $expect2 = '株';
my $output2 = bracketed2kanji ($bracketed);
ok ($output2 eq $expect2);
my $round_trip2 = kanji2bracketed ($output2);
ok ($round_trip2 eq $bracketed);

exit;
