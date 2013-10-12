use warnings;
use strict;
use Lingua::JA::Moji 'romaji2kana';
use Test::More;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";

use utf8;
is (romaji2kana ("bye"), 'ビェ', "Romanization of bye as ビェ");
is (romaji2kana ('lalilulelo'), 'ァィゥェォ', "Romanization of lalilulelo is ァィゥェォ");
is (romaji2kana ('hyi'), 'ヒィ', "Romaji conversion of hyi to hixi");
is (romaji2kana ('hye'), 'ヒェ', "Romaji conversion of hye to hixe");

done_testing ();
