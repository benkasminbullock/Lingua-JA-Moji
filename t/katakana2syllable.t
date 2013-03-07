use warnings;
use strict;
use Test::More;
use utf8;
use Lingua::JA::Moji 'katakana2syllable';

my $long = 'ソーシャルブックマークサービス';

my $pieces = katakana2syllable ($long);

is_deeply ($pieces,
           ['ソー', 'シャ', 'ル', 'ブ', 'ック', 'マー', 'ク', 'サー', 'ビ', 'ス'],
           "decomposition of katakana into syllables");

$long = 'ソーシャール';

$pieces = katakana2syllable ($long);

is_deeply ($pieces,
           ['ソー', 'シャー', 'ル'],
           "ya plus chouon");

done_testing ();
