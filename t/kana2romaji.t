use warnings;
use strict;
use Test::More;
use Lingua::JA::Moji 'kana2romaji';
use utf8;
is (kana2romaji ('ドッグ'), 'doggu');
# Common
is (kana2romaji ('ジェット', {style => 'common'}), 'jetto');
is (kana2romaji ('ウェ', {style => 'common'}), 'we');

done_testing ();

