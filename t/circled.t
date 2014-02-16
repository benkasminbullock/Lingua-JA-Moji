use warnings;
use strict;
use utf8;
use Lingua::JA::Moji ':all';
use Test::More;

my $circled = '㊄';
my $expect = '五';
my $output = circled2kanji ($circled);
is ($output, $expect);
my $round_trip = kanji2circled ($output);
is ($round_trip, $circled);

my $bracketed = '㈱';
my $expect2 = '株';
my $output2 = bracketed2kanji ($bracketed);
is ($output2, $expect2);
my $round_trip2 = kanji2bracketed ($output2);
is ($round_trip2, $bracketed);

my $accept = '🉑';
my $expect3 = '可';
my $output3 = circled2kanji ($accept);
is ($output3, $expect3);
my $round_trip3 = kanji2circled ($output3);
is ($expect3, $output3);

done_testing ();

exit;
