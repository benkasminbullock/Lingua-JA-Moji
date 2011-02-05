use warnings;
use strict;
use utf8;
use Test::More tests => 27;
# http://code.google.com/p/test-more/issues/detail?id=46
binmode Test::More->builder->output, ":utf8";
binmode Test::More->builder->failure_output, ":utf8";
BEGIN { use_ok('Lingua::JA::Moji') };

use Lingua::JA::Moji qw/romaji2kana
                        kana2romaji
                        is_romaji
                        romaji2hiragana
                        is_kana
                        romaji_styles/;

# Sanity tests

ok (romaji2kana ('kakikukeko') eq 'カキクケコ');
ok (kana2romaji ('かきくけこ') eq 'kakikukeko');

# Sokuon

ok (romaji2kana ('kakko') eq 'カッコ');

ok (! is_romaji ("abcdefg"), "abcdefg does not look like romaji");
ok (is_romaji ("atarimae") eq "atarimae");
ok (romaji2hiragana ("iitte") eq "いいって", "romaji2hiragana does not use chouon");
ok (is_romaji ("kooru"));
#print is_romaji ("kuruu"), "\n";
ok (is_romaji ("kuruu") eq "kuruu");
ok (is_romaji ("benkyō suru"));

ok (is_kana ("いいって"));
ok (!is_kana ("いいってd"));
ok (!is_kana ("ddd"));

# Check for existence of styles

ok (romaji_styles ("nihon"));


my $ouhisi = kana2romaji ("おうひし", {style => "nihon", ve_type => "wapuro"});
#print "$ouhisi\n";

ok ($ouhisi eq "ouhisi");

# "romaji2hiragana" (Romaji to hiragana) tests

ok (romaji2hiragana ("fa-to") eq "ふぁーと");

# Double n plus vowel

my $double_n = romaji2hiragana ('keisatu no danna');
ok ($double_n =~ /んな/, "double n in 'danna' converted to ん plus な");

# l for small vowel

ok (romaji2kana ("lyo") eq "ョ");

# du, dzu both づ

ok (romaji2hiragana ("dudzu") eq "づづ", "Romanization of du, dzu");

# "is_romaji" tests

ok (is_romaji ('honto ni honto ni honto ni raion desu boku ben'));
ok (! is_romaji ('ドロップ'), 'katakana does not look like romaji');

# kana2romaji tests

my $fall = kana2romaji ("フォール", {ve_type => "wapuro"});
ok ($fall eq 'huxooru', "small o kana");
my $fell = kana2romaji ("フェール", {ve_type => "wapuro"});
ok ($fell eq 'huxeeru', "small e kana");
my $wood = kana2romaji ("ウッド");
ok ($wood !~ /ッ/);
my $legend = kana2romaji ('レジェンド');
#print "$legend\n";
ok ($legend =~ /zixe/, "je -> zixe");
my $perfume = kana2romaji ('パフューム', {ve_type => 'wapuro'});
#print "$perfume\n";
ok ($perfume eq 'pahuxyuumu');
my $invoice = kana2romaji ('インヴォイス', {ve_type => 'wapuro', debug=>undef});
#print "$invoice\n";
ok ($invoice eq 'invuxoisu');

