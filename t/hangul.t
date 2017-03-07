use warnings;
use strict;
use Lingua::JA::Moji qw/kana2hangul/;
use utf8;
use Test::More;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";

my $h = kana2hangul ('すごわざ');
is ($h, '스고와자', "Hangul conversion");
# http://lesson-hangeul.com/50itiranhyo.html
TODO: {
    local $TODO='Make this work better';
    is (kana2hangul ('とうきょうと かちゅしかく'), '도쿄토 가추시카쿠');
};
done_testing ();
