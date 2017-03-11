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
use Lingua::JA::Moji qw/hentai2kana hentai2kanji/;

# Cannot yet copy paste hentaigana into Emacs.

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
is (hentai2kanji ($hentaigana), '安喜土无');
done_testing ();
