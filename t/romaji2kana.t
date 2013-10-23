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
is (romaji2kana ('fya'), 'フャ', "Romaji conversion of fya to huxya");
is (romaji2kana ('fye'), 'フェ', "Romaji conversion of fye to huxe");
is (romaji2kana ('fyi'), 'フィ', "Romaji conversion of fyi to huxi");
is (romaji2kana ('fyo'), 'フョ', "Romaji conversion of fyo to huxyo");
is (romaji2kana ('fyu'), 'フュ', "Romaji conversion of fyu to huxyu");
is (romaji2kana ('dye dyi'), 'ヂェ ヂィ', "Conversion of dye, dyi");
is (romaji2kana ('mye myi'), 'ミェ ミィ', "Conversion of mye, myi");
is (romaji2kana ('gottsu'), 'ゴッツ', 'Conversion of gottsu');

done_testing ();
