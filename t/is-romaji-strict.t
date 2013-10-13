use warnings;
use strict;
use Test::More;
use Lingua::JA::Moji 'is_romaji_strict';

ok (is_romaji_strict ('Shigeru Yoshikawa'), "Shigeru Yoshikawa = Japanese");
ok (! is_romaji_strict ('Lolita'), "Lolita != Japanese");
ok (! is_romaji_strict ('Hu Piaoye'), "Hu Piaoye != Japanese");

done_testing ();
