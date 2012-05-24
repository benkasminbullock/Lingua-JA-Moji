use warnings;
use strict;
use Lingua::JA::Moji 'romaji2kana';
use Test::More tests => 2;
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";
use utf8;
my $bye = romaji2kana ("bye");
ok ($bye eq 'ビェ', "Romanization of bye as ビェ");
my $la = romaji2kana ('lalilulelo');
ok ($la eq 'ァィゥェォ', "Romanization of lalilulelo is ァィゥェォ");

