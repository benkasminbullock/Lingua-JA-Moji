use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use Test::More;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";
use Lingua::JA::Moji 'hentai2kana';

my @shenanigans = qw/
1b002
1b023
1b077
1b11d
/;

my $hentaigana = '';
for (@shenanigans) {
    $hentaigana .= chr (hex ($_));
}
is (hentai2kana ($hentaigana), 'あきとんむも');

done_testing ();
